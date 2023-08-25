  -- Standardize Date Format
  
  ALTER TABLE NashvilleHousing
  Add SaleDateConverted Date;
  
  Update NashvilleHousing
  SET SaleDateConverted =  CONVERT(Date, SaleDate)

  ---------------------------------------------------------------------

-- Update Property Address based on existing data
  
  Select *
  FROM NashvilleHousing
  --Where PropertyAddress IS NULL
  ORDER BY ParcelID

  Select a.UniqueId, b.UniqueId, a.ParcelId, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
  FROM NashvilleHousing a
  JOIN NashvilleHousing b 
  ON a.ParcelID = b.ParcelID
  AND a.UniqueId != b.UniqueId
  WHERE a.PropertyAddress IS NULL

  Update a
  SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
  FROM NashvilleHousing a
  JOIN NashvilleHousing b 
  ON a.ParcelID = b.ParcelID
  AND a.UniqueId != b.UniqueId
  WHERE a.PropertyAddress IS NULL

 ---------------------------------------------------------------------

 -- Split PropertyAddress into Address + City columns.

 Select PropertyAddress
 FROM NashvilleHousing

 SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) AS Address,
 SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) AS Address

 FROM NashvilleHousing

 ALTER TABLE NashvilleHousing
 Add PropertySplitAddress Nvarchar(255);

 Update NashvilleHousing
 SET PropertySplitAddress =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1)

 ALTER TABLE NashvilleHousing
 Add PropertySplitCity Nvarchar(255);

 Update NashvilleHousing
 SET PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

  ---------------------------------------------------------------------

  -- Split Address into multiple columns.

 Select *
 FROM NashvilleHousing
 
 Select 
 PARSENAME(REPLACE(OwnerAddress,',','.'),3),
 PARSENAME(REPLACE(OwnerAddress,',','.'),2),
 PARSENAME(REPLACE(OwnerAddress,',','.'),1)
 FROM Nashvillehousing

 ALTER TABLE NashvilleHousing
 Add OwnerSplitAddress Nvarchar(255);

 Update NashvilleHousing
 SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

 ALTER TABLE NashvilleHousing
 Add OwnerSplitCity Nvarchar(255);

 Update NashvilleHousing
 SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

 ALTER TABLE NashvilleHousing
 Add OwnerSplitState Nvarchar(255);

 Update NashvilleHousing
 SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

 ---------------------------------------------------------------------

 -- Standardize Yes/No notation in "SoldAsVacant" field.

 Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
 FROM NashvilleHousing
 GROUP BY SoldAsVacant
 ORDER BY 2

 Select SoldAsVacant,
	CASE When SoldASVacant = 'Y' THEN 'Yes'
		 When SoldASVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
 FROM NashvilleHousing


 Update NashvilleHousing
 SET SoldAsVacant = CASE When SoldASVacant = 'Y' THEN 'Yes'
		 When SoldASVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END

 ---------------------------------------------------------------------

 -- Remove Duplicates

 WITH RowNumCTE AS(
 Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UNIQUEID
					) row_num

 from NashvilleHousing
 )

 DELETE from RowNumCTE
 Where row_num > 1




