/*

Cleaning Data in SQL

*/


SELECT *
FROM PortfolioProject..NashvilleHousing


-- Change the Sale Date


SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)


-- The above did not update properly so I used the below instead


ALTER TABLE NashvilleHousing
ADD SaleDateConverted date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)


-- Populate Property Address Data


SELECT *
FROM PortfolioProject..NashvilleHousing
-- WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State) using SUBSTRINGs


SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
-- WHERE PropertyAddress is null
-- ORDER BY ParcelID

SELECT
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1) AS Address
, SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1,LEN(PropertyAddress)) AS Address
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1,LEN(PropertyAddress))



-- Breaking out Address into Individual Columns (Address, City, State) using PARSENAME



SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing


SELECT 
PARSENAME(REPLACE(owneraddress, ',', '.') ,3)
,PARSENAME(REPLACE(owneraddress, ',', '.') ,2)
,PARSENAME(REPLACE(owneraddress, ',', '.') ,1)
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(owneraddress, ',', '.') ,3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(owneraddress, ',', '.') ,2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(owneraddress, ',', '.') ,1)


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(soldasvacant), COUNT(soldasvacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY soldasvacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- Remove Duplicates


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY parcelID,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 ORDER BY
					UniqueID
					) row_num
FROM PortfolioProject..NashvilleHousing
--	ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


-- Delete Unused Columns


SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN owneraddress, taxdistrict, propertyaddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN saledate