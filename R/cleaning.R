#TODO

#' Cleans up and removes all the edge cases and odd phenomena in the PDS data
#'
#' Convert playing field NAs to zeroes, see \code{\link{examine_NAs}}
#'
#' Set windows NAs to zeroes, see \code{\link{examine_NAs}}
#'
#' Set composition NAs to zeroes (they are blocks with no windows, see \code{\link{examine_NAs}})
#'
#' Remove appropriate zero compositions.
#'
#' Remove "unpainted", "no wall finish" and "no ceiling" rows as they have no cost and cannot deteriorate.
#'
#' Moves external areas into their own blocks to avoid them skewing rebuild decisions with exaggerated repair costs.
#'#'
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
#' There is one block (ID 97667) with 0 storeys and height 100m. There are no external
#' components.  This is an office in a tower block somewhere.  Set height to 3m
#' so we don't get unreasonable repair costs where height matters.
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
#' @export
#'
#' @examples
cleaning <- function(element_data){

}

#TODO
#' Move all external area elements into their own 'block' on a site.
#'
#' @param element_data
#'
#' @return
#' @export
#'
#' @examples
separate_External <- function(element_data){

}
