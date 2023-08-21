
-- Data Cleaning In SQL

Select *
From [Project Portfolio].dbo.NashvileHousing NashvileHousing


-- Standardize Date Format


Select SaleDateconverted, CONVERT (Date, SaleDate)
From [Project Portfolio].dbo.[NashvileHousing ]


Update [Project Portfolio].dbo.[NashvileHousing ]
SET SaleDate = CONVERT (Date, SaleDate)

ALTER TABLE [Project Portfolio].dbo.[NashvileHousing] 
Add SaleDateConverted Date;

Update [Project Portfolio].dbo.[NashvileHousing ]
SET SaleDateConverted = CONVERT (Date, SaleDate)


-- Populate Property Address Data 

Select PropertyAddress
from [Project Portfolio].dbo.[NashvileHousing ]



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress , ISNULL(a.Propertyaddress, b.Propertyaddress)
from [Project Portfolio].dbo.[NashvileHousing ] a
JOIN [Project Portfolio].dbo.[NashvileHousing ] b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a 
SET PropertyAddress =ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Project Portfolio].dbo.[NashvileHousing ] a
JOIN [Project Portfolio].dbo.[NashvileHousing ] b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--Breaking out Address into individual column (State, City, Address)


Select PropertyAddress
from [Project Portfolio].dbo.[NashvileHousing ]


Select
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 ) as Address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)) as Address

From [Project Portfolio].dbo.[NashvileHousing ]

ALTER TABLE [Project Portfolio].dbo.[NashvileHousing] 
Add PropertySplitAddress Nvarchar(255);

UPDATE [Project Portfolio].dbo.[NashvileHousing ]
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 )
   
   
ALTER TABLE [Project Portfolio].dbo.[NashvileHousing] 
Add PropertySplitCity Nvarchar(255);

UPDATE [Project Portfolio].dbo.[NashvileHousing ]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress))


Select OwnerAddress
From [Project Portfolio].dbo.[NashvileHousing ]

Select 
PARSENAME(REPLACE(OwnerAddress , ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress , ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress , ',', '.'), 1)
From [Project Portfolio].dbo.[NashvileHousing ]


ALTER TABLE [Project Portfolio].dbo.[NashvileHousing] 
Add OwnerSplitAddress Nvarchar(255);

UPDATE [Project Portfolio].dbo.[NashvileHousing ]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress , ',', '.'), 3)
   
ALTER TABLE [Project Portfolio].dbo.[NashvileHousing] 
Add OwnerSplitCity Nvarchar(255);

UPDATE [Project Portfolio].dbo.[NashvileHousing ]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress , ',', '.'), 2)

ALTER TABLE [Project Portfolio].dbo.[NashvileHousing] 
Add OwnerSplitState Nvarchar(255);

UPDATE [Project Portfolio].dbo.[NashvileHousing ]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress , ',', '.'), 1)

--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct (SoldAsVacant), Count(SoldAsVacant)
From [Project Portfolio].dbo.[NashvileHousing ]
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END 
From [Project Portfolio].dbo.[NashvileHousing ]


UPDATE [NashvileHousing ]
 SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END 

	  -- Remove Duplicates 

Select *,
    ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SaleDate,
				 LegalReference
				 ORDER BY
				     UniqueID
					 ) row_num
From [Project Portfolio].dbo.[NashvileHousing ] 
order by ParcelID


-- Using CTE 

WITH RowNumCTE AS (
Select *,
    ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SaleDate,
				 LegalReference
				 ORDER BY
				     UniqueID
					 ) row_num
From [Project Portfolio].dbo.[NashvileHousing ] 
)
DELETE
From RowNumCTE
Where row_num > 1


-- Delete Unused Columns

Select *
from [Project Portfolio].dbo.[NashvileHousing ]

ALTER TABLE [Project Portfolio].dbo.[NashvileHousing ]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE [Project Portfolio].dbo.[NashvileHousing ]
DROP COLUMN SaleDate 


-- Move Cleaned Data To A New Table 

CREATE TABLE [Project Portfolio].dbo.NewNashvileHousing (
    
    UniqueID Float(50), ParcelID nvarchar (255), LandUse nvarchar (255), 
	SalesPrice Float (50), LegalRef nvarchar (255), SoldAsVacant nvarchar(255),
	OwnerName nvarchar (255), Acreage Float (50), LandValue Float (50), BuildingValue Float (50),
	TotalValue float (50), YearBuilt Float (50), Bedrooms Float (50), FullBath Float (50), HalfBath Float (50), 
	 SaleDate DATE, PropertyAddress nvarchar (255), PropertyCity nvarchar (255), 
	 OwnerAddress nvarchar (255), OwnerCity nvarchar (255), OwnerState nvarchar (255)
);

INSERT INTO [Project Portfolio].dbo.NewNashvileHousing (
    UniqueID, ParcelID, LandUse, SalesPrice, LegalRef, SoldAsVacant,
    OwnerName, Acreage, LandValue, BuildingValue, TotalValue, YearBuilt,
    Bedrooms, FullBath, HalfBath, SaleDate, PropertyAddress, PropertyCity,
    OwnerAddress, OwnerCity, OwnerState
)
SELECT
    UniqueID, ParcelID, LandUse, SalePrice, LegalReference, SoldAsVacant,
    OwnerName, Acreage, LandValue, BuildingValue, TotalValue, YearBuilt,
    Bedrooms, FullBath, HalfBath, SaleDateConverted, PropertySplitAddress, PropertySplitCity,
    OwnerSplitAddress, OwnerSplitCity, OwnerSplitState

FROM [Project Portfolio].dbo.[NashvileHousing];

Select * 

From [Project Portfolio].dbo.NewNashvileHousing


-- Drop the old table if needed
DROP TABLE [Project Portfolio].dbo.[NashvileHousing];

