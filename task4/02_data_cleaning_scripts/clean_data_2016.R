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



# write output to csv file
write_csv(candy_2016_clean, "03_clean_data/candy_2016_clean.csv")

check_country_us <-
  candy_2016_clean %>%
  filter(str_detect(country_imported, "[uU][sS][aA]")) %>% 
  group_by(country_imported) %>%
  summarise(count  = n()) %>% 
  arrange(country_imported)

candy_2016_clean <-
  candy_2016_clean %>%
  select(date:age) %>% 
  mutate(country = case_when(
                    (str_detect(country_imported, "Not") & str_detect(country_imported, "[uU][sS][aA]")) ~ NA_character_,
                    str_detect(country_imported, "[uU][sS][aA]") ~ "USA"
                    ) 
                    )

