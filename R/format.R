# TODO
#
#' Puts PDS data into appropriate format for blockbuster
#'
#' Remove extraneous space from "D" grade
#'
#' Change lift formatting to numeric.
#'
#' Set swimming pool to 0 or 1 instead of yes/no
#'
#' @param element_data
#'
#' @return
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
