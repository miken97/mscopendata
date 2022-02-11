
#' MSC GeoMet OGC-API Core Request Function
#'
#' The [OGC API - Features](https://github.com/opengeospatial/ogcapi-features) (WFS 3) provides access to collections of geospatial data.
#' URLs are of the form: `https://api.weather.gc.ca/collections/{collecion_id}/items/{item_id}?{query}`.
#'
#' @param collection_id A character string. Appends URL path. Unique feature collection identifier. Run [collection_ids()] to get a list of valid options. If `NULL` (default), a list of all available collections from the [MSC GeoMet OGC API](https://api.weather.gc.ca/) `/collections` endpoint.
#' @param items A character string. Appends URL path. Set to `"items"` to return feature collection features. Defaults to `NULL`.
#' @param feature_id A character string. Appends URL path. Unique local identifier of the feature. Defaults to `NULL`.
#' @param format A character string. Appends URL query. API response format. One of `"json"`, `"jsonld"` or `"html"`. Defaults to `"json"`.
#' @param bbox A character string. Appends URL query. Spatial extent to query. Defaults to `NULL`.
#' @param properties A character string. Appends URL query. Defaults to `NULL`.
#' @param ... Name-value pairs that provide query parameters. Appends URL query. See [httr2::req_url_query()].
#' @param url_only A logical scalar. If `TRUE`, request URL is returned without making GET request to API. Defaults to `FALSE`.
#' @param flatten A logical scalar. Should JSON arrays containing only primitives (i.e. booleans, numbers, and strings) be caused to atomic vectors? Defaults to `FALSE`.
#'
#' @return NULL, an atomic vector, or list.
#' @export
#'
#' @examples
#' \dontrun{
#' geomet_ogc_api()
#' }
geomet_ogc_api <- function(collection_id = NULL, items = NULL, feature_id = NULL,
                           format = "json", bbox = NULL, properties = NULL, ...,
                           url_only = FALSE, flatten = FALSE) {

  # validate inputs ----
  validate_collection_id(collection_id)
  rlang::arg_match(format, c("json", "jsonld", "html"))
  rlang::is_logical(url_only, n = 1L)


  # handle inputs ----

  query_params <- list(
    ...,
    "f" = format,
    "limit" = 10000L,
    "bbox" = NULL,
    "properties" = NULL
  )


  # construct api request url ----
  api_req <- httr2::request("https://api.weather.gc.ca") |>
    httr2::req_url_path_append("collections", collection_id, items) |>
    httr2::req_url_query(!!!query_params)

  if (url_only) {
    return(api_req)

  }

  # make api request; handle response ----
  # api_resp
  api_req |>
    httr2::req_perform()|>
    httr2::resp_body_json(simplifyVector = flatten)

}
