library(tidyverse)
library(readxl)
library(dplyr)
library(janitor)


# create a vector of expected sheet names in seabirds.xls
excel_sheet_names_expected <- c("Ship data by record ID", 
                                "Bird data by record ID", 
                                "Ship data codes", 
                                "Bird data codes")

# create a vector of actual sheet names in seabirds.xls
excel_sheet_names_actual <- c(excel_sheets("raw_data/seabirds.xls"))

# return an error if any expected sheet names can't be found
stopifnot(
  all(excel_sheet_names_expected %in% excel_sheet_names_actual) == TRUE
)

# drop sheet name vectors
rm("excel_sheet_names_expected", "excel_sheet_names_actual")




# read in the data
ship_data_by_record_id <- read_excel("raw_data/seabirds.xls", sheet = "Ship data by record ID")
bird_data_by_record_id <- read_excel("raw_data/seabirds.xls", sheet = "Bird data by record ID")
ship_data_codes <- read_excel("raw_data/seabirds.xls", sheet = "Ship data codes")
bird_data_codes <- read_excel("raw_data/seabirds.xls", sheet = "Bird data codes")


