
#' GeoMet OGC-API
#'
#' The [OGC API - Features](https://github.com/opengeospatial/ogcapi-features)
#' (WFS 3) provides access to collections of geospatial data.
#'
#' URLs are of the form `/{collections}/{collecion_id}/items/{item_id}?{query}`
#'
#' @param flatten A logical scalar. Should JSON arrays containing only
#'   primitives (i.e. booleans, numbers, and strings) be caused to atomic
#'   vectors? Defaults to `FALSE`.
#'
#' @return NULL, an atomic vector, or list.
#' @export
#'
#' @examples
#' \dontrun{
#' geomet_collections()
#' }
geomet_collections <- function(flatten = FALSE) {

  # create a request that used the base API url
  req <- httr2::request("https://api.weather.gc.ca") |>
    httr2::req_url_path_append("collections") |>
    httr2::req_perform()

  resp <- req |>
    httr2::resp_body_json(simplifyVector = flatten)

  resp

}


#' Parse bounding box
#'
#' @param coord_vec A numeric vector of coordinates with format `c(xmin, ymin, xmax, ymax)`.
#'
#' @return A bounding box character string for use in api query.
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' bbox <- c("xmin" = -79.44, "ymin" = 43.62, "xmax" = -79.33, "ymax" = 43.68)
#' parse_bbox(bbox)
#'}
parse_bbox <- function(coord_vec) {

  paste0(
    c(
      "xmin" = coord_vec[1],
      "ymin" = coord_vec[2],
      "xmax" = coord_vec[3],
      "ymax" = coord_vec[4]
    ),
    collapse = ","
  )

}
