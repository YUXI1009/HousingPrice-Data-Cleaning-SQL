USE Housing_Data;

SELECT * FROM Nashville_Housing_Data_for_Data_Cleaning;

-- Standardize date format

UPDATE Nashville_Housing_Data_for_Data_Cleaning 
SET SaleDate = CONVERT(SaleDate,DATE);
--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

SELECT 
    ParcelID,
    PropertyAddress  
FROM Nashville_Housing_Data_for_Data_Cleaning nhdfdc2
ORDER BY ParcelID ;

SELECT 
    n1.ParcelID,
    n1.PropertyAddress,
    n2.ParcelID,
    n2.PropertyAddress,
    IF((n1.PropertyAddress=''),n2.PropertyAddress,n1.PropertyAddress) 
FROM Nashville_Housing_Data_for_Data_Cleaning n1
JOIN Nashville_Housing_Data_for_Data_Cleaning n2
ON n1.ParcelID = n2.ParcelID
AND n1.ID <> n2.ID
WHERE n1.PropertyAddress = '';

UPDATE Nashville_Housing_Data_for_Data_Cleaning n1
INNER JOIN
(SELECT
    n2.ID,
    n2.ParcelID,
    n2.PropertyAddress
FROM Nashville_Housing_Data_for_Data_Cleaning n2) AS t
ON n1.ParcelID = t.ParcelID
AND n1.ID <> t.ID
SET n1.PropertyAddress  =  IF((n1.PropertyAddress=''),t.PropertyAddress,n1.PropertyAddress);
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress  FROM Nashville_Housing_Data_for_Data_Cleaning;

SELECT 
    SUBSTRING(PropertyAddress,1,LOCATE(',',PropertyAddress)-1) as address,
    SUBSTRING(PropertyAddress,LOCATE(',',PropertyAddress)+1) as city
FROM Nashville_Housing_Data_for_Data_Cleaning n;

ALTER TABLE Nashville_Housing_Data_for_Data_Cleaning 
ADD PropertySplitAddress VARCHAR(255);

UPDATE Nashville_Housing_Data_for_Data_Cleaning 
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,LOCATE(',',PropertyAddress)-1);

ALTER TABLE Nashville_Housing_Data_for_Data_Cleaning 
ADD PropertySplitCity VARCHAR(255);

UPDATE Nashville_Housing_Data_for_Data_Cleaning 
SET PropertySplitCity = SUBSTRING(PropertyAddress,LOCATE(',',PropertyAddress)+1);

SELECT * FROM Nashville_Housing_Data_for_Data_Cleaning;

SELECT OwnerAddress FROM Nashville_Housing_Data_for_Data_Cleaning;

SELECT
SUBSTRING_INDEX(OwnerAddress,',',1) AS Addess,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2),',',-1) AS City,
SUBSTRING_INDEX(OwnerAddress,',',-1) AS state
FROM Nashville_Housing_Data_for_Data_Cleaning;

ALTER TABLE Nashville_Housing_Data_for_Data_Cleaning 
ADD OwnerAddressSplitAddress VARCHAR(255);

UPDATE Nashville_Housing_Data_for_Data_Cleaning 
SET OwnerAddressSplitAddress=SUBSTRING_INDEX(OwnerAddress,',',1);

ALTER TABLE Nashville_Housing_Data_for_Data_Cleaning 
ADD OwnerAddressSplitCity VARCHAR(255);

UPDATE Nashville_Housing_Data_for_Data_Cleaning 
SET OwnerAddressSplitCity=SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2),',',-1);

ALTER TABLE Nashville_Housing_Data_for_Data_Cleaning 
ADD OwnerAddressSplitState VARCHAR(255);

UPDATE Nashville_Housing_Data_for_Data_Cleaning 
SET OwnerAddressSplitState=SUBSTRING_INDEX(OwnerAddress,',',-1);

SELECT * FROM Nashville_Housing_Data_for_Data_Cleaning nhdfdc ;

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT SoldAsVacant 
FROM Nashville_Housing_Data_for_Data_Cleaning; 

SELECT 
    CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
         WHEN SoldAsVacant ='N'  THEN 'No'
         ELSE SoldAsVacant 
    END AS SoldAsVacant 
FROM Nashville_Housing_Data_for_Data_Cleaning nhdfdc;

UPDATE Nashville_Housing_Data_for_Data_Cleaning 
SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
                        WHEN SoldAsVacant ='N'  THEN 'No'
                        ELSE SoldAsVacant 
                        END;
                        
SELECT distinct(SoldAsVacant)
FROM Nashville_Housing_Data_for_Data_Cleaning;


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


WITH RowNumCTE AS(
SELECT 
    *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					ID
					) row_num

From Nashville_Housing_Data_for_Data_Cleaning nhdfdc 
ORDER BY ParcelID)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;


SELECT * FROM Nashville_Housing_Data_for_Data_Cleaning;


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE Nashville_Housing_Data_for_Data_Cleaning 
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress, 
DROP COLUMN SaleDate;
