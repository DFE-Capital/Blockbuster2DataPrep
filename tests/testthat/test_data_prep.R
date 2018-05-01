context("Testing read_PDS_csv")

test_that("Failure produces informative error message", {
  # create testfiles
  csv <- tempfile(pattern = "file1", fileext = ".csv")
  write.csv(1:10, file = csv, row.names = FALSE) # one column
  csv2 <- tempfile(pattern = "file2", fileext = ".csv")
  write.csv(matrix(1:10, ncol = 2), file = csv2) # two columns
  notcsv <- tempfile(pattern = "file", fileext = ".notcsv")
  write(1:10, file = notcsv)
  notafile <- tempfile(pattern = "file", fileext = ".tmp")
  write(1:10, file = notafile)
  file.remove(notafile)

  expect_error(read_PDS_csv(establishment_path = notafile),
               paste0("establishment_path: The file does not exist"))
  expect_error(read_PDS_csv(establishment_path = csv, building_path = notafile),
               paste0("building_path: The file does not exist"))
  expect_error(read_PDS_csv(establishment_path = csv, building_path = csv, condition_path = notafile),
               paste0("condition_path: The file does not exist"))

  expect_error(read_PDS_csv(establishment_path = notcsv),
               paste0("establishment_path: The file is not a csv file"))
  expect_error(read_PDS_csv(establishment_path = csv, building_path = notcsv),
               paste0("building_path: The file is not a csv file"))
  expect_error(read_PDS_csv(establishment_path = csv, building_path = csv, condition_path = notcsv),
               paste0("condition_path: The file is not a csv file"))

  expect_error(read_PDS_csv(establishment_path = csv, establishment_sep = ","),
               "establishment_path: The file contains only one column. Have you specified the column divider correctly?")
  expect_error(read_PDS_csv(establishment_path = csv2, establishment_sep = ",",
                            building_path = csv, building_sep = ","),
               "building_path: The file contains only one column. Have you specified the column divider correctly?")
  expect_error(read_PDS_csv(establishment_path = csv2, establishment_sep = ",",
                            building_path = csv2, building_sep = ",",
                            condition_path = csv, condition_sep = ","),
               "condition_path: The file contains only one column. Have you specified the column divider correctly?")

  file.remove(csv)
  file.remove(csv2)
  file.remove(notcsv)
})

test_that("successfully pulls files from default path", {
  if(!file.exists("C:/Users/PCURTIS/OneDrive - Department for Education/Documents/Projects/Blockbuster Model Resources/Data cleaning/data_ext/PDS_full_establishment.csv"))
    skip("Testing not being run on local machine")

  expect_failure(expect_error(read_PDS_csv()))

})

test_that("output contains the correct three objects", {
  test <- read_PDS_csv()
  expect_equal(names(test), c("establishment", "building", "condition"))
})

context("Testing create_Element")

test_that("Output should not be larger than the component level input", {
  test <- list(condition = data.frame(BuildingID = 1:10, SiteID = 1:10,
                                      BusinessUnitID  = 1:10, URN = 1:10,
                                      Site.Reference = 1:10,
                                      Block.Reference = 1:10),
               establishment = data.frame(URN = 1:2, est.val = 1:2),
               building = data.frame(BuildingID = 1:6, SiteID = 1:6,
                                     BusinessUnitID  = 1:6, URN = 1:6,
                                     Site.Reference = 1:6,
                                     Block.Reference = 1:6, buil.val = 1:6))

  expect_equal(nrow(create_Element(test)), nrow(test$condition))
  })



context("Testing create_PDS")

test_that("create_PDS loads PDS data", {
  # check this by looking for specific rows in output
  expect_equal(create_PDS %>% filter(elementid == 1846, buildingid == 104111) %>% nrow, 1)
  expect_equal(create_PDS %>% filter(elementid == 1713, buildingid == 99653) %>% nrow, 1)
  expect_equal(create_PDS %>% filter(elementid == 1972, buildingid == 60423) %>% nrow, 1)
  expect_equal(create_PDS %>% filter(elementid == 1996, buildingid == 83378) %>% nrow, 1)
  expect_equal(create_PDS %>% filter(elementid == 1950, buildingid == 123305) %>% nrow, 1)

})

test_that("selected PDS data is present with correct values in output", {
  # look at specific rows that should exist
  example1 <- data.frame(elementid = 1846, buildingid = 104111, A = 0, B = 1, C = 0, D = 0, E = 0,
                         unit_area = 244 * 6)
  # unit area is building height of 6 times block perimeter 244 times
  #  composition 1 as element 1846 is external wall - interior finish.
  example2 <- data.frame(elementid = 1713, buildingid = 99653, A = 1, B = 0, C = 0, D = 0, E = 0,
                         unit_area = 781 * 0.1)
  # unit area is ground gifa 781 times composition 0.1 as element 1713 is drainage
  example3 <- data.frame(elementid = 1972, buildingid = 60423, A = 0, B = 0, C = 1, D = 0, E = 0,
                         unit_area = 93*0.95)
  # unit area is gifa 93 times composition 0.95 as element 1972 is a roof
  example4 <- data.frame(elementid = 1996, buildingid = 83378, A = 0, B = 1, C = 0, D = 0, E = 0,
                         unit_area = 116)
  # unit area is gifa times composition 1 as element 1996 is redecorations
  example5 <- data.frame(elementid = 1950, buildingid = 123305, A = 0, B = 1, C = 0, D = 0, E = 0,
                         unit_area = 676 * 0.5)
  # unit area is boundary 676 times composition 0.5 as element 1950 is a boundary wall

  expect_equal(create_PDS() %>% filter(elementid == 1846, buildingid == 104111),
               example1)
  expect_equal(create_PDS() %>% filter(elementid == 1713, buildingid == 99653),
               example2)
  expect_equal(create_PDS() %>% filter(elementid == 1972, buildingid == 60423),
               example3)
  expect_equal(create_PDS() %>% filter(elementid == 1996, buildingid == 83378),
               example4)
  expect_equal(create_PDS() %>% filter(elementid == 1950, buildingid == 123305),
               example5)
})

test_that("create_PDS gives informative error if PDS data not loaded")

test_that("create_PDS output has combined all three files correctly")

test_that("create_PDS output is cleaned")

test_that("create_PDS output contains unit_area column")

test_that("repair costs and deterioration rates are added to create_PDS output")

test_that("create_PDS output has correct columns and formats for Blockbuster2")

# test_that("data_prep correctly connects and downloads from SQL") # not implemented yet
