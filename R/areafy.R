
#' Add size quantification to PDS data
#'
#' @param data A dataframe that contains \code{Element}, \code{sub_Element},
#'  \code{elementid} and \code{composition} columns
#'
#' @return The dataframe with an added variable called \code{unit_area}
#'  which quantifies the size of the Element using the appropriate formula for
#'   each component type
#'
areafy <- function(data) {
  data %>% group_by(buildingid) %>%
    # add flag to indicate presence of ground floor - this is used when calculating suspended floor size
    mutate(ground_floor_present = any(Element == "Ground bearing / hollow floors - structure")) %>%
    ungroup %>%
    mutate(unit_area = case_when(
      Element == "Roofs" ~ Ground.Floor.GIFA..m2.,
      # ground floors
      Sub.element == "Ground bearing / hollow floors - structure" ~ Ground.Floor.GIFA..m2.,
      # sus floors with ground floor present
      Sub.element == "Suspended floors – Structure" & ground_floor_present ~ gifa - Ground.Floor.GIFA..m2.,
      Element == "Floors and Stairs" ~ gifa,
      Element == "Ceilings" ~ gifa,
      Sub.element == "Windows and doors" ~ WindowsAndDoors,
      Element == "External Walls, Windows and Doors" ~ ((Perimeter..m. * Height..m.) - WindowsAndDoors),
      Element == "Internal Walls and Doors" ~ gifa,
      Element == "Sanitary Services" ~ gifa,
      Element == "Mechanical Services" ~ gifa,
      # lifts
      Sub.element == "Lifts" ~ No.of.Lifts,
      Element == "Electrical Services" ~ gifa,
      Element == "Redecorations" ~ gifa,
      Element == "Fixed Furniture and Fittings" ~ gifa,
      Sub.element == "Boundary walls and fences" ~ Boundary..m.,
      # swimming pools
      Sub.element == "Swimming Pools - Plant" ~ Swimming.Pool,
      Sub.element == "Swimming Pools - Structure" ~ Swimming.Pool,
      # drainage
      Sub.element == "Drainage - Other" ~ gifa,
      Sub.element == "Drainage - Treatment plant" ~ gifa,
      Element == "External Areas" ~ Site.area.excluding.playing.fields..m2. - Ground.Floor.GIFA..m2.,
      Element == "Playing Fields" ~ Playing.field.area..m2.,
      TRUE ~ 0 # to catch missing things.
      ),
      # adjust unit_area according to component composition
      unit_area = unit_area * Composition,
      # change all negative unit_areas to zero.  Negatives arise as estimated wall size is less than estimated window size.
      unit_area = case_when(unit_area < 0 ~ 0,
                            TRUE          ~ unit_area)
      ) %>% return()
}

