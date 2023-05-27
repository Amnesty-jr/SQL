/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [portfolio].[dbo].[NashvilleHousing]



  -- Cleaning Data in sql
  SELECT *
  FROM portfolio.dbo.NashvilleHousing

  -- Standardize Date Format
  SELECT SalesDateConverted,
  CAST(SaleDate AS date)
  FROM portfolio.dbo.NashvilleHousing

   UPDATE NashvilleHousing
   SET SaleDate = CAST(SaleDate AS date)

   ALTER TABLE NashvilleHousing
   ADD SalesDateConverted Date;

   UPDATE NashvilleHousing
   SET SalesDateConverted = CAST(SaleDate AS date)

   --Populate Property Address
  SELECT *
  FROM portfolio.dbo.NashvilleHousing
  ORDER BY ParcelID

  SELECT a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
  FROM portfolio.dbo.NashvilleHousing a
  JOIN portfolio.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress is Null

	UPDATE a
	SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress) 
	FROM portfolio.dbo.NashvilleHousing a
	JOIN portfolio.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress is Null

	-- Breaking out Address into individual columns(Address, City, State)
  SELECT 
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
  FROM portfolio.dbo.NashvilleHousing

  ALTER TABLE portfolio.dbo.NashvilleHousing
  ADD PropertySplitAddress Nvarchar(255);

  UPDATE portfolio.dbo.NashvilleHousing
  SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

  ALTER TABLE portfolio.dbo.NashvilleHousing
  ADD PropertySplitCity Nvarchar(225)

  UPDATE portfolio..NashvilleHousing
  SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

  SELECT *
  FROM portfolio..NashvilleHousing

  SELECT OwnerAddress
  FROM portfolio..NashvilleHousing
  ORDER BY OwnerAddress DESC

  SELECT 
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
  FROM portfolio..NashvilleHousing
  ORDER BY OwnerAddress DESC

  ALTER TABLE portfolio..NashvilleHousing
  ADD OwnerSplitAddress Nvarchar(255)

  UPDATE portfolio..NashvilleHousing
  SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


  ALTER TABLE portfolio..NashvilleHousing
  ADD OwnerSplitCity Nvarchar(255)

  UPDATE portfolio..NashvilleHousing
  SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

  ALTER TABLE portfolio..NashvilleHousing
  ADD OwnerSplitState Nvarchar(255)

  UPDATE portfolio..NashvilleHousing
  SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

  SELECT *
  FROM portfolio..NashvilleHousing

  -- Change Y & N to Yes and No in "SoldAsVacant" field
  SELECT DISTINCT(SoldAsVacant),
		COUNT(SoldAsVacant)
  FROM portfolio..NashvilleHousing
  GROUP BY SoldAsVacant

  SELECT SoldAsVacant,
  CASE 
  WHEN SoldAsVacant = 'Y' THEN 'Yes'
  WHEN SoldAsVacant = 'N' THEN 'No'
  ELSE SoldAsVacant
  END 
  FROM portfolio..NashvilleHousing
  
  UPDATE portfolio..NashvilleHousing
  SET SoldAsVacant =  CASE 
  WHEN SoldAsVacant = 'Y' THEN 'Yes'
  WHEN SoldAsVacant = 'N' THEN 'No'
  ELSE SoldAsVacant
  END 


  -- Removing Duplicates
WITH RowNumCTE AS(
SELECT *,
  ROW_NUMBER() OVER (
  PARTITION BY ParcelID,
  SalePrice,
  SaleDate,
  LegalReference
  ORDER BY
  UniqueID
  ) AS row_num
FROM portfolio.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1