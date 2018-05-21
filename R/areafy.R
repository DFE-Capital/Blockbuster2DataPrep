
#' Add size quantification to PDS data
#'
#' @param data A dataframe that contains \code{Element}, \code{sub_Element},
#'  \code{ElementID} and \code{composition} columns
#'
#' @return The dataframe with an added variable called \code{unit_area}
#'  which quantifies the size of the Element using the appropriate formula for
#'   each component type
#'
areafy <- function(data) {
  data %>% group_by(BuildingID) %>%
    # add flag to indicate presence of ground floor - this is used when calculating suspended floor size
    mutate(ground_floor_present = any(Element == "Ground bearing / hollow floors - structure")) %>%
    ungroup %>%
    mutate(unit_area = case_when(
      Element == "Roofs" ~ Ground.Floor.GIFA..m2.,
      # ground floors
      Sub.element == "Ground bearing / hollow floors - structure" ~ Ground.Floor.GIFA..m2.,
      # sus floors with ground floor present
      Sub.element == "Suspended floors – Structure" & ground_floor_present ~ building.GIFA - Ground.Floor.GIFA..m2.,
      Element == "Floors and Stairs" ~ building.GIFA,
      Element == "Ceilings" ~ building.GIFA,
      Sub.element == "Windows and doors" ~ WindowsAndDoors,
      Element == "External Walls, Windows and Doors" ~ ((Perimeter..m. * Height..m.) - WindowsAndDoors),
      Element == "Internal Walls and Doors" ~ building.GIFA,
      Element == "Sanitary Services" ~ building.GIFA,
      Element == "Mechanical Services" ~ building.GIFA,
      # lifts
      Sub.element == "Lifts" ~ No.of.Lifts,
      Element == "Electrical Services" ~ building.GIFA,
      Element == "Redecorations" ~ building.GIFA,
      Element == "Fixed Furniture and Fittings" ~ building.GIFA,
      Sub.element == "Boundary walls and fences" ~ Boundary..m.,
      # swimming pools
      Sub.element == "Swimming Pools - Plant" ~ Swimming.Pool,
      Sub.element == "Swimming Pools - Structure" ~ Swimming.Pool,
      # drainage
      Sub.element == "Drainage - Other" ~ building.GIFA,
      Sub.element == "Drainage - Treatment plant" ~ building.GIFA,
      Element == "External Areas" ~ Site.area.excluding.playing.fields..m2. - Ground.Floor.GIFA..m2.,
      Element == "Playing Fields" ~ Playing.field.area..m2.,
      TRUE ~ 0 # to catch missing things.
      ),
      unit_area = unit_area * Composition
      ) %>% return()
}

