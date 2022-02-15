
#' Feature Collections
#'
#' List of available feature collections from the [MSC GeoMet OGC API](https://api.weather.gc.ca/) `/collections` endpoint.
#'
#' @param incl_extents A logical scalar. If `TRUE`, spatial and temporal extents for each feature collection are returned. Defaults to `FALSE`.
#' @param url_only A logical scalar. If `TRUE`, request URL is returned without making GET request to API. Defaults to `FALSE`.
#'
#' @return A data frame of available features collections, including unique identifier (`collection_id`), title and description.
#' @export
#'
#' @examples
#' collections()
#'
collections <- function(incl_extents = FALSE, url_only = FALSE) {

  collection_list <- geomet_ogc_api(
    format = "json",
    url_only = url_only,
    flatten = TRUE
  )

  # Section 7.13. Feature Collections
  # returns:
  #   - `links`
  #   - `collections`
  # ref: <https://docs.ogc.org/is/17-069r3/17-069r3.html#_collections_>

  feature_collections <- tibble::tibble(
    collection_id = collection_list[["collections"]][["id"]],
    title = collection_list[["collections"]][["title"]],
    description = collection_list[["collections"]][["description"]]
  )

  if (incl_extents) {

    ## links ----

    links <- collection_list[["collections"]][["links"]] |>
      dplyr::bind_rows(.id = "row_id") |>
      dplyr::mutate(row_id = as.integer(.data[["row_id"]])) |>
      dplyr::filter(is.na(.data[["hreflang"]]) | .data[["hreflang"]] == "en-CA") |>
      dplyr::arrange(.data[["row_id"]], .data[["rel"]], .data[["type"]]) |>
      dplyr::select(-.data[["hreflang"]]) |>
      tidyr::nest(links = c("type", "rel", "title", "href")) |>
      dplyr::select(-.data[["row_id"]])


    ## collections ----

    # spatial extent
    extent_spatial <- purrr::map_dfr(
      collection_list[["collections"]][["extent"]][["spatial"]][["bbox"]],
      ~tibble::as_tibble_row(.x[1,], .name_repair = ~c("xmin", "ymin", "xmax", "ymax"))
    ) |>
      dplyr::mutate(row_id = dplyr::row_number()) |>
      dplyr::arrange(.data[["row_id"]]) |>
      tidyr::nest(bbox = c("xmin", "ymin", "xmax", "ymax")) |>
      dplyr::select(-.data[["row_id"]])

    # temporal extent
    extent_temporal <- collection_list[["collections"]][["extent"]][["temporal"]] |>
      dplyr::mutate(
        row_id = dplyr::row_number(),
        invalid = purrr::map_lgl(.data[["interval"]], ~!is.null(.x))
      ) |>
      dplyr::filter(.data[["invalid"]]) |>
      dplyr::mutate(
        start_date = purrr::map(
          .data[["interval"]],
          ~stringr::str_extract_all(.x[1, 1], "\\d{4}-\\d{2}-\\d{2}", simplify = T)[,1]
        ),
        end_date = purrr::map(
          .data[["interval"]],
          ~stringr::str_extract_all(.x[1, 2], "\\d{4}-\\d{2}-\\d{2}", simplify = T)[,1]
        )
      ) |>
      dplyr::transmute(
        .data[["row_id"]],
        .data[["start_date"]],
        .data[["end_date"]]
      ) |>
      tidyr::unnest(cols = c(.data[["start_date"]], .data[["end_date"]])) |>
      tidyr::complete(row_id = seq.int(1L, nrow(extent_spatial))) |>
      dplyr::arrange(.data[["row_id"]]) |>
      tidyr::nest(interval = c("start_date", "end_date")) |>
      dplyr::select(-.data[["row_id"]])


    # combine ----

    feature_collections |>
      dplyr::bind_cols(extent_spatial, extent_temporal, links)

  } else {
    feature_collections

  }

}


#' Get Collection
#'
#' Get collection from the [MSC GeoMet OGC API](https://api.weather.gc.ca/) `/collections/{collection_id}` endpoint.
#'
#' @param collection_id A character string. Unique collection identifier. Run [collections()] to get a list of valid options.
#' @param use_tidy A logical scalar. Should API response be tidied? Defaults to `TRUE`.
#'
#' @return A data frame of available collections, including unique identifier (`collection_id`), title and description.
#' @export
#'
#' @examples
#' \dontrun{
#' get_collection("climate-stations")
#'}
get_collection <- function(collection_id, use_tidy = TRUE) {

  # construct api request and handle response ----
  collection_list <- geomet_ogc_api(
    collection_id = collection_id,
    items = "items",
    format = "json",
    flatten = TRUE
  )

  if (use_tidy) {

    switch(
      collection_id,
      "climate-stations" = tidy_climate_stations(collection_list)
    )

  } else {
    collection_list

  }

}


# Tidiers -------------------------------------------------------------

tidy_climate_stations <- function(collection_list) {

  climate_stations_properties <- c(
    "STN_ID"                   = "station_id",
    "STATION_NAME"             = "station_name",
    "PROV_STATE_TERR_CODE"     = "prov",
    "ENG_PROV_NAME"            = "en_prov",
    "FRE_PROV_NAME"            = "fr_prov",
    "COUNTRY"                  = "country",
    "LATITUDE"                 = "lat",
    "LONGITUDE"                = "lon",
    "TIMEZONE"                 = "tz",
    "ELEVATION"                = "elev",
    "CLIMATE_IDENTIFIER"       = "climate_id",
    "TC_IDENTIFIER"            = "tc_id",
    "WMO_IDENTIFIER"           = "wmo_id",
    "STATION_TYPE"             = "station_type",
    "NORMAL_CODE"              = "normals_code",
    "PUBLICATION_CODE"         = "pub_code",
    "DISPLAY_CODE"             = "display_code",
    "ENG_STN_OPERATOR_ACRONYM" = "station_operator_abbr",
    "FRE_STN_OPERATOR_ACRONYM" = "fr_station_operator_abbr",
    "ENG_STN_OPERATOR_NAME"    = "station_operator",
    "FRE_STN_OPERATOR_NAME"    = "fr_station_operator",
    "DLY_FIRST_DATE"           = "dly_start_date",
    "DLY_LAST_DATE"            = "dly_end_date",
    "FIRST_DATE"               = "start_date",
    "LAST_DATE"                = "end_date",
    "HAS_MONTHLY_SUMMARY"      = "mly_summary",
    "HAS_NORMALS_DATA"         = "normals"
  )

  climate_stations <- collection_list[["features"]]

  climate_stations[["properties"]] |>
    tibble::as_tibble() |>
    dplyr::rename_with(~stringr::str_replace_all(.x, climate_stations_properties)) |>
    dplyr::transmute(
      .data[["prov"]],
      .data[["station_name"]],
      .data[["station_id"]],
      .data[["climate_id"]],
      .data[["wmo_id"]],
      .data[["tc_id"]],
      lon = purrr::map_dbl(climate_stations[["geometry"]][["coordinates"]], ~.x[1]),
      lat = purrr::map_dbl(climate_stations[["geometry"]][["coordinates"]], ~.x[2]),
      elev = as.numeric(.data[["elev"]]),
      .data[["tz"]],
      # interval = "",
      start_date = as.Date(.data[["start_date"]], format = "%Y-%m-%d"),
      # start_date = lubridate::ymd_hms(start_date),
      end_date = as.Date(.data[["end_date"]], format = "%Y-%m-%d"),
      # end_date = lubridate::ymd_hms(end_date),
      normals = dplyr::if_else(.data[["normals"]] == "Y", TRUE, FALSE),
      .data[["normals_code"]],
      lon_utm = .data[["lon"]],
      lat_utm = .data[["lat"]],
      .data[["station_type"]],
      .data[["station_operator"]],
      .data[["station_operator_abbr"]],
      .data[["pub_code"]],
      .data[["display_code"]],
      .data[["dly_start_date"]],
      .data[["dly_end_date"]],
      .data[["mly_summary"]]
    ) |>
    dplyr::arrange(.data[["prov"]], .data[["station_name"]])

}
