# Dirty data project task 4: Halloween candy data



# Folder structure

## 01_raw_data

**Note that this folder is not backed up to GitHub**

This folder contains the raw data supplied by CodeClan:

* **boing-boing-candy-2015.xlsx**

* **boing-boing-candy-2017.xlsx**

* **boing-boing-candy-2016.xlsx**



## 02_data_cleaning_scripts

This contains three cleaning **.R** files, one for each of the Excel files listed above.

Please open each for detailed notes on what the code does.

### General notes on approach to cleaning

* The raw data files are in a "wide" format, with a column for each of the dozens of candy types in the data - I've made the data "longer"  by combining these all into one **candy_name** column.

* My aim was to get the three files into a format where they could be appended into a single "all years" table - to do this, I've ensured that the clean versions of the 2015,  2016 and 2017 data all have the following columns:

| Column                  | Format |
|-------------------------|--------|
| year                    | num    |
| unique_id               | chr    |
| age                     | num    |
| gender                  | chr    |
| country                 | chr    |
| going_trick_or_treating | chr    |
| candy_name              | chr    |
| rating                  | chr    |

* The **country** column had particularly messy data in it - to clean this, I've used a mix of regex and hard coding. This is a section which could do with some further refining, e.g.

  * Perhaps use a look-up table for country names
  
  * Move the country cleaning code out of the separate yearly cleaning files - it would be better if there was only one place where you had to update the code.
  



## 03_clean_data

**Note that this folder is not backed up to GitHub**

This folder contains csv files created by the cleaning scripts described above:

* **candy_2015_clean.csv**
* **candy_2016_clean.csv**
* **candy_2017_clean.csv**



## 04_analysis_and_documentation

This folder contains two **.Rmd** notebooks:

* **01_initial_checks_raw_data.Rmd**: This file contains some code chunks I used to get an idea of what the raw data looked like, along with my initial thoughts on what needed to be cleaned.


* **02_candy_analysis.Rmd**: This brings in the csv files created by my cleaning scripts, and joins them together in a single table. This is then used to answer some analysis questions which had been  set by CodeClan.
