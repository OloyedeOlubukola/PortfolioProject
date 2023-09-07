-- DATA CLEANING IN SQL 

Select *
From [Project Portfolio].dbo.Nashvile Nashvile	

-- STANDARDIZE DATE FORMAT 

Select SaleDate
From Nashvile

Select SaleDate, CONVERT(Date, SaleDate)
From Nashvile

UPDATE Nashvile
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE Nashvile
Add SalesDateConverted Date;

UPDATE Nashvile
SET SalesDateConverted = CONVERT(Date, SaleDate)

Select SalesDateConverted
From Nashvile


--POPULATE PROPERTY ADDRESS DATA 

 --Find Duplicate 

 SELECT PropertyAddress, ParcelID, COUNT(PropertyAddress), COUNT(ParcelID)
FROM Nashvile
GROUP BY PropertyAddress, ParcelID
HAVING COUNT(PropertyAddress) > 1  


SELECT *
From Nashvile
Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Nashvile a
JOIN Nashvile b
on a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Nashvile a
JOIN Nashvile b
on a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null


 --BREAK OUT PROPERTY ADDRESS INTO COLUMNS (ADDRESS, CITY STATE)


Select
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 ) as Address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)) as Address
 From Nashvile

ALTER TABLE Nashvile
Add PropertySplitAddress Nvarchar(255);

UPDATE Nashvile
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 )
   
   
ALTER TABLE Nashvile
Add PropertySplitCity Nvarchar(255);

UPDATE Nashvile
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress))


 --BREAK OUT OWNER ADDRESS INTO COLUMNS (ADDRESS, CITY STATE)

 Select 
PARSENAME(REPLACE(OwnerAddress , ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress , ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress , ',', '.'), 1)
From Nashvile


ALTER TABLE Nashvile 
Add OwnerSplitAddress Nvarchar(255);

UPDATE Nashvile
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress , ',', '.'), 3)
   
ALTER TABLE Nashvile
Add OwnerSplitCity Nvarchar(255);

UPDATE Nashvile
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress , ',', '.'), 2)

ALTER TABLE Nashvile
Add OwnerSplitState Nvarchar(255);

UPDATE Nashvile
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress , ',', '.'), 1)


--CHANGE Y AND N TO YES AND NO IN "SoldAsVacant" Column
Select Distinct SoldAsVacant, COUNT(SoldAsVacant)
From Nashvile
Group by SoldAsVacant 
Order by 2 


Select SoldAsVacant
,CASE When SoldAsVacant = 'Y' then 'YES'
      When SoldAsVacant = 'N' then 'NO'
      ELSE SoldAsVacant 
      END 
      From Nashvile

UPDATE Nashvile

SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END 

-- REMOVE DUPLICATE 

Select *,
    ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SaleDate,
				 LegalReference
				 ORDER BY
				     UniqueID
					 ) row_num
From Nashvile
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
From Nashvile
)
Select * 
From RowNumCTE
Where row_num > 1

Select *
From Nashvile

--DELETE UNUSED COLUMN 

ALTER TABLE Nashvile 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate 

--MOVE CLEANED DATA TO NEW TABLE 

CREATE TABLE [Project Portfolio].dbo.NashvileNewData (
    
    UniqueID Float(50), ParcelID nvarchar (255), LandUse nvarchar (255), 
	SalesPrice Float (50), LegalRef nvarchar (255), SoldAsVacant nvarchar(255),
	OwnerName nvarchar (255), Acreage Float (50), LandValue Float (50), BuildingValue Float (50),
	TotalValue float (50), YearBuilt Float (50), Bedrooms Float (50), FullBath Float (50), HalfBath Float (50), 
	 SaleDate DATE, PropertyAddress nvarchar (255), PropertyCity nvarchar (255), 
	 OwnerAddress nvarchar (255), OwnerCity nvarchar (255), OwnerState nvarchar (255)
	 );


INSERT INTO [Project Portfolio].dbo.NashvileNewData(
    UniqueID, ParcelID, LandUse, SalesPrice, LegalRef, SoldAsVacant,
    OwnerName, Acreage, LandValue, BuildingValue, TotalValue, YearBuilt,
    Bedrooms, FullBath, HalfBath, SaleDate, PropertyAddress, PropertyCity,
    OwnerAddress, OwnerCity, OwnerState
)

SELECT
     UniqueID , ParcelID, LandUse, SalePrice, LegalReference, SoldAsVacant,
    OwnerName, Acreage, LandValue, BuildingValue, TotalValue, YearBuilt,
    Bedrooms, FullBath, HalfBath, SalesDateConverted, PropertySplitAddress, PropertySplitCity,
    OwnerSplitAddress, OwnerSplitCity, OwnerSplitState

FROM Nashvile

SELECT *
From NashvileNewData

--DROP OLD TABLE IF NEEDED 
DROP TABLE Nashvile