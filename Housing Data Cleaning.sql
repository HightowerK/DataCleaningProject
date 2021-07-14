/*
----------------------------

CLEANING DATA W/ SQL QUERIES

----------------------------
*/

SELECT *
FROM HousingPortfolioProject.dbo.NashvilleHousing;

-- Standardize Date Format
SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM HousingPortfolioProject.dbo.NashvilleHousing;

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate);

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);


--------------------------------------------------------
-- Populate Property Address Data

SELECT *
FROM HousingPortfolioProject.dbo.NashvilleHousing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM HousingPortfolioProject.dbo.NashvilleHousing a
JOIN HousingPortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM HousingPortfolioProject.dbo.NashvilleHousing a
JOIN HousingPortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;
 


--------------------------------------------------------

-- Breaking out Address into Individual COlumns (Address, City, State)

SELECT PropertyAddress
FROM HousingPortfolioProject.dbo.NashvilleHousing
-- WHERE PropertyAddress IS NULL
-- ORDER BY ParcelID;

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM HousingPortfolioProject.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

SELECT *
FROM HousingPortfolioProject.dbo.NashvilleHousing;




SELECT OwnerAddress
FROM HousingPortfolioProject.dbo.NashvilleHousing;

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) AS StreetAddress
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) AS City
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) AS State
FROM HousingPortfolioProject.dbo.NashvilleHousing;


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);

-- SELECT *
-- FROM HousingPortfolioProject.dbo.NashvilleHousing;




--------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" Field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM HousingPortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM HousingPortfolioProject.dbo.NashvilleHousing;


UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END;



--------------------------------------------------------

-- Remove Duplicates (Not necessarily Common)

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM HousingPortfolioProject.dbo.NashvilleHousing
-- ORDER BY ParcelID
)

SELECT *
--DELETE
FROM RowNumCTE
WHERE row_num > 1;
--ORDER BY PropertyAddress



--------------------------------------------------------

-- Delete Unused Columns (Not necessarily Common)

SELECT *
FROM HousingPortfolioProject.dbo.NashvilleHousing;

-- Deleting OwnerAddress, Property Address and SaleDate since we updated/split up those columns previously

ALTER TABLE HousingPortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress;

ALTER TABLE HousingPortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate;



--------------------------------------------------------


