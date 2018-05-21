#' Cleans up and removes all the edge cases and odd phenomena in the PDS data
#'
#' To see the data exploration that has resulted in the following adjustments, see
#' the sense checking cleans vignette.
#'
#' Set playing field area and windows NAs to zeroes.
#'
#' Set composition NAs to zero
#'
#' Moves external areas into their own blocks to avoid them skewing rebuild
#' decisions with exaggerated repair costs.
#'
#' Set external area blocks GIFA to zero
#'
#' @param element_data
#'
#' @return The cleaned input.
clean_element <- function(element_data){

  # fix data entry mistake for Kenilworth School and Sports College
  index <- which(element_data$BuildingID == 97667)
  element_data$building.GIFA[index] <- 463
  element_data$Perimeter..m.[index] <- 100
  element_data$Height..m.[index] <- 3
  element_data$Catering.Kitchen[index] <- "No"
  element_data$WindowsAndDoors[index] <- 45 # 15% of wall area is windows according to PDS report.  3 * 100 * 0.15 = 45

  element_data %>%
    # change NA playing field area and NA Windows and Doors and NA Composition to zero
    mutate_at(c("Playing.field.area..m2.", "WindowsAndDoors", "Composition"), funs(replace(., is.na(.), 0))) %>%
    # place external areas in their own building
    mutate(BuildingID = case_when(Element == "External Areas" ~ BuildingID + 9000000,
                                  TRUE                        ~ as.numeric(BuildingID)),
           # set external area blocks GIFA to zero
           building.GIFA = case_when(BuildingID > 9000000 ~ 0,
                                     TRUE                 ~ building.GIFA))
}

#' Remove rows containing particular components
#'
#' @param data A data frame with an \code{ElementID} column
#' @param elementid A numeric vector containing the \code{ElementID} numbers of the components you wish to remove. By default this contains the elementIDs of
#' unpainted redecorations and components that do not exist, e.g. no ceiling.
#'
#' @return The data frame with the appropriate rows filtered out.
remove_element <- function(data, elementid = c(1810, 1952, 1838, 1845, 1869, 1891, 1918, 1992, 1994)){
  data %>% filter(!ElementID %in% elementid)
}
