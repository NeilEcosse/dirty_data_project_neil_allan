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

# drop unwanted variables, create year and unique_id columns
candy_2015_clean <-
  candy_2015_clean %>% 
  select("Timestamp":"[York Peppermint Patties]" ) %>% 
  mutate(year = substring(Timestamp,1,4)) %>% 
  mutate(unique_id = paste(Timestamp,
                           substring(`How old are you?`,1,2),
                           `Are you going actually going trick or treating yourself?`,
                           sep = "_" ))

# use pivot_longer to convert candy columns to rows
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
  
# remove punctuation and spaces from unique_id
candy_2015_clean <-
  candy_2015_clean %>% 
  mutate(unique_id = str_remove_all(unique_id, " |\\.|\\,|\\:|\\-"))

# remove square brackets from candy_name
candy_2015_clean <-
  candy_2015_clean %>% 
  mutate(candy_name = str_remove_all(candy_name,"\\[")) %>% 
  mutate(candy_name = str_remove_all(candy_name,"\\]"))


  
#candy_2015_clean <-
#  candy_2015_clean %>%
#  separate(age_imported, into = c("age", "junk"), sep = ".0")


# delete observations where rating is NA - these are 'blank' rows created by pivot longer, not required

candy_2015_clean <-
  candy_2015_clean %>% 
  filter(!is.na(rating))






