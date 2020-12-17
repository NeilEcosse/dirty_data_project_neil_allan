library(tidyverse)
library(readxl)
library(dplyr)
library(janitor)
library(assertr)



# create a vector of actual sheet names in boing-boing-candy-2015.xlsx
excel_sheet_names_actual <- c(excel_sheets("01_raw_data/boing-boing-candy-2015.xlsx"))


# return an error if the expected sheet name can't be found
stopifnot(
  ("Form Responses 1" %in% excel_sheet_names_actual) == TRUE
)

# drop actual sheet name vector
rm("excel_sheet_names_actual")


# read in the data
candy_2015_clean <-
  read_excel("01_raw_data/boing-boing-candy-2015.xlsx",
             sheet = "Form Responses 1")

# drop unwanted variables, create year, country, gender and unique_id columns
candy_2015_clean <-
  candy_2015_clean %>% 
  select("Timestamp":"[York Peppermint Patties]" ) %>% 
  mutate(year = substring(Timestamp,1,4)) %>% 
  mutate(country = NA_character_) %>%
  mutate(gender = NA_character_) %>%
  mutate(unique_id = paste(Timestamp,
                           substring(`How old are you?`,1,2),
                           `Are you going actually going trick or treating yourself?`,
                           sep = "_" ))



# check if there are dates from more than one year - create error message if there are

year_comparison <-
  candy_2015_clean %>% 
  summarise(max_year = max(year), min_year = min(year))

stopifnot(year_comparison$max_year == year_comparison$min_year)

# drop year_comparison
rm(year_comparison)



# use pivot_longer to convert candy columns to rows - make it tidy and easier to
#combine with data for other years

candy_2015_clean <- 
  candy_2015_clean %>% 
  pivot_longer(cols = "[Butterfinger]":"[York Peppermint Patties]",
               names_to = "candy_name",
               values_to = "rating",)

# clean column names
candy_2015_clean <-
  clean_names(candy_2015_clean)

# rename selected columns
candy_2015_clean <-
  candy_2015_clean %>% 
  rename("date" = "timestamp") %>% 
  rename("age_imported" = "how_old_are_you") %>% 
  rename("going_trick_or_treating" = "are_you_going_actually_going_trick_or_treating_yourself")


# delete observations where rating is NA - these are 'blank' rows created by pivot longer, not required
candy_2015_clean <-
  candy_2015_clean %>% 
  filter(!is.na(rating))
  
# remove punctuation and spaces from unique_id
candy_2015_clean <-
  candy_2015_clean %>% 
  mutate(unique_id = str_remove_all(unique_id, " |\\.|\\,|\\:|\\-"))

# remove square brackets from candy_name
candy_2015_clean <-
  candy_2015_clean %>% 
  mutate(candy_name = str_remove_all(candy_name,"\\[")) %>% 
  mutate(candy_name = str_remove_all(candy_name,"\\]"))


# create a numeric age column
candy_2015_clean <-
  candy_2015_clean %>% 
  mutate(age = as.numeric(str_extract(age_imported, "[0-9]+")))



# convert ages greater than 120 to NA
candy_2015_clean <-
  candy_2015_clean %>% 
 mutate(age = if_else(age > 120, NA_real_, age))



# write output to csv file
write_csv(candy_2015_clean, "03_clean_data/candy_2015_clean.csv")

# drop the object from environment
rm(candy_2015_clean)