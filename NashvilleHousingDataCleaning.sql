
-- CLEANING DATA USING SQL QUERIES 

Select * 
From DataCleaning.dbo.NashvilleHousing

-- Standardize Date Format 

-- Format Sale Date Using Update 

Select SaleDate, Convert(Date, SaleDate)
From DataCleaning.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date, SaleDate)

Select SaleDate
From DataCleaning.dbo.NashvilleHousing

-- Format Sale Date Using Alter 

Alter Table NashvilleHousing 
Add ConvertedSaleDate Date; 

Update NashvilleHousing
Set ConvertedSaleDate = Convert(Date, SaleDate)

Select ConvertedSaleDate
From DataCleaning.dbo.NashvilleHousing

-- Populate Property Adress Data 

Select *
From DataCleaning.dbo.NashvilleHousing
Order by ParcelID

-- (When ParcelID is the same for two rows, Property Adress, if null, is populated with the 
-- non-null Property Adress of the same ParcelID)

Select dc1.ParcelID, dc1.PropertyAddress, dc2.ParcelID, dc2.PropertyAddress 
From DataCleaning.dbo.NashvilleHousing as dc1
Join DataCleaning.dbo.NashvilleHousing as dc2
	On dc1.ParcelID = dc2.ParcelID
	and dc1.[UniqueID ] <> dc2.[UniqueID ]
Where dc1.PropertyAddress is null

Select dc1.ParcelID, dc1.PropertyAddress, dc2.ParcelID, dc2.PropertyAddress, ISNULL(dc1.PropertyAddress, dc2.PropertyAddress)
From DataCleaning.dbo.NashvilleHousing as dc1
Join DataCleaning.dbo.NashvilleHousing as dc2
	On dc1.ParcelID = dc2.ParcelID
	and dc1.[UniqueID ] <> dc2.[UniqueID ]
Where dc1.PropertyAddress is null

Update dc1
Set PropertyAddress = ISNULL(dc1.PropertyAddress, dc2.PropertyAddress)
From DataCleaning.dbo.NashvilleHousing as dc1
Join DataCleaning.dbo.NashvilleHousing as dc2
	On dc1.ParcelID = dc2.ParcelID
	and dc1.[UniqueID ] <> dc2.[UniqueID ]
Where dc1.PropertyAddress is null

-- Breaking Address into Individual Columns (Address, City) 

Select PropertyAddress
From DataCleaning.dbo.NashvilleHousing

Select 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
	TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress))) as City
From DataCleaning.dbo.NashvilleHousing

Alter Table NashvilleHousing 
Add SplitAddress nvarchar(255); 

Update NashvilleHousing
Set SplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

Alter Table NashvilleHousing 
Add SplitCity nvarchar(255); 

Update NashvilleHousing
Set SplitCity = TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress)))

Select SplitAddress, SplitCity 
From DataCleaning.dbo.NashvilleHousing

-- Breaking Owner Address into Individual Columns (Address, City, State)

Select OwnerAddress 
From DataCleaning.dbo.NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3) as Address,
PARSENAME(Replace(OwnerAddress, ',', '.'), 2) as City,
PARSENAME(Replace(OwnerAddress, ',', '.'), 1) as State
From DataCleaning.dbo.NashvilleHousing

Alter Table NashvilleHousing 
Add SplitOwnerAddress nvarchar(255); 

Alter Table NashvilleHousing 
Add SplitOwnerCity nvarchar(255); 

Alter Table NashvilleHousing 
Add SplitOwnerState nvarchar(255);

Update NashvilleHousing
Set SplitOwnerAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Update NashvilleHousing
Set SplitOwnerCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Update NashvilleHousing
Set SplitOwnerState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Select SplitOwnerAddress, SplitOwnerCity, SplitOwnerState
From DataCleaning.dbo.NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant"

Select Distinct(SoldAsVacant), count(SoldAsVacant)
From DataCleaning.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE 
	When SoldAsVacant = 'Y' THEN 'YES'
	When SoldAsVacant = 'N' THEN 'NO' 
	Else SoldAsVacant 
END 
From DataCleaning.dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = 
CASE 
	When SoldAsVacant = 'Y' THEN 'YES'
	When SoldAsVacant = 'N' THEN 'NO' 
	Else SoldAsVacant 
END
From DataCleaning.dbo.NashvilleHousing

-- Remove Duplicates 

WITH RowNumCTE AS(
Select *,
	Row_number() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From DataCleaning.dbo.NashvilleHousing
)

Select *   
from RowNumCTE
Where row_num > 1  

--DELETE  
--from RowNumCTE
--Where row_num > 1 


-- Delete Unused Columns 

Select * 
From DataCleaning.dbo.NashvilleHousing

Alter Table DataCleaning.dbo.NashvilleHousing
Drop Column PropertyAddress, OwnerAddress, SaleDate, TaxDistrict 






