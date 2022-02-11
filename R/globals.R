
# Global Variables ----------------------------------------------------

# utils::globalVariables(
#   c(
#     ""
#   )
# )


# Validate Inputs -----------------------------------------------------

validate_collection_id <- function(collection_id) {

  # `collection_id` must either be null or a valid character string
  rlang::is_null(collection_id) |
    rlang::is_character(collection_id, n = 1L)

  if (rlang::is_character(collection_id, n = 1L)) {
    rlang::arg_match(collection_id , c(
      "ahccd-annual",
      "ahccd-monthly",
      "ahccd-seasonal",
      "ahccd-stations",
      "ahccd-trends",
      "climate-daily",
      "climate-monthly",
      "climate-normals",
      "climate-stations",
      "hydrometric-annual-peaks",
      "hydrometric-annual-statistics",
      "hydrometric-daily-mean",
      "hydrometric-monthly-mean",
      "hydrometric-realtime",
      "hydrometric-stations",
      "ltce-precipitation",
      "ltce-snowfall",
      "ltce-stations",
      "ltce-temperature",
      "swob-realtime"
    ))

  }

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
