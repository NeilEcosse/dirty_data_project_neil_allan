library(tidyverse)
library(readxl)
library(dplyr)
library(janitor)
library(assertr)



# create a vector of expected sheet names in seabirds.xls
excel_sheet_names_expected <- c("Ship data by record ID", 
                                "Bird data by record ID", 
                                "Ship data codes", 
                                "Bird data codes")

# create a vector of actual sheet names in seabirds.xls
excel_sheet_names_actual <- c(excel_sheets("01_raw_data/seabirds.xls"))

# return an error if any expected sheet names can't be found
stopifnot(
  all(excel_sheet_names_expected %in% excel_sheet_names_actual) == TRUE
)

# drop sheet name vectors
rm("excel_sheet_names_expected", "excel_sheet_names_actual")


# read in the data
ship_data_by_record_id <- read_excel("01_raw_data/seabirds.xls", sheet = "Ship data by record ID")
bird_data_by_record_id <- read_excel("01_raw_data/seabirds.xls", sheet = "Bird data by record ID")
ship_data_codes <- read_excel("01_raw_data/seabirds.xls", sheet = "Ship data codes")
bird_data_codes <- read_excel("01_raw_data/seabirds.xls", sheet = "Bird data codes")



# bird_data_by_record_id - clean column names with janitor
bird_data_by_record_id_clean <-
  clean_names(bird_data_by_record_id)

# ship_data_by_record_id - clean column names with janitor
ship_data_by_record_id_clean <-
  clean_names(ship_data_by_record_id)

# bird_data_codes - clean column names with janitor
bird_data_codes_clean <-
  clean_names(bird_data_codes)

# ship_data_codes - clean column names with janitor
ship_data_codes_clean <-
  clean_names(ship_data_codes)

#  drop pre-cleaning versions of objects
rm("bird_data_by_record_id", "ship_data_by_record_id", "bird_data_codes", "ship_data_codes")

# ship_data_by_record_id_clean - check that values for latitude and longitude are valid
ship_data_by_record_id_clean  %>% 
  verify(is.na(lat) | (lat >= -90 & lat <= 90)) %>% 
  verify(is.na(long) | (long >= -180 & long <= 180))




# bird_data_by_record_id_clean - change column titles for common and scientific names
bird_data_by_record_id_clean <-
  bird_data_by_record_id_clean %>% 
  rename("species_common_name" = "species_common_name_taxon_age_sex_plumage_phase") %>% 
  rename("species_scientific_name" = "species_scientific_name_taxon_age_sex_plumage_phase")


# bird_data_by_record_id_clean - remove strings relating to age, sex and plumage from species_common_name
bird_data_by_record_id_clean <-
  bird_data_by_record_id_clean %>% 
  mutate(species_common_name = str_remove_all(species_common_name, 
        " M| F| AD[MF]*| SUBAD[MF]*| IMM[MF]*| JUV[MF]*| PL[1-9][MF]*| DRK[MF]*| INT[MF]*| LGHT[MF]*| LIGHT[MF]*| WHITE[MF]*"))
# remove any leading or trailing spaces from species_common_name
bird_data_by_record_id_clean <-
  bird_data_by_record_id_clean %>% 
  mutate(species_common_name = trimws(species_common_name, which = "both"))



# bird_data_by_record_id_clean - remove brackets from species_common_name for "NO BIRDS RECORDED" records
bird_data_by_record_id_clean <-
  bird_data_by_record_id_clean %>% 
  mutate(species_common_name = str_remove_all(species_common_name,"\\["))
bird_data_by_record_id_clean <-
  bird_data_by_record_id_clean %>% 
  mutate(species_common_name = str_remove_all(species_common_name,"\\]"))



#  bird_data_by_record_id_clean - remove strings relating to age, sex and plumage from species_scientific_name
bird_data_by_record_id_clean <-
  bird_data_by_record_id_clean %>% 
  mutate(species_scientific_name = str_remove_all(species_scientific_name, 
        " M| F| AD[MF]*| SUBAD[MF]*| IMM[MF]*| JUV[MF]*| PL[1-9][MF]*| DRK[MF]*| INT[MF]*| LGHT[MF]*| LIGHT[MF]*| WHITE[MF]*"))
# remove any leading or trailing spaces from species_scientific_name
bird_data_by_record_id_clean <-
  bird_data_by_record_id_clean %>% 
  mutate(species_scientific_name = trimws(species_scientific_name, which = "both"))



#  bird_data_by_record_id_clean - remove strings relating to age, sex and plumage from species_abbreviation
bird_data_by_record_id_clean <-
  bird_data_by_record_id_clean %>% 
  mutate(species_abbreviation = str_remove_all(species_abbreviation, 
        " M| F| AD[MF]*| SUBAD[MF]*| IMM[MF]*| JUV[MF]*| PL[1-9][MF]*| DRK[MF]*| INT[MF]*| LGHT[MF]*| LIGHT[MF]*| WHITE[MF]*"))
# remove any leading or trailing spaces from species_abbreviation
bird_data_by_record_id_clean <-
  bird_data_by_record_id_clean %>% 
  mutate(species_abbreviation = trimws(species_abbreviation, which = "both"))




# bird_data_by_record_id_clean_clean - change NA to 0 in numeric 'count' columns
bird_data_by_record_id_clean <-
  bird_data_by_record_id_clean %>%
    mutate(count = if_else(is.na(count),0,count)) %>%
    mutate(nfeed = if_else(is.na(nfeed),0,nfeed)) %>%
    mutate(nsow = if_else(is.na(nsow),0,nsow)) %>%
    mutate(nsoice = if_else(is.na(nsoice),0,nsoice)) %>%
    mutate(nflyp = if_else(is.na(nflyp),0,nflyp)) %>%
    mutate(nacc = if_else(is.na(nacc),0,nacc)) %>%
    mutate(nfoll = if_else(is.na(nfoll),0,nfoll)) 


# write output to csv files
write_csv(bird_data_by_record_id_clean,"03_clean_data/bird_data_by_record_id_clean.csv")
write_csv(ship_data_by_record_id_clean,"03_clean_data/ship_data_by_record_id_clean.csv")
write_csv(bird_data_codes_clean,"03_clean_data/bird_data_codes_clean.csv")
write_csv(ship_data_codes_clean,"03_clean_data/ship_data_codes_clean.csv")


# drop data objects from environment
rm(bird_data_by_record_id_clean, bird_data_codes_clean, ship_data_by_record_id_clean, ship_data_codes_clean)