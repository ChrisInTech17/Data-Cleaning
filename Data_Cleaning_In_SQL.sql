SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing
-- Taking a look at the Housing Data--
SELECT SaleDateConverted
FROM PortfolioProject.dbo.NashvilleHousing

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)
-- Ran into an issue where the above querey went through with (56477 rows affected) message
--But it didn't update the format. I'll try ALTER

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)
---- Taking a quick look at the Property Addresses---

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
---The Property Address is filled with NULL entries I'm going to recovery it---

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
---Where PropertyAddress IS NULL---
ORDER BY ParcelID
---It seems the ParcelID can help with the address for the NULL rows I'll do an Join to fully,--
--Compare the (ParcelID, Addresses) and the (NULL row Addresses).---

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID , b.PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b. [UniqueID ]
WHERE a.PropertyAddress IS NULL

--Above I wanted to join tables to compare the ParcelID and Address side by side--


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID , b.PropertyAddress, ISNULL(a.propertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b. [UniqueID ]
WHERE a.PropertyAddress IS NULL

--I verified the ParcelID does infact match for both rows which lets me know we can populate Address B into Address A

UPDATE a
SET PropertyAddress = ISNULL(a.propertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b. [UniqueID ]
WHERE a.PropertyAddress IS NULL
--All addresses have been updated Results returned (0 rows affected) Using ISNULL to find and Replace NULL values.--


SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
--Looks Great--

-- NOW I'm going to break the addresses into seperate coloumns because they currenty have the City---

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
---WHERE PropertyAddress IS NULL

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address
--I pulled from the first value all the way to the coma using  the substring and CHARINDEX minus 1 value to remove the coma.

FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN (PropertyAddress))
FROM PortfolioProject.dbo.NashvilleHousing

--Now I'm going to use the same method above to create seperate columns for each respective value in the address--

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);
--First I added the table--

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)
--Added the results from this substring--

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);
--Again added the table for city this time--
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN (PropertyAddress))
--Then I added the results to the table for city--

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--The very last column has my new changes which are easier to use and view.--

SELECT OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

SELECT

PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From PortfolioProject.dbo.NashvilleHousing
--Here I'm using PARSENAME to seperate the address into their own columns---
--PARSENAME gave me the address backwards so I did 3,2,1 to get a standard address format--
---I  to use the same method above to create seperate columns for each respective value in the address--

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
--Then I added the results to the table for city, and state--

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--The very last column has my new changes which are easier to use and view.--

-- Moving on I'll Change Y and N to Yes and No in "Sold as Vacant" Coulmn

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant ,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant =  'N' THEN 'No'
	ELSE SoldAsVacant
	END	
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant =  'N' THEN 'No'
	ELSE SoldAsVacant
	END	

	SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2
---All set update was a success--

--- Removing Duplicates JUST OUT OF PRACTICE
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					)row_num
FROM PortfolioProject.dbo.NashvilleHousing
) DELETE
FROM RowNumCTE
WHERE row_num > 1






FROM PortfolioProject.dbo.NashvilleHousing

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--Removing Unused Columns OUT OF PRACTICE I would not use this on raw data--

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress,SaleDate
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate
