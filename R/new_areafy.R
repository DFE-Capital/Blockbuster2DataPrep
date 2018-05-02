
#' Add size quantification to PDS data
#'
#' @param data A dataframe that contains \code{element}, \code{sub_element},
#'  \code{elementid} and \code{composition} columns
#'
#' @return The dataframe with an added variable called \code{unit_area}
#'  which quantifies the size of the element using the appropriate formula for
#'   each component type
#'
#' @importFrom dplyr %>%
areafy3 <- function(data) {
  data %>%
    mutate(unit_area = case_when(
      element == "Roofs" ~ ground_gifa,
      # ground floors
      elementid == 1752 ~ ground_gifa,
      # sus floors with ground floor present
      elementid == 9999 ~ gifa - ground_gifa,
      element == "Floors and Stairs" ~ gifa,
      element == "Ceilings" ~ gifa,
      sub_element == "Windows and doors" ~ windows_doors,
      element == "External Walls, Windows and Doors" ~ ((block_perimeter * height) - windows_doors),
      element == "Internal Walls and Doors" ~ gifa,
      element == "Sanitary Services" ~ gifa,
      element == "Mechanical Services" ~ gifa,
      # lifts
      elementid == 1909 ~ number_lifts,
      element == "Electrical Services" ~ gifa,
      element == "Redecorations" ~ gifa,
      element == "Fixed Furniture and Fittings" ~ gifa,
      sub_element == "Boundary walls and fences" ~ boundary_length,
      # swimming pools
      elementid == 1959 ~ swimming_pool,
      elementid == 1962 ~ swimming_pool,
      # drainage
      elementid == 2002 ~ gifa,
      elementid == 2001 ~ gifa,
      element == "External Areas" ~ site_area_exc_field - ground_gifa,
      element == "Playing Fields" ~ field_area,
      TRUE ~ 0 # to catch missing things.
      ),
      unit_area = unit_area * composition
      )
}

