/* This is a Case study which focuses on data cleaning using SQL */

--=============================================================================================================================
--Overview of the Data

SELECT * FROM NashvilleHousing
--=============================================================================================================================
--Standardizing the Date format
--Converting SaleDate's DateTime format to Date format

Alter Table NashvilleHousing
ADD SaleDateConverted DATE

UPDATE  NashvilleHousing
SET SaleDateConverted = SaleDate
--=============================================================================================================================
--Handling the missing values 
--Populating the missing PropertyAddress data 

Select A.ParcelID,A.PropertyAddress,B.ParcelID,B.PropertyAddress,ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM NashvilleHousing AS A
JOIN NashvilleHousing AS B
ON A.ParcelID = B.ParcelID AND A.[UniqueID ] <>B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A 
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM NashvilleHousing AS A
JOIN NashvilleHousing AS B
ON A.ParcelID = B.ParcelID AND A.[UniqueID ] <>B.[UniqueID ]
WHERE A.PropertyAddress IS NULL
--=============================================================================================================================
--Spliting data into multiple columns using SUBSTRING
--Property's Address divided into individual columns (Address,City) 

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,0,CHARINDEX(',',PropertyAddress))

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
--=============================================================================================================================
--Spliting data into multiple columns using PARSENAME 
--Owner's address split into individual columns (Address,City,State)

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress VARCHAR(50)
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity VARCHAR(50)
UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)
UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)
--=============================================================================================================================
--Replacing values for consistency 
--Standardize SoldAsVacant field from Y/N to Yes and No

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
--===================================================================================================================
--Removing the duplicates -using CTE 

With CTE_Duplicates
AS
(
SELECT * ,
ROW_NUMBER()OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				)Row_Num
FROM NashvilleHousing
)
DELETE FROM CTE_Duplicates
Where Row_Num >1
--===================================================================================================================
--Deleting Unused/irrelevant columns

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress,OwnerAddress,TaxDistrict
ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate
SELECT * FROM NashvilleHousing



