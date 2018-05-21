#' Load PDS data from csvs, clean, format, and quantify
#'
#' This utility function is used to create a cleaned dataset ready for use
#' with the \code{Blockbuster2} Deterioration Model.
#'
#' @param single_table logical.  If TRUE, the output will be a single
#' component-level table
#' @param remove_elements logical. If TRUE, the elements specified in the
#' \code{elementid} argument will be removed.
#' @param add_rates logical.  If TRUE, the deterioration rates will be included
#' in the output.
#' @param add_costs logical. If TRUE, the repair costs will be included in the
#' output.
#' @inheritParams read_PDS_csv
#' @inheritParams append_deterioration_rates
#' @inheritParams append_repair_costs
#' @inheritParams remove_element
#'
#' @return The default behaviours is to produce a list of three tables (school-level,
#' building-level and component-level) containing all elements from the PDS data, with columns containing the unit_area and probability of being at each grade (which will be one or zero).
#'
#' Setting \code{single_table = TRUE} will produce a single component-level table.
#'
#' Setting \code{remove_elements} will remove those components specified by elementid in the \code{elementid} argument.  This is intended to remove those 'empty' components which indicate there is nothing there, for instance unpainted decorations, or no heating.  By default these are the elements specified by the \code{elementid} argument default.
#'
#' The arguments \code{add_rates} and \code{add_costs} will cause the deterioration rates and repair costs to be added to component-level output as columns if there are set to \code{TRUE}/
#'
#' The \code{widen} argument will add a column for each grade to the component-level output.  These columns contain the proability that the component is at that grade and will be one or zero.
#'
#' @export
#' @examples
#' \dontrun{
#' create_PDS()
#'
#' # include repair costs and deterioration rates
#' create_PDS(add_rates = TRUE, add_costs = TRUE)
#'
#' # remove 'empty' elements
#' create_PDS(remove_elements = TRUE)
#'
#' # create a single table suitable for passing to the Blockbuster2 Deterioration Model using all default parameters and settings
#' input <- create_PDS(single_table = TRUE, remove_elements = TRUE, add_rates = TRUE, add_costs = TRUE)
#' Blockbuster2::Blockbuster(input)
#' }
create_PDS <- function(single_table = FALSE,
                       remove_elements = FALSE,
                       add_rates = FALSE,
                       add_costs = FALSE,
                       widen = TRUE,
                       establishment_path = "./PDS/PDS_full_establishment.csv",
                       establishment_sep = "\t",
                       building_path = "./PDS/PDS_full_building.csv",
                       building_sep = ",",
                       condition_path = "./PDS/PDS_full_condition.csv",
                       condition_sep = "\t",
                       repair_costs = "./data_ext/parameter.table.rda",
                       deterioration_rates = "./data_ext/deterioration.rates.rda",
                       elementid = c(1810, 1952, 1838, 1845, 1869, 1891, 1918, 1992, 1994)
                       ){
  # load PDS data (from csv or from SQL, depending on arguments)
  data <- read_PDS_csv(establishment_path = establishment_path,
                       establishment_sep = establishment_sep,
                       building_path = building_path,
                       building_sep = building_sep,
                       condition_path = condition_path,
                       condition_sep = condition_sep) %>%
    # clean PDS data
    clean_PDS() %>%
    # combine data using create_Element
    create_element() %>%
    # remove unwanted elements
    when(
      remove_elements ~ remove_element(., elementid = elementid)
    ) %>%
    # clean element level data
    clean_element() %>%
    # fix data types
    format_element() %>%
    # format column names ready for Blockbuster
    rename_element() %>%
    # add area to element level data
    areafy() %>%
    # add deterioration rates
    when(
      add_rates ~ append_deterioration_rates(., deterioration_rates = deterioration_rates)
    ) %>%
    # add repair costs
    when(
      add_costs ~ append_repair_costs(., repair_costs = repair_costs)
    ) %>%
    # put into wide format for blockbuster 2 package
    widen ~ widen_element(.) %>%
    # split into three files
    when(
      single_table == FALSE ~ split_element(.)
    )
}
