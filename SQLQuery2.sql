/*

Cleaning data in SQL queries

*/

--standerdise the date format

select SaleDate ,CONVERT(Date,SaleDate)

from Nashvillehouse

Update Nashvillehouse set SaleDate = convert(Date,SaleDate)

select * from Nashvillehouse

Alter table  Nashvillehouse add SalesDateConverted Date; 

Update Nashvillehouse SET SalesDateConverted = convert(Date,SaleDate)


--PROPERTY ADDRESS 
SELECT PropertyAddress from Nashvillehouse where PropertyAddress is null


select * from Nashvillehouse order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress from Nashvillehouse a
JOIN Nashvillehouse b
ON a.ParcelID = b.ParcelID
AND
a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress) from Nashvillehouse a
JOIN Nashvillehouse b
ON a.ParcelID = b.ParcelID
AND
a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

update	a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from Nashvillehouse a
JOIN Nashvillehouse b
ON a.ParcelID = b.ParcelID
AND
a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

--BREAKING OUT THE ADDRESS INTO	INDIVIDUAL COLUMNS(ADDRESS,CITY,STATE)

SELECT PropertyAddress from Nashvillehouse

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)) AS ADDRESS FROM Nashvillehouse

--CHARINDEX RETURNS THE INT VALUE /PUT -1 TO REMOVE THE (,)

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS ADDRESS
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS ADDRESS
FROM Nashvillehouse


Alter table Nashvillehouse ADD NewPropertySplitAddress nvarchar(255)

Update Nashvillehouse set NewPropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)


Alter table Nashvillehouse ADD PropertySplitcity nvarchar(255);
Update Nashvillehouse set PropertySplitcity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT * from Nashvillehouse


select OwnerAddress from Nashvillehouse

select PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Nashvillehouse


Alter table Nashvillehouse ADD OwnerSplitAddress nvarchar(255)
Update Nashvillehouse SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter table Nashvillehouse ADD OwnerSplitCity nvarchar(255)
Update Nashvillehouse SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter table Nashvillehouse ADD OwnerSplitState nvarchar(255)
update Nashvillehouse SET OwnerSplitState =PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Change Y and N to YES and NO in "Sold As vacant field"
	select * from Nashvillehouse

	select SoldAsVacant,COUNT(SoldAsVacant) 
	FROM Nashvillehouse group by SoldAsVacant 
	order by 2

	select SoldAsVacant
	, CASE when SoldAsVacant ='Y' THEN  'YES'
	       when SoldASVacant = 'N' THEN 'NO'
		   ELSE SoldAsVacant
		   END
	   FROM Nashvillehouse

--UPDATE THE TABLE

	  Update Nashvillehouse
	    SET SoldAsVacant = CASE when SoldAsVacant ='Y' THEN 'YES'
		when SoldASVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END

--REMOVE DUPLICATES


 WITH RowNumCTE AS(
  Select *,ROW_NUMBER() OVER(
        PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY UniqueID 
		)row_num
		from Nashvillehouse 
		--ORDER BY ParcelID
	)

	select * from RowNumCTE
	where row_num > 1
	order by PropertyAddress

	--Delete the duplicates

		WITH RowNumCTE AS(
	  Select *,ROW_NUMBER() OVER(
			PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY UniqueID 
			)row_num
			from Nashvillehouse 
			--ORDER BY ParcelID
		)

		Delete from RowNumCTE
	where row_num > 1
	--order by PropertyAddress


	--Delete unused columns

		select * from Nashvillehouse

		ALTER TABLE Nashvillehouse DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress
		ALTER TABLE Nashvillehouse DROP COLUMN SALEDATE

