#' # TODO
#' #
#' #' Queries the SQL server for the appropriate PDS data
#' #'
#' #' @examples
#' \dontrun{
#' read_PDS_SQL <- function()
#' }




#' Loads PDS data from csv files
#'
#' By default, the csv files are expected to be found in a folder called
#' \code{PDS} and be called \code{PDS_full_establishment.csv},
#' \code{PDS_full_building.csv} and \code{PDS_full_condition.csv}
#'
#' @param establishment_path character. Path to the establishment level data.
#' @param establishment_sep character. String used as column divider by the csv holding establishment data
#' @param building_path character. Path to the building level data
#' @param building_sep character. String used as column divider by the csv holding building level data
#' @param condition_path character. Path to the component level data
#' @param condition_sep character. String used as column divider by the csv holding component level data
#'
#' @return A list containing the three data frames pulled from the csv files
#' @examples
#' \dontrun{
#' # from default location
#' read_PDS_csv()
#'
#' # from user supplied location
#' read_PDS_csv("./data/est.csv", ",", "./data/build.csv", ",", "./data/comp.csv", ",")
#' }
#'
read_PDS_csv <- function(establishment_path = "./PDS/PDS_full_establishment.csv",
                         establishment_sep = "\t",
                         building_path = "./PDS/PDS_full_building.csv",
                         building_sep = ",",
                         condition_path = "./PDS/PDS_full_condition.csv",
                         condition_sep = "\t"
                         ){

  # tidy paths
  establishment_path <- file.path(establishment_path)
  buildingpath <- file.path(building_path)
  condition_path <- file.path(condition_path)

  # check files exist
  if(!file.exists(establishment_path)) stop(paste0("establishment_path: The file does not exist"))
  if(!file.exists(building_path)) stop(paste0("building_path: The file does not exist"))
  if(!file.exists(condition_path)) stop(paste0("condition_path: The file does not exist"))

  file.type <- function(string){
    x <- strsplit(string, ".", fixed = TRUE)
    x[[1]][length(x[[1]])]
  }

  if(file.type(establishment_path) != "csv") stop(paste0("establishment_path: The file is not a csv file"))
  if(file.type(building_path) != "csv") stop(paste0("building_path: The file is not a csv file"))
  if(file.type(condition_path) != "csv") stop(paste0("condition_path: The file is not a csv file"))

  establishment <- read.csv(establishment_path, sep = establishment_sep, stringsAsFactors = FALSE)
  if(ncol(establishment) == 1) stop("establishment_path: The file contains only one column. Have you specified the column divider correctly?")
  building <- read.csv(building_path, sep = building_sep, stringsAsFactors = FALSE)
  if(ncol(building) == 1) stop("building_path: The file contains only one column. Have you specified the column divider correctly?")
  condition <- read.csv(condition_path, sep = condition_sep, stringsAsFactors = FALSE)
  if(ncol(condition) == 1) stop("condition_path: The file contains only one column. Have you specified the column divider correctly?")

  return(list(establishment = establishment, building = building, condition = condition))

}

#' Clean inconsistencies between PDS files before joining
#'
#' This function removes and amends rows of the PDS data as necessary.  The file
#' \code{data_cleaning.Rmd} details the full discovery and cleaning process that
#' lead to these amendments.
#'
#' This should be run before using \code{\link{create_Element}} to join the three data files
#'
#' @param PDS The output from \code{\link{read_PDS_csv}} or \code{\link{read_PDS_SQL}}
#'
#' @return The cleaned data
clean_PDS <- function(PDS){
  # remove row of building containing just a business id that is not duplicated elsewhere, and no other data
  PDS$building <- PDS$building %>% filter(BusinessUnitID != 15)

  # remove site which only contained no components (demolished buildings with external area attached to other blocks)
  PDS$building <- PDS$building %>% filter(SiteID != 5132)

  # remove buildings with no components (demolished or mistaken buildings)
  PDS$building <- PDS$building %>%
    filter(!BuildingID %in% c(101047, 126145, 126170, 126185, 126542, 77318, 79394, 97996, 97997))

  # Relabel 08-Library,Office and Ent in condition file so it matches building label
  PDS$condition <- PDS$condition %>%
    mutate(Block.Reference = case_when(
      .data$Site.Reference == 5029 & Block.Reference == "08-Library, Offices & Ent" ~ "08-Library",
    TRUE ~ Block.Reference))

  # Rename GIFA to avoid confusion
  PDS$building <- PDS$building %>% rename(building.GIFA = Gross.internal.floor.area..m2.)
  PDS$establishment <- PDS$establishment %>% rename(school.GIFA = Gross.internal.floor.area..m2.)

  # update number of sites, blocks and gifa for establishments by summarising blocks
  PDS$establishment <- PDS$building %>% group_by(BusinessUnitID) %>%
    summarise(new.school.GIFA = sum(building.GIFA),
              new.no.of.block = n()
              ) %>%
    right_join(PDS$establishment) %>%
    select(-school.GIFA, -Number.of.Blocks) %>%
    rename(school.GIFA = new.school.GIFA,
           Number.of.Blocks = new.no.of.block)

  PDS$establishment <- PDS$building %>% group_by(BusinessUnitID, SiteID) %>%
    summarise(dur = n()) %>%
    group_by(BusinessUnitID) %>%
    summarise(new.no.of.sites = n()) %>%
    right_join(PDS$establishment) %>% select(-Number.of.Sites) %>%
    rename(Number.of.Sites = new.no.of.sites)



    return(list(establishment = PDS$establishment, building = PDS$building,
                condition = PDS$condition))
}


#' Combine the three PDS data files into an element level summary
#'
#' Joins the files read in by \code{\link{read_PDS_csv}} into one element level summary
#' @param data The output from \code{\link{read_PDS_csv}} or \code{\link{read_PDS_SQL}}.
#'
#' @return data.frame The three PDS data files joined into one component-level data.frame.
create_Element <- function(data){
  data$condition %>%
    full_join(data$building) %>%
    full_join(data$establishment)


}




remove_duplicate_columns <- function(data){

}
