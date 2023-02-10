# HousingPrice-Data-Cleaning-SQL

Time period of data: 2013 to 2019

One csv file is used in this project: Housing Price Data

Data Cleaning Processe as below:

- Standardize date format
- Populate 'PropertyAddress' that are missing with the same 'ParcelID' but unique 'ID'
- Breaking out ' PropertyAddress' & 'OwnerAdress' to address,city,state separately
- Improve data consistency, change 'Y' & 'N' to 'Yes' & 'No' in 'SoldAsVacant'
- Remove duplicates records
- Delete unused columns
