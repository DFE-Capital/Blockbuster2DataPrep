# WHILE USABLE TO GENERATE INITIAL DATA, THESE WILL BE NEEDED IN BLOCKBUSTER2
#  PACKAGE TOO, IN CASE OF USER_AMENDMENTS BY EXCEL INPUT.


# TODO
#
#' Add deterioration rates to element data
#'
#' @param element_data A dataframe containing a \code{elementid} column
#' @param deterioration_rates A dataframe containing \code{elementid},
#'  \code{ab}, \code{bc}, \code{cd} and \code{de} columns that specify the
#'   deterioration rates for each element type.
#'
#' @return A data frame with \code{ab}, \code{bc}, \code{cd} and \code{de}
#'  columns appended appropriately.
update_deterioration_rates <- function(element_data, deterioration_rates){

}

# TODO
#
#' Add repair costs to element data
#'
#' Joins the element data with the repair rates and adds columns called
#'  \code{\*.repair.cost} and \code{\*.repair.total} that specify the unit
#'   repair costs and the element specific repair totals
#'
#' @param element_data A dataframe containing a \code{elementid} column
#' @param deterioration_rates A dataframe containing \code{elementid},
#'  \code{B}, \code{C}, \code{D} and \code{E} columns that specify the
#'   repair rates for each element type.
#'
#' @return A data frame with appropriately appended columns giving unit repair
#'  costs and element specific repair costs.
updated_repair_costs <- function(element_data, repair_costs){

}
