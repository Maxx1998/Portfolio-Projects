SELECT * FROM [Nashville Housing Data]

--Standardize Date Format

SELECT SaleDate,CONVERT(DATE,SaleDate)
FROM [Nashville Housing Data]


ALTER TABLE [Nashville Housing Data]
ADD SaleDateCoverted DATE

UPDATE [Nashville Housing Data]
SET SaleDateCoverted=CONVERT(DATE,SaleDate)

SELECT *
FROM [Nashville Housing Data]

--Populate Property Address Data

SELECT *
FROM [Nashville Housing Data]
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID



SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Nashville Housing Data] a
JOIN [Nashville Housing Data] b
ON a.ParcelID=b.parcelID
AND a.UniqueID<>b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Nashville Housing Data] a
JOIN [Nashville Housing Data] b
ON a.ParcelID=b.parcelID
AND a.UniqueID<>b.UniqueID
WHERE a.PropertyAddress IS NULL



SELECT *
FROM [Nashville Housing Data]
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

--Breaking Out Address into Individual Columns (Address,City,State)

SELECT PropertyAddress
FROM [Nashville Housing Data]
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID


SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM [Nashville Housing Data]


ALTER TABLE [Nashville Housing Data]
ADD PropertySplitAddress VARCHAR(255)

UPDATE [Nashville Housing Data]
SET PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

ALTER TABLE [Nashville Housing Data]
ADD PropertySplitCity VARCHAR(255)

UPDATE [Nashville Housing Data]
SET PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) 


SELECT * FROM [Nashville Housing Data]

SELECT OwnerAddress 
FROM [Nashville Housing Data]

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [Nashville Housing Data]

ALTER TABLE [Nashville Housing Data]
ADD OwnerSplitAddress VARCHAR(255)

UPDATE [Nashville Housing Data]
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE [Nashville Housing Data]
ADD OwnerSplitCity VARCHAR(255)

UPDATE [Nashville Housing Data]
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE [Nashville Housing Data]
ADD OwnerSplitState VARCHAR(255)

UPDATE [Nashville Housing Data]
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT * FROM [Nashville Housing Data ]


--Change 1 and 0 to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT(SoldAsVacant) 
FROM [Nashville Housing Data ]

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant=1 THEN 'Yes'
WHEN SoldAsVacant=0 THEN 'No'
END
FROM [Nashville Housing Data ]




ALTER TABLE [Nashville Housing Data]
ADD SoldAsVacantUpdated VARCHAR(50)


UPDATE [Nashville Housing Data]
SET SoldAsVacantUpdated=
CASE WHEN SoldAsVacant=1 THEN 'Yes'
WHEN SoldAsVacant=0 THEN 'No'
END


SELECT SoldAsVacant,SoldAsVacantUpdated
FROM [Nashville Housing Data]


--Remove Duplicates


WITH RowNumCTE AS(
SELECT * ,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				  UniqueID
				  ) row_num
FROM [Nashville Housing Data]
--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num>1
ORDER BY PropertyAddress

--Delete Unused Columns

SELECT *
FROM [Nashville Housing Data ]

ALTER TABLE [Nashville Housing Data ]
DROP COLUMN OwnerAddress,PropertyAddress,SaleDate,TaxDistrict