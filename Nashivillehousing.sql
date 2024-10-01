-- Populate Property Address data
select NashvilleHousing.PropertyAddress
from NashvilleHousing
-- where PropertyAddress is null
order by ParcelID

SELECT
    a.ParcelID,
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress,
    COALESCE(a.PropertyAddress, b.PropertyAddress) AS PropertyAddress
FROM
    NashvilleHousing a
JOIN
    NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.`UniqueID` <> b.`UniqueID`
WHERE
    a.PropertyAddress IS NULL;

update NashvilleHousing a
JOIN NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.`UniqueID` <> b.`UniqueID`
set a.PropertyAddress = ifnull(a.PropertyAddress,b.PropertyAddress)
where a.PropertyAddress is null

-----------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, CHAR_LENGTH(PropertyAddress)) AS CityState
FROM
    NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress VARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity VARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,
                                  LOCATE(',', PropertyAddress) + 1,
                                  CHAR_LENGTH(PropertyAddress) - LOCATE(',', PropertyAddress));

Select OwnerAddress
From NashvilleHousing

select
    substring_index(OwnerAddress,',',1) as OwnerSplitAddress,
    substring_index(substring_index(OwnerAddress, ',', 2), ',', -1) as OwnerSplitcity,
    substring_index(OwnerAddress,',',-1) as OwnerSplitstate
From NashvilleHousing

alter table nashvillehousing
Add OwnerSplitAddress varchar(255)

update nashvillehousing
set OwnerSplitAddress  = substring_index(OwnerAddress,',',1);

alter table nashvillehousing
Add OwnerSplitcity varchar(255);

update nashvillehousing
set OwnerSplitcity  =  substring_index(substring_index(OwnerAddress, ',', 2), ',', -1);

alter table nashvillehousing
Add OwnerSplitstate varchar(255);

update nashvillehousing
set OwnerSplitstate = substring_index(OwnerAddress,',',-1)

-- ALTER TABLE NashvilleHousing
-- DROP COLUMN OwnerSplitcity;

select *
from nashvillehousing

-- Change Y and N to Yes and No in "Sold as Vacant" field
select distinct(SoldasVacant),count(SoldAsVacant)
from nashvillehousing
group by SoldasVacant
order by 2

SELECT
    SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END AS VacantStatus
FROM
    nashvillehousing;

UPDATE nashvillehousing
SET SoldAsVacant = CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END;
-----------------------------------------------------------------------
-- Remove Duplicates
WITH RowNumberCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM nashvillehousing
)
DELETE FROM nashvillehousing
WHERE UniqueID IN (
    SELECT UniqueID FROM RowNumberCTE WHERE row_num > 1
);

SELECT ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, COUNT(*)
FROM nashvillehousing
GROUP BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
HAVING COUNT(*) > 1;

-- Delete Unused Columns
select *
From NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;