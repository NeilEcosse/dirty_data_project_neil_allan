library(tidyverse)
library(readxl)
library(dplyr)
library(janitor)
library(assertr)



# create a vector of actual sheet names in boing-boing-candy-2016.xlsx
excel_sheet_names_actual <- c(excel_sheets("01_raw_data/boing-boing-candy-2016.xlsx"))


# return an error if the expected sheet name can't be found
stopifnot(
  ("Form Responses 1" %in% excel_sheet_names_actual) == TRUE
)

# drop actual sheet name vector
rm("excel_sheet_names_actual")


# read in the data
candy_2016_clean <-
  read_excel("01_raw_data/boing-boing-candy-2016.xlsx",
             sheet = "Form Responses 1")

# drop unwanted variables, create year and unique_id columns
candy_2016_clean <-
  candy_2016_clean %>% 
  select("Timestamp":"[York Peppermint Patties]" ) %>% 
  mutate(year = substring(Timestamp,1,4)) %>% 
  mutate(unique_id = paste(Timestamp,
                           substring(`How old are you?`,1,2),
                           `Are you going actually going trick or treating yourself?`,
                           sep = "_" ))


# check if there are dates from more than one year - create error message if there are

year_comparison <-
  candy_2016_clean %>% 
  summarise(max_year = max(year), min_year = min(year))

stopifnot(year_comparison$max_year == year_comparison$min_year)

# drop year_comparison
rm(year_comparison)




# use pivot_longer to convert candy columns to rows - make it tidy and easier to
#combine with data for other years

candy_2016_clean <- 
  candy_2016_clean %>% 
  pivot_longer(cols = "[100 Grand Bar]":"[York Peppermint Patties]",
               names_to = "candy_name",
               values_to = "rating",)

# clean column names
candy_2016_clean <-
  clean_names(candy_2016_clean)

# rename selected columns
candy_2016_clean <-
  candy_2016_clean %>% 
  rename("date" = "timestamp") %>% 
  rename("going_trick_or_treating" = "are_you_going_actually_going_trick_or_treating_yourself") %>%
  rename("gender" = "your_gender") %>%
  rename("age_imported" = "how_old_are_you") %>% 
  rename("country_imported" = "which_country_do_you_live_in") %>%
  rename("state_province_county_imported" = "which_state_province_county_do_you_live_in") 


# delete observations where rating is NA - these are 'blank' rows created by pivot longer, not required
candy_2016_clean <-
  candy_2016_clean %>% 
  filter(!is.na(rating))

# remove punctuation and spaces from unique_id
candy_2016_clean <-
  candy_2016_clean %>% 
  mutate(unique_id = str_remove_all(unique_id, " |\\.|\\,|\\:|\\-"))

# remove square brackets from candy_name
candy_2016_clean <-
  candy_2016_clean %>% 
  mutate(candy_name = str_remove_all(candy_name,"\\[")) %>% 
  mutate(candy_name = str_remove_all(candy_name,"\\]"))


# create a numeric age column
candy_2016_clean <-
  candy_2016_clean %>% 
  mutate(age = as.numeric(str_extract(age_imported, "[0-9]+")))



# convert ages greater than 120 to NA
candy_2016_clean <-
  candy_2016_clean %>% 
  mutate(age = if_else(age > 120, NA_real_, age))



# make a clean country column using various  regex searches

# This is not ideal - it will not cope with any new genuine countries if they're added to the data
# could maybe get a list of countries to match the data to?
candy_2016_clean <-
  candy_2016_clean %>%
  select(date:age) %>% 
  mutate(country = case_when(
  #USA
    (str_detect(country_imported, "Not") & str_detect(country_imported, "[uU][sS][aA]")) ~ NA_character_,
    str_detect(country_imported, "[uU][sS][aA]") ~ "USA",
    str_detect(country_imported, "^[uU][sS]") ~ "USA",
    str_detect(country_imported, "^[uU][\\.][sS]") ~ "USA",
    str_detect(country_imported, "[uU][nN][iI][tT]") & str_detect(country_imported, "[sS][tT]") ~ "USA",
    str_detect(country_imported, "[aA][mM][eE][rR][iI][cC][aA]") ~ "USA",
    str_detect(country_imported, "United Sates") ~ "USA",
    str_detect(country_imported, "Murica") ~ "USA",
    str_detect(country_imported, "The Yoo Ess of Aaayyyyyy") ~ "USA",
    str_detect(country_imported, "^Merica") ~ "USA",
  # Other genuine countries - this is where I'd prefer to use a look-up, otherwise I need 
  # to update every time I have new data - they'd be dumped into NA
    str_detect(country_imported, "^[aA]ustralia") ~ "Australia",
    str_detect(country_imported, "^[aA]ustria") ~ "Austria",
    str_detect(country_imported, "^[bB]elgium") ~ "Belgium",
    str_detect(country_imported, "^[bB]rasil") ~ "Brazil",
    str_detect(country_imported, "^[bB]razil") ~ "Brazil",
    str_detect(country_imported, "^[cC]anada") ~ "Canada",
    str_detect(country_imported, "^[cC]hina") ~ "China",
    str_detect(country_imported, "^[cC]roatia") ~ "Croatia",
    str_detect(country_imported, "^[eE]ngland") ~ "UK",
    str_detect(country_imported, "^[eE]spaña") ~ "Spain",
    str_detect(country_imported, "^[fF]inland") ~ "Finland",
    str_detect(country_imported, "^[fF]rance") ~ "France",
    str_detect(country_imported, "^[gG]ermany") ~ "Germany",
    str_detect(country_imported, "^[hH]ungary") ~ "Hungary",
    str_detect(country_imported, "^[jJ]apan") ~ "Japan",
    #str_detect(country_imported, "^[kK]orea") ~ "South Korea",
    str_detect(country_imported, "^[kK]enya") ~ "Kenya",
    str_detect(country_imported, "^[mM]exico") ~ "Mexico",
    str_detect(country_imported, "[nN]etherland") ~ "Netherlands",
    str_detect(country_imported, "^[nN]ew [zZ]ealand") ~ "New Zealand",
    str_detect(country_imported, "^[pP]anama") ~ "Panama",
    str_detect(country_imported, "^[pP]hilippines") ~ "Philippines",
    str_detect(country_imported, "^[pP]ortugal") ~ "Portugal",
    str_detect(country_imported, "^[sS]outh [kK]orea") ~ "South Korea",
    str_detect(country_imported, "^[sS]weden") ~ "Sweden",
    str_detect(country_imported, "^[sS]witzerland") ~ "Switzerland",
    str_detect(country_imported, "^[sS]weden") ~ "Sweden",
    str_detect(country_imported, "^[uU][kK]") ~ "UK",
    str_detect(country_imported, "^[uU]nited [kK]") ~ "UK",
    TRUE ~ NA_character_
  ) 
  )


# write output to csv file
write_csv(candy_2016_clean, "03_clean_data/candy_2016_clean.csv")