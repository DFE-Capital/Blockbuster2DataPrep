#' Corrects certain data types in preparation for the areafy function
#'
#' This function needs to be called before \code{\link{areafy}}.  It corrects
#' some data types so \code{\link{areafy}} can correctly quantify some components.
#' It removes the extraneous space from the "D" \code{grade} entries. It changes
#' the `Swimming.Pool` from a yes no to a 0 or 1. It formats the `No.of.Lifts`
#' column to be numeric.
#' @param element_data
#'
#' @return The input with re-formatted columns.
format_element <- function(element_data){
  element_data %>% mutate(
    Grade = case_when(Grade == "D " ~ "D",
                      TRUE          ~ Grade),
    Swimming.Pool = case_when(Swimming.Pool == "Yes" ~ 1,
                              Swimming.Pool == "No"  ~ 0),
    No.of.Lifts = case_when(No.of.Lifts == "1.000" ~ 1,
                            No.of.Lifts == "2.000" ~ 2,
                            No.of.Lifts == "3.000" ~ 3,
                            No.of.Lifts == "4.000" ~ 4,
                            No.of.Lifts == "5.000" ~ 5,
                            No.of.Lifts == "6.000" ~ 6,
                            TRUE                   ~ 0))
}


