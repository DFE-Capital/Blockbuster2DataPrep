## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, eval = FALSE)
library(Blockbuster2DataPrep)
library(dplyr)

## ---- results = 'hide'---------------------------------------------------
#  PDS_single <- create_PDS(single_table = TRUE, remove_elements = TRUE, add_rates = TRUE, add_costs = TRUE)
#  save(PDS_single, file = "./data/PDS_single.rda")

## ---- results = 'hide'---------------------------------------------------
#  PDS_excel <- create_PDS()
#  PDS_excel_element <- PDS_excel$element
#  # just the element level
#  save(PDS_excel_element, file = "./data/PDS_excel_element.rda")
#  # all data
#  save(PDS_excel, file = "./data/PDS_excel.rda")

## ----data, cache = TRUE--------------------------------------------------
#  # load the files
#  data_files <- read_PDS_csv()

## ------------------------------------------------------------------------
#  # show building row with no data
#  data_files$building %>% filter(BusinessUnitID == 15)
#  #remove row
#  data_files$building <- data_files$building %>% filter(BusinessUnitID != 15)

## ------------------------------------------------------------------------
#  # These should all return TRUE, i.e. there are no mismatches
#  
#  # compare building data and establishment
#  setequal(data_files$building$BusinessUnitID, data_files$establishment$BusinessUnitID)
#  setequal(data_files$building$URN, data_files$establishment$URN)
#  
#  # compare condition data and establishment
#  setequal(data_files$establishment$BusinessUnitID, data_files$condition$BusinessUnitID)
#  setequal(data_files$condition$URN, data_files$establishment$URN)
#  
#  {
#    est_LADFE <- data_files$establishment %>%
#      mutate(LADFE = paste(.data$LA.Number, .data$DFE.number..ESTAB.)) %>% pull(LADFE)
#    con_LADFE <- data_files$condition %>%
#      mutate(LADFE = paste(.data$LA.Number, .data$DFE.number..ESTAB.)) %>% pull(LADFE)
#    setequal(est_LADFE, con_LADFE)
#    }
#  
#  # compare condition and building
#  setequal(data_files$condition$BusinessUnitID, data_files$building$BusinessUnitID)
#  setequal(data_files$condition$SiteID, data_files$building$SiteID)

## ------------------------------------------------------------------------
#  #SiteID
#  setdiff(
#    union(data_files$building$SiteID, data_files$condition$SiteID),
#    intersect(data_files$building$SiteID, data_files$condition$SiteID)
#  )

## ------------------------------------------------------------------------
#  # remove site 5132
#  data_files$building <- data_files$building %>% filter(SiteID != 5132)

## ------------------------------------------------------------------------
#  # continuing to compare condition and building
#  setequal(data_files$condition$SiteID, data_files$building$SiteID)
#  setequal(data_files$condition$URN, data_files$building$URN)
#  setequal(data_files$condition$Site.Reference, data_files$building$Site.Reference)
#  setequal(data_files$condition$BuildingID, data_files$building$BuildingID)

## ------------------------------------------------------------------------
#  missing_buildings <- setdiff(
#    union(data_files$building$BuildingID, data_files$condition$BuildingID),
#    intersect(data_files$building$BuildingID, data_files$condition$BuildingID)
#  )
#  
#  missing_buildings

## ------------------------------------------------------------------------
#  URNS <- data_files$building %>% filter(BuildingID %in% missing_buildings) %>% pull(URN)
#  data_files$establishment %>% filter(URN %in% URNS)

## ------------------------------------------------------------------------
#  data_files$building <- data_files$building %>% filter(!BuildingID %in% missing_buildings)

## ------------------------------------------------------------------------
#  setequal(data_files$condition$BuildingID, data_files$building$BuildingID)

## ------------------------------------------------------------------------
#  
#  # continuing to compare condition and building
#  {
#    con_block <- data_files$condition %>%
#      mutate(block = paste(.data$Site.Reference, .data$Block.Reference)) %>%
#      pull(block)
#    build_block <- data_files$building %>%
#      mutate(block = paste(.data$Site.Reference, .data$Block.Reference)) %>%
#      pull(block)
#    setequal(con_block, build_block)
#  }

## ------------------------------------------------------------------------
#  full_join(data_files$condition %>% filter(Site.Reference == 5029),
#            data_files$building %>% filter(Site.Reference == 5029),
#            by = "BuildingID") %>%
#    select(Site.Reference.x, Site.Reference.y, Block.Reference.x, Block.Reference.y)

## ------------------------------------------------------------------------
#  # Relabel 08-Library,Office and Ent in condition file
#  data_files$condition <- data_files$condition %>% mutate(Block.Reference = case_when(
#    .data$Site.Reference == 5029 & Block.Reference == "08-Library, Offices & Ent" ~ "08-Library",
#    TRUE ~ Block.Reference
#  ))

## ------------------------------------------------------------------------
#  {
#    con_block <- data_files$condition %>%
#      mutate(block = paste(.data$Site.Reference, .data$Block.Reference)) %>%
#      pull(block)
#    build_block <- data_files$building %>%
#      mutate(block = paste(.data$Site.Reference, .data$Block.Reference)) %>%
#      pull(block)
#    setdiff(con_block, build_block) %>%
#    length %>% `==`(0)
#  }

## ------------------------------------------------------------------------
#  data_files$building %>%
#    group_by(URN) %>% summarise(gifa = sum(Gross.internal.floor.area..m2.)) %>%
#    full_join(data_files$establishment, by = "URN") %>%
#    mutate(match = isTRUE(all.equal(.data$Gross.internal.floor.area..m2., .data$gifa, tolerance = 1))) %>%
#    filter(!match) %>% select(gifa, Gross.internal.floor.area..m2.)

## ------------------------------------------------------------------------
#  data_files$building <- data_files$building %>% rename(building.GIFA = Gross.internal.floor.area..m2.)
#  data_files$establishment <- data_files$establishment %>% rename(school.GIFA = Gross.internal.floor.area..m2.)

## ------------------------------------------------------------------------
#  # replace gifa and number of blocks in establishment data with newly computed values from building data
#  data_files$establishment <- data_files$building %>% group_by(BusinessUnitID) %>%
#      summarise(new.school.GIFA = sum(building.GIFA),
#                new.no.of.block = n()
#                ) %>%
#      right_join(data_files$establishment) %>%
#      select(-school.GIFA, -Number.of.Blocks) %>%
#      rename(school.GIFA = new.school.GIFA,
#             Number.of.Blocks = new.no.of.block)
#  
#  
#  # replace number of sites in establishment data with correct value computed from building data
#  data_files$establishment <- data_files$building %>% group_by(BusinessUnitID, SiteID) %>%
#      summarise(new.no.of.sites = n()) %>%
#      group_by(BusinessUnitID) %>%
#      summarise(new.no.of.sites = n()) %>%
#      right_join(data_files$establishment) %>% select(-Number.of.Sites) %>%
#      rename(Number.of.Sites = new.no.of.sites)
#  
#  

## ------------------------------------------------------------------------
#  element_data <- create_element(data_files)

## ------------------------------------------------------------------------
#  element_data %>% filter(is.na(Playing.field.area..m2.)) %>% nrow
#  element_data %>% filter(is.na(Playing.field.area..m2.), Element == "Playing Fields")

## ------------------------------------------------------------------------
#  element_data %>% filter(is.na(WindowsAndDoors), Sub.element == "Windows and doors" )

## ------------------------------------------------------------------------
#  index <- which(element_data$BuildingID == 97667)
#  element_data$building.GIFA[index] <- 463
#  element_data$Perimeter..m.[index] <- 100
#  element_data$Height..m.[index] <- 3
#  element_data$Catering.Kitchen[index] <- "No"
#  element_data$WindowsAndDoors[index] <- 45 # 15% of wall area is windows according to PDS report.  3 * 100 * 0.15 = 45

## ------------------------------------------------------------------------
#  element_data <- element_data %>% mutate_at(c("Playing.field.area..m2.", "WindowsAndDoors"), funs(replace(., is.na(.), 0)))

## ------------------------------------------------------------------------
#  element_data %>% filter(is.na(Composition), Grade != "A")

## ------------------------------------------------------------------------
#  element_data <- element_data %>% mutate_at("Composition", funs(replace(., is.na(.), 0)))

## ------------------------------------------------------------------------
#  element_data <- element_data %>% mutate(BuildingID = case_when(Element == "External Areas" ~ BuildingID + 9000000,
#                                                                 TRUE                        ~ as.numeric(BuildingID)))

## ------------------------------------------------------------------------
#  element_data <- element_data %>% mutate(Swimming.Pool = case_when(Swimming.Pool == "Yes" ~ 1,
#                                                    Swimming.Pool == "No"  ~ 0),
#                          No.of.Lifts = case_when(No.of.Lifts == "1.000" ~ 1,
#                                                  No.of.Lifts == "2.000" ~ 2,
#                                                  No.of.Lifts == "3.000" ~ 3,
#                                                  No.of.Lifts == "4.000" ~ 4,
#                                                  No.of.Lifts == "5.000" ~ 5,
#                                                  No.of.Lifts == "6.000" ~ 6,
#                                                  TRUE                   ~ 0))
#  

## ----areafy, results = 'hide', cache = TRUE------------------------------
#  # invisible is used to stop printing the output to console which will cause problems due to the size of the datatable
#  element_data <- invisible(element_data %>% areafy)

## ------------------------------------------------------------------------
#  element_data <- element_data %>%
#    rename_element

## ------------------------------------------------------------------------
#  element_data %>% group_by(Element, Sub.element, Construction.Type) %>% slice(1) %>% select(ElementID, Element, Sub.element, Construction.Type)

