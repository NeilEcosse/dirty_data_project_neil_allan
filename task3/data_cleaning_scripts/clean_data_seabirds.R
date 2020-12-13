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

# clean bird_data_by_record_id column names with janitor
bird_data_by_record_id_clean <-
  clean_names(bird_data_by_record_id)

# change column titles for common and scientific names
bird_data_by_record_id_clean <-
  bird_data_by_record_id_clean %>% 
  rename("species_common_name" = "species_common_name_taxon_age_sex_plumage_phase") %>% 
  rename("species_scientific_name" = "species_scientific_name_taxon_age_sex_plumage_phase")


# remove strings relating to age, sex and plumage from species_common_name
bird_data_by_record_id_clean <-
  bird_data_by_record_id_clean %>% 
  mutate(species_common_name = str_remove_all(species_common_name, " AD[MF]*| SUBAD[MF]*| IMM[MF]*| JUV[MF]*| PL[1-9][MF]*| DRK[MF]*| INT[MF]*| LGHT[MF]*| WHITE[MF]*"))
