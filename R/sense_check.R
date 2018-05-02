#TODO

#' Sense check NAs by looking at them before cleaning
#'
#' @param elementid
#'
#' @return
examine_NAs <- function(data, column){
  column <- enquo(column)
  data %>% filter(is.na(!!column))
}


#' Sense check duplicated rows by looking at them before cleaning
#'
#' @param element
#'
#' @return
examine_duplicates <- function(element){


}

#' Sense check rows with zero composition.
#'
#' Should be run before setting NA compositions to zero.
#'
#' @param element
#'
#' @return
examine_zero_composition <- function(element){

}


#' Sense check columns which are in two files but do not match
#'
#' @param data
#'
#' @return
examine_duplicate_column_differences <- function(data){
  # identify pairs

  # identify mismatches

  # return mismatches in list



}

