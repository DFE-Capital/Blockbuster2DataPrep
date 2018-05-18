#TODO

#' Cleans up and removes all the edge cases and odd phenomena in the PDS data
#'
#' To see the data exploration that has resulted in the following adjustments, see
#' the sense checking cleans vignette.
#'
#' Set playing field area and windows NAs to zeroes
#'
#' Set composition NAs to ones#'
#'
#' Moves external areas into their own blocks to avoid them skewing rebuild decisions with exaggerated repair costs.
#'
# Suspended floors use different area computations depending on whether the
# block has a ground floor or not.  Assigning a placeholder elementid when this
# is the case.
#
# # identify buildings with suspended floors
# buildings.with.sus.floors <- PDS.element %>% filter(elementid == 1756) %>% pull(buildingid) %>% unique
# # identify buildings with ground floors
# buildings.with.ground.floors <- PDS.element %>% filter(elementid == 1752) %>% pull(buildingid) %>% unique
# # identify rows with sus floors where there are ground floors in same building
# buildings <- buildings.with.sus.floors[buildings.with.sus.floors %in% buildings.with.ground.floors]
#'
#' # There are a few rows where there ground_gifa is larger than gifa, which
# doesn't make sense.  In these cases, gifa is set to ground_gifa * No.of.storeys.
# This also captures where gifa is the same as ground_gifa but with more than one
# storey
#'
#'# There are blocks where the site area is smaller than the ground_gifa. I believe
# the site area does not include the gifa because there are external components.
# Therefore the site area is set to be the original site area plus the ground gifa.
#
# ind <- PDS.element$site_area_exc_field < PDS.element$ground_gifa
# ind[is.na(ind)] <- FALSE
# PDS.element$site_area_exc_field[ind] <-
#   PDS.element$ground_gifa[ind] + PDS.element$site_area_exc_field[ind]
#'
#'# There are numerous (300+) suspended floors in buildings with ground floors
# that are only single storey. These occur when there is land dropoff so some of
# the floor is suspended and some on the ground.  Repairing suspended floors is
# slightly more expensive so we will assume that all the floor is suspended in
# these cases to be conservative.
#
# # identify row index of suspended floors with 0 area
# ind <- PDS.element$elementid == 1756 & PDS.element$unit_area == 0
# # identify buildings with suspended floors with 0 area
# buildings <- PDS.element %>% filter(elementid == 1756 & unit_area == 0) %>%
#   pull(buildingid) %>% unique
# # set suspended floor area to ground gifa
# PDS.element$unit_area[ind] <- PDS.element$ground_gifa[ind]
# # identify row index of ground floors associated with 0 area suspended floors.
# ind <- PDS.element$elementid == 1752 & PDS.element$buildingid %in% buildings
# # remove ground floor rows
# PDS.element <- PDS.element[!ind, ]
#'
#' @param element_data
#'
#' @return
cleaning <- function(element_data){

  # fix data entry mistake for Kenilworth School and Sports College
  index <- which(element_data$BuildingID == 97667)
  element_data$building.GIFA[index] <- 463
  element_data$Perimeter..m.[index] <- 100
  element_data$Height..m.[index] <- 3
  element_data$Catering.Kitchen[index] <- "No"
  element_data$WindowsAndDoors[index] <- 45 # 15% of wall area is windows according to PDS report.  3 * 100 * 0.15 = 45

  element_data %>%
    # change NA playing field area and NA Windows and Doors to zero
    mutate_at(c("Playing.field.area..m2.", "WindowsAndDoors"), funs(replace(., is.na(.), 0))) %>%
    # change NA Composition to 1
    mutate_at("Composition", funs(replace(., is.na(.), 1))) %>%

}

#' Remove rows containing particular components
#'
#' @param data A data frame with an \code{ElementID} column
#' @param elementid A numeric vector containing the \code{ElementID} numbers of the components you wish to remove. By default this contains the elementIDs of
#' unpainted redecorations and components that do not exist, e.g. no ceiling.
#'
#' @return The data frame with the appropriate rows filtered out.
#' @export
remove_element <- function(data, elementid = c(1810, 1952, 1838, 1845, 1869, 1891, 1918, 1992, 1994)){
  data %>% filter(!ElementID %in% elementid)
}

#TODO
#' Move all external area elements into their own 'block' on a site.
#'
#' @param element_data
#'
#' @return
separate_External <- function(element_data){

}
