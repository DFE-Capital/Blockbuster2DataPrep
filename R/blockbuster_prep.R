#' Rename columns so they match the required columns for the Blockbuster package
#'
#' @param element_data
#'
#' @return The input data with renamed \code{BuildingID}, \code{ElementID} and
#'  \code{building.GIFA} columns
rename_element <- function(element_data){
  element_data %>%
    rename(BuildingID = "buildingid",
           ElementID = "elementid",
           building.GIFA = "gifa"
    )
}

#' Convert the element_data to wide format for use by Blockbuster2 package
#'
#' Changes the single \code{Grade} column to five columns of zeroes and ones called
#' \code{A}, \code{B}, \code{C}, \code{D} and \code{E} for use by the \code{Blockbuster2}
#' package
#' @param element_data
#'
#' @return The input with the new columns
widen_element <- function(element_data){
  grade_table <- data.frame(Grade = c("A", "B", "C", "D", "E"), A = c(1, 0, 0, 0, 0), B = c(0, 1, 0, 0, 0), C = c(0, 0, 1, 0, 0), D = c(0, 0, 0, 1, 0), E = c(0, 0, 0, 0, 1))
  element_data %>% left_join(grade_table)
}


#' Split the cleaned PDS data into the three tables
#'
#' This restores the original star schema. Data is split into school-level, building-level
#' and component level tables
#'
#' @param element_data
#'
#' @return A list of three data frames at school-level, building-level and
#' component-level respectively
split_element <- function(element_data){

  school <- element_data %>%
    group_by(BusinessUnitID) %>%
    slice(1) %>%
    select(BusinessUnitID, DfENo., URN, Number.of.Sites, school.GIFA,
           Number.of.Blocks, CurrentStatusDesc, School.Name,
           Site.area.excluding.playing.fields..m2., Playing.field.area..m2.,
           Boundary..m., Swimming.Pool, SurveyDate)

  building <- element_data %>%
    group_by(buildingid) %>%
    slice(1) %>%
    select(BusinessUnitID, SiteID, buildingid, DfENo., Site.Reference,
           Block.Reference, Building.Type, Listed, No.of.storeys,
           Basement.area..m2., gifa, Ground.Floor.GIFA..m2., Perimeter..m.,
           Height..m., Catering.Kitchen, No.of.Lifts, WindowsAndDoors)

  # using select(-) to remove columns rather than select as element data may include
  # additional columns for deterioration rates and building costs
  element <- element_data %>%
    select(-BusinessUnitID, -SiteID, -LA.Number, -DFE.number..ESTAB., -URN,
           -Site.Reference, -Block.Reference, -LANo, -DfENo, Building.Type,
           -Listed, -No.of.storeys, -Basement.area..m2., -gifa,
           -Ground.Floor.GIFA..m2., -Perimeter..m., -Height..m., -Catering.Kitchen,
           -No.of.Lifts, -WindowsAndDoors, -Number.of.Sites,
           -school.GIFA, -Number.of.Blocks, -CurrentStatusDesc, -School.Name,
           -DNRNumber.of.SitesDNR, -Site.area.excluding.playing.fields..m2.,
           -Playing.field.area..m2., -Boundary..m., -Swimming.Pool, -SurveyDate,
           -ground_floor_present, -unit_area)

  return(element = element, building = building, school = school)
}
