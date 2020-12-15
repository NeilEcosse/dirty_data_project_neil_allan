# Dirty data project task 3: Seabird observation data



# Folder structure

## 01_raw_data

**Note that this folder is not backed up to GitHub**

This folder contains the raw data supplied by CodeClan in an Excel file called **seabirds.xls**

It contains the following worksheets:

| **Sheet**              | **Contents**                                                                                                                                    |
|------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------|
| Ship data by record ID | Details about the observations, notably the location, date and time; the column **record_id** can be used to link to **Bird data by record ID** |
| Bird data by record ID | Details on the birds observed, notably species name and the number of individuals                                                               |
| Ship data codes        | Description of codes used in **Ship data by record ID**                                                                                         |
| Bird data codes        | Description of codes used in **Bird data by record ID**                                                                                         |



## 02_data_cleaning_scripts

This contains a file called **clean_data_seabirds.R**

### General notes on approach to cleaning

* I have removed certain unnecessary strings (detailed below) from the species name columns, but I have not attempted to clean them up any further. For example, there are names recorded as *Petrel (unidentified)*and *Wandering albatross sensu lato* - I have not made any attempt to refine these or group them with other species names, as I don't know enough about either the species involved or the level of knowledge of the observer.

* I have concentrated my efforts on columns related to species name and count, and the date and location of the observation; the tables contain a number of other columns with lower-leveldetail, and these might require further before being  used.

* I have retained observations where the count of birds is NA, and updated count to zero - I don't want to remove or ignore these rows at this stage, as they could be useful (e.g. not seeing any birds in a place you might expect to could in itself  be a useful observation).

### Details of the cleaning file  *clean_data_seabirds.R*

* Checks if the Excel file  **seabirds.xls**  contains the expected worksheets, as detailed in *01_raw_data* above.
It returns an error if the four expected sheet names are not found. If there are any extra worksheets, these will be ignored and the process will continue.

* Reads the contents of the four expected sheets into objects in the environment

* Creates new versions of each table with the suffix **clean**, and cleans the variable names of these objects using janitor; the following four objects will be used in the rest of the process:


| |
|------------------------------|
| bird_data_by_record_id_clean |
| ship_data_by_record_id_clean |
| bird_data_codes              |
| ship_data_codes              |


* Checks that latitude and longitude of observations in the ship table contain valid data

* Renames variables for common and scientific name to remove unwanted information

* **bird_data_by_record_id_clean** - removes unwanted information from *species_common_name*, *species_scientific_name* and *species_abbreviation*; as well as the name, these columns contain information on sex, age and plumage, which is already recorded elsewhere in the table. The following strings are deleted:

| **Data** | **String**                             |
|----------|----------------------------------------|
| sex      | M                                      |
| sex      | F                                      |
| age      | AD                                     |
| age      | SUBAD                                  |
| age      | IMM                                    |
| age      | JUV                                    |
| plumage  | PL followed by any single-digit number |
| plumage  | DRK                                    |
| plumage  | INT                                    |
| plumage  | LGHT                                   |
| plumage  | LIGHT                                  |
| plumage  | WHITE                                  |

* Removes any leading or trailing spaces left in these columns after the changes above; also removes the square brackets found in some fields

* Updates NA to 0 in numeric count columns

* Writes the four **clean** table objects into csv files with the same names in the folder **03_clean_data**




## 03_clean_data

**Note that this folder is not backed up to GitHub**

This folder contains the csv files created by **clean_data_seabirds.R**



## 04_analysis_and_documentation

This folder contains the file **seabird_analysis.Rmd**

It uses the cleaned csv files to:

* answer the analysis questions set by CodeClan

* do some other analysis based on things I'd noticed myself in the data.

Further details can be found in the Rmd file - note that my own analysis at this stage is more about me getting to know and understand the dataset, rather than seeking to extract insights or conclusions.









