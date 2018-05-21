create_PDS <- function(){
  # load PDS data (from csv or from SQL, depending on arguments)
  data <- read_PDS_csv() %>%
    # clean PDS data
    clean_PDS() %>%
    # combine data using create_Element

    create_Element() %>%
  # clean element level data
    clean_element() %>%
  # add area to element level data
    format_element() %>%
    areafy
  # add repair costs and deterioration rates to element level data
  # format output ready for Blockbuster
}
