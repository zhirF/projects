--seeing what the data look like
select * from housing

--standardizing the dateformat
select SaleDate,convert(Date,SaleDate) as sale_date
from housing 

alter table housing
add sale_date_proper Date

update housing 
set sale_date_proper=convert(Date,SaleDate)
select Sale_date_proper
from housing

alter table housing
drop column saledate 

select * from housing


--populate property address data
select * from housing where PropertyAddress is null

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.propertyaddress,b.PropertyAddress) 
from housing a join housing b
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=ISNULL(a.propertyaddress,b.PropertyAddress)
from housing a join housing b 
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


--breaking out address to individual columns (address,city,state)
select propertyaddress 
from housing

select 
SUBSTRING(propertyaddress,1,charindex(',',propertyaddress)-1) as address
,SUBSTRING(propertyaddress,charindex(',',propertyaddress)+1,len(PropertyAddress)) as address
from housing

alter table housing
add property_split_address nvarchar(255)

update housing 
set property_split_address=SUBSTRING(propertyaddress,1,charindex(',',propertyaddress)-1)

alter table housing
add property_split_city nvarchar(255)
update housing 
set property_split_city=SUBSTRING(propertyaddress,charindex(',',propertyaddress)+1,len(PropertyAddress))

select * from housing


select OwnerAddress from housing

select 
PARSENAME(replace(owneraddress,',','.'),3),
PARSENAME(replace(owneraddress,',','.'),2),
PARSENAME(replace(owneraddress,',','.'),1)
from housing


alter table housing
add owner_split_address nvarchar(255)
update housing 
set owner_split_address=PARSENAME(replace(owneraddress,',','.'),3)

alter table housing
add owner_split_city nvarchar(255)
update housing 
set owner_split_city=PARSENAME(replace(owneraddress,',','.'),2)

alter table housing
add owner_split_state nvarchar(255)
update housing 
set owner_split_state=PARSENAME(replace(owneraddress,',','.'),1)



--change Y and N in 'Sold as Vacant' field

select distinct(soldasvacant), count(soldasvacant)
from housing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No'
else SoldAsVacant
end
from housing

update housing
set SoldAsVacant=case when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No'
else SoldAsVacant
end


--remove duplicates
with row_num_cte as(
select * ,
ROW_NUMBER() over (
partition by parcelID,
propertyaddress,
saleprice,
sale_date_proper,
legalreference
order by uniqueid) row_num
from housing
)
delete 
from row_num_cte
where row_num >1

with row_num_cte as(
select * ,
ROW_NUMBER() over (
partition by parcelID,
propertyaddress,
saleprice,
sale_date_proper,
legalreference
order by uniqueid) row_num
from housing
)
select *
from row_num_cte
where row_num >1
--DONE!!!



--and delete unused columns
select * from housing

alter table housing
drop column owneraddress,propertyaddress

--THE END(-_-)

