library(tidyverse)
library(readxl)
library(dplyr)
library(janitor)
library(assertr)



# create a vector of actual sheet names in boing-boing-candy-2017.xlsx
excel_sheet_names_actual <- c(excel_sheets("01_raw_data/boing-boing-candy-2017.xlsx"))


# return an error if the expected sheet name can't be found
stopifnot(
  ("responses (2) (1).csv" %in% excel_sheet_names_actual) == TRUE
)

# drop actual sheet name vector
rm("excel_sheet_names_actual")


# read in the data
candy_2017_clean <-
  read_excel("01_raw_data/boing-boing-candy-2017.xlsx",
             sheet = "responses (2) (1).csv")

# drop unwanted variables, create year and unique_id columns
candy_2017_clean <-
  candy_2017_clean %>% 
  select("Internal ID":"Q6 | York Peppermint Patties" ) %>% 
  mutate(year = as.integer("2017")) %>% 
  mutate(unique_id = paste(year,
                           `Internal ID`,
                           substring(`Q3: AGE`,1,2),
                           `Q1: GOING OUT?`,
                           sep = "_" ))






# use pivot_longer to convert candy columns to rows - make it tidy and easier to
#combine with data for other years

candy_2017_clean <- 
  candy_2017_clean %>% 
  pivot_longer(cols = "Q6 | 100 Grand Bar":"Q6 | York Peppermint Patties",
               names_to = "candy_name",
               values_to = "rating",)

# clean column names
candy_2017_clean <-
  clean_names(candy_2017_clean)

# rename selected columns
candy_2017_clean <-
  candy_2017_clean %>% 
  rename("going_trick_or_treating" = "q1_going_out") %>%
  rename("gender" = "q2_gender") %>%
  rename("age_imported" = "q3_age") %>% 
  rename("country_imported" = "q4_country") %>%
  rename("state_province_county_imported" = "q5_state_province_county_etc") 


# delete observations where rating is NA - these are 'blank' rows created by pivot longer, not required
candy_2017_clean <-
  candy_2017_clean %>% 
  filter(!is.na(rating))

# remove punctuation and spaces from unique_id
candy_2017_clean <-
  candy_2017_clean %>% 
  mutate(unique_id = str_remove_all(unique_id, " |\\.|\\,|\\:|\\-"))

# remove "Q6 | " from candy_name
candy_2017_clean <-
  candy_2017_clean %>% 
  mutate(candy_name = str_remove_all(candy_name,"Q6 \\| ")) 


# create a numeric age column
candy_2017_clean <-
  candy_2017_clean %>% 
  mutate(age = as.numeric(str_extract(age_imported, "[0-9]+")))



# convert ages greater than 120 to NA
candy_2017_clean <-
  candy_2017_clean %>% 
  mutate(age = if_else(age > 120, NA_real_, age))



# make a clean country column using various  regex searches

# This is not ideal - it will not cope with any new genuine countries if they're added to the data
# could maybe get a list of countries to match the data to?
candy_2017_clean <-
  candy_2017_clean %>%
  select(internal_id:age) %>% 
  mutate(country = case_when(
    #USA
    (str_detect(country_imported, "Not") & str_detect(country_imported, "[uU][sS][aA]")) ~ NA_character_,
    str_detect(country_imported, "[uU][sS][aA]") ~ "USA",
    str_detect(country_imported, "^[uU][sS]") ~ "USA",
    str_detect(country_imported, "^[uU] [sS]") ~ "USA",
    str_detect(country_imported, "^[uU][\\.][sS]") ~ "USA",
    str_detect(country_imported, "[uU][nN][iI][tT]") & str_detect(country_imported, "[sS][tT]") ~ "USA",
    str_detect(country_imported, "[aA][mM][eE][rR][iI][cC][aA]") ~ "USA",
    str_detect(country_imported, "United Sates") ~ "USA",
    str_detect(country_imported, "Murica") ~ "USA",
    str_detect(country_imported, "The Yoo Ess of Aaayyyyyy") ~ "USA",
    str_detect(country_imported, "^Merica") ~ "USA",
    str_detect(country_imported, "'merica") ~ "USA",
    str_detect(country_imported, "murrika") ~ "USA",
    str_detect(country_imported, "Ahem....Amerca") ~ "USA",
    str_detect(country_imported, "Alaska") ~ "USA",
    str_detect(country_imported, "California") ~ "USA",
    str_detect(country_imported, "New Jersey") ~ "USA",
    str_detect(country_imported, "New York") ~ "USA",
    str_detect(country_imported, "North Carolina") ~ "USA",
    str_detect(country_imported, "Pittsburgh") ~ "USA",
    str_detect(country_imported, "Pittsburgh") ~ "USA",
    # Other genuine countries - this is where I'd prefer to use a look-up, otherwise I need 
    # to update every time I have new data - they'd be dumped into NA
    str_detect(country_imported, "^[aA]ustralia") ~ "Australia",
    str_detect(country_imported, "^[aA]ustria") ~ "Austria",
    str_detect(country_imported, "^[bB]elgium") ~ "Belgium",
    str_detect(country_imported, "^[bB]rasil") ~ "Brazil",
    str_detect(country_imported, "^[bB]razil") ~ "Brazil",
    str_detect(country_imported, "^[cC][aA][nN][aA][dD][aA]") ~ "Canada",
    str_detect(country_imported, "^[cC]hina") ~ "China",
    str_detect(country_imported, "^[cC]osta [rR]ica") ~ "Costa Rica",
    str_detect(country_imported, "^[cC]roatia") ~ "Croatia",
    str_detect(country_imported, "^[dD]enmark") ~ "Denmark",
    str_detect(country_imported, "^[eE]ngland") ~ "UK",
    str_detect(country_imported, "^[eE]spaña") ~ "Spain",
    str_detect(country_imported, "^[fF]inland") ~ "Finland",
    str_detect(country_imported, "^[fF]rance") ~ "France",
    str_detect(country_imported, "^[gG]ermany") ~ "Germany",
    str_detect(country_imported, "^[gG]reece") ~ "Greece",
    str_detect(country_imported, "^[hH]ungary") ~ "Hungary",
    str_detect(country_imported, "^[iI]celand") ~ "Iceland",
    str_detect(country_imported, "^[iI]reland") ~ "Ireland",
    str_detect(country_imported, "^[jJ]apan") ~ "Japan",
    #str_detect(country_imported, "^[kK]orea") ~ "South Korea",
    str_detect(country_imported, "^[kK]enya") ~ "Kenya",
    str_detect(country_imported, "^[mM]exico") ~ "Mexico",
    str_detect(country_imported, "[nN]etherland") ~ "Netherlands",
    str_detect(country_imported, "^[nN]ew [zZ]ealand") ~ "New Zealand",
    str_detect(country_imported, "^[pP]anama") ~ "Panama",
    str_detect(country_imported, "^[pP]hilippines") ~ "Philippines",
    str_detect(country_imported, "^[pP]ortugal") ~ "Portugal",
    str_detect(country_imported, "^[sS]ingapore") ~ "Singapore",
    str_detect(country_imported, "^[sS]cotland") ~ "UK",
    str_detect(country_imported, "^[sS]outh [aA]frica") ~ "South Africa",
    str_detect(country_imported, "^[sS]outh [kK]orea") ~ "South Korea",
    str_detect(country_imported, "^[sS]pain") ~ "Spain",
    str_detect(country_imported, "^[sS]weden") ~ "Sweden",
    str_detect(country_imported, "^[sS]witzerland") ~ "Switzerland",
    str_detect(country_imported, "^[sS]weden") ~ "Sweden",
    str_detect(country_imported, "^[tT]aiwan") ~ "Taiwan",
    str_detect(country_imported, "^[uU][aA][eE]") ~ "UAE",
    str_detect(country_imported, "^[uU][kK]") ~ "UK",
    str_detect(country_imported, "^[uU]nited [kK]") ~ "UK",
    TRUE ~ NA_character_
  ) 
  )


# write output to csv file
write_csv(candy_2017_clean, "03_clean_data/candy_2017_clean.csv")

# create a checklist of what countries have been updated to
# since the script isn't perfect, this is a here as a check
check_countries_2017 <-
  candy_2017_clean %>% 
  group_by(country, country_imported) %>% 
  summarise(count = n()) %>% 
  arrange(country, country_imported)

# drop the candy object from environment
rm(candy_2017_clean)



