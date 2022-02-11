
#' Collections
#'
#' List of available collections from the [MSC GeoMet OGC API](https://api.weather.gc.ca/) `/collections` endpoint.
#'
#' @return A data frame of available collections, including unique identifier
#' (`collection_id`), title and description.
#' @export
#'
#' @examples
#' collection_ids()
#'
collection_ids <- function() {

  collection_list <- geomet_ogc_api(format = "json", flatten = TRUE)

  tibble::tibble(
    collection_id = collection_list[["collections"]][["id"]],
    title = collection_list[["collections"]][["title"]],
    description = collection_list[["collections"]][["description"]]
  )

}


#' Get Collection
#'
#' Get collection from the [MSC GeoMet OGC API](https://api.weather.gc.ca/) `/collections/{collection_id}` endpoint.
#'
#' @param collection_id A character string. Unique collection identifier. Run [collection_ids()] to get a list of valid options.
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
