/*cleaning data in sql queries*/


select * from portfolioProject.dbo.NashvilleHousing order by 1,2;


--standardize date format

select SaleDate, convert(Date, SaleDate) from portfolioProject.dbo.NashvilleHousing;
update portfolioProject.dbo.NashvilleHousing set SaleDate = CONVERT(Date, SaleDate); 
--above update query does not update SaleDate column as date becoz its is created as datetime in schema

alter table portfolioProject.dbo.NashvilleHousing add SaleDateConverted date;
update portfolioProject.dbo.NashvilleHousing set SaleDate = CONVERT(Date, SaleDate);
--so we made another column as date type and update that whole column 

select SaleDateConverted from portfolioProject.dbo.NashvilleHousing;

---------------------------------------------------------------------------------------------

--Populate property address data


select PropertyAddress from portfolioProject.dbo.NashvilleHousing ;
select [UniqueID ],PropertyAddress from portfolioProject.dbo.NashvilleHousing where PropertyAddress is null;


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from portfolioProject.dbo.NashvilleHousing a 
join 
portfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from portfolioProject.dbo.NashvilleHousing a  join portfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

----------------------------------------------------------------------------------------

--Breaking out address into individual columns (Address, city , state)

select PropertyAddress, 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress))
as address, CHARINDEX(',', PropertyAddress)
from portfolioProject.dbo.NashvilleHousing;

--SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) --address crop
-- CHARINDEX(',', PropertyAddress) -- counted the char till ','

-- removing ',' from the end by using -1 as parameter , we are going to the ','  and coming back from behind using -1
select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as address
from portfolioProject.dbo.NashvilleHousing; 

--   now getting the city
select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress) )as address
from portfolioProject.dbo.NashvilleHousing; 
-- if we take +1 out then we see ',' 



alter table portfolioProject.dbo.NashvilleHousing 
add PropertySplitAddress Nvarchar(255);

update portfolioProject.dbo.NashvilleHousing 
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);


alter table portfolioProject.dbo.NashvilleHousing 
add PropertySplitCity Nvarchar(255);

update portfolioProject.dbo.NashvilleHousing 
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));


--breaking up owner address
select * from portfolioProject.dbo.NashvilleHousing ;


select PARSENAME(OwnerAddress,1) from portfolioProject.dbo.NashvilleHousing ;

select OwnerAddress, 
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)
from portfolioProject.dbo.NashvilleHousing ;



alter table portfolioProject.dbo.NashvilleHousing 
add OwnerSplitAddress Nvarchar(255);

update portfolioProject.dbo.NashvilleHousing 
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3);


alter table portfolioProject.dbo.NashvilleHousing 
add OwnerSplitCity Nvarchar(255);

update portfolioProject.dbo.NashvilleHousing 
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2);

alter table portfolioProject.dbo.NashvilleHousing 
add OwnerSplitState Nvarchar(255);

update portfolioProject.dbo.NashvilleHousing 
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1);

-----------------------------------------------------------------------------------


--change  Y and N to yes and no in "Sold as Vacant" field
select distinct(SoldAsVacant) from portfolioProject.dbo.NashvilleHousing ;

select distinct(SoldAsVacant), count(SoldAsVacant) from portfolioProject.dbo.NashvilleHousing group by SoldAsVacant order by 2 ;

select SoldAsVacant , 
case 
when SoldAsVacant = 'Y' then  'Yes'
when SoldAsVacant = 'N' then  'No'
else SoldAsVacant
end
from portfolioProject.dbo.NashvilleHousing order by SoldAsVacant desc;

update portfolioProject.dbo.NashvilleHousing
set SoldAsVacant = case 
when SoldAsVacant = 'Y' then  'Yes'
when SoldAsVacant = 'N' then  'No'
else SoldAsVacant
end;

-------------------------------------------------------------------------------------------------

--remove duplicates

--finding duplicates
with RowNumCTE AS(
select * , ROW_NUMBER() OVER (
	
	PARTITION BY ParcelID, 
	PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID)row_num

from portfolioProject.dbo.NashvilleHousing
)
Select * from RowNumCTE where row_num > 1
order by PropertyAddress


--deleting duplicates
with RowNumCTE AS(
select * , ROW_NUMBER() OVER (
	
	PARTITION BY ParcelID, 
	PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID)row_num

from portfolioProject.dbo.NashvilleHousing)
Delete from RowNumCTE where row_num > 1


---------------------------------------------------------------------------------------------------------

--DELETE unused columns

select *
from portfolioProject.dbo.NashvilleHousing

alter table portfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table portfolioProject.dbo.NashvilleHousing
drop column SaleDate

