#' Add deterioration rates to element data
#'
#' @param element_data A dataframe containing a \code{elementid} column
#' @param deterioration_rates Either a character string contain the path to a
#'  dataframe, or a dataframe containing \code{elementid},
#'  \code{ab}, \code{bc}, \code{cd} and \code{de} columns that specify the
#'   deterioration rates for each element type.
#'
#' @return A data frame with \code{ab}, \code{bc}, \code{cd} and \code{de}
#'  columns appended appropriately.
append_deterioration_rates <- function(element_data,
                                       deterioration_rates = "./data_ext/deterioration.rates.rda"){
  if(is.character(deterioration_rates))
    deterioration_rates <- load(file.path(deterioration_rates))
  element_data %>% left_join(deterioration_rates %>%
                               select(elementid, ab, bc, cd, de),
                             by = "elementid")
}

#' Add repair costs to element data
#'
#' Joins the element data with the repair rates and adds columns called
#'  \code{\*.repair.cost} and \code{\*.repair.total} that specify the unit
#'   repair costs and the element specific repair totals
#'
#' @param element_data A dataframe containing a \code{elementid} column
#' @param deterioration_rates Either a character string containing the path to a
#'  dataframe, or a dataframe containing \code{elementid},
#'  \code{B}, \code{C}, \code{D} and \code{E} columns that specify the
#'   repair rates for each element type.
#'
#' @return A data frame with appropriately appended columns giving unit repair
#'  costs and element specific repair costs.
append_repair_costs <- function(element_data,
                                repair_costs = "./data_ext/parameter.table.rda"){
  if(is.character(repair_costs))
    repair_costs <- load(file.path(repair_costs))
  element_data %>% left_join(repair_costs %>%
                               select(elementid, B.repair.cost, C.repair.cost,
                                      D.repair.cost, E.repair.cost),
                             by = "elementid")
}
