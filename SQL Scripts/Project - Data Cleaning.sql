-- Data Cleaning 

USE world_layoffs; 
-- Will select the database we wanted to work on.

SET SQL_SAFE_UPDATES = 0;
-- To update and delete the values inside a table.

SELECT *
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null values or blank values
-- 4. Remove Any Columns or rows

CREATE TABLE layoffs_staging
LIKE layoffs;
-- Avoid using original Dataset instead always use duplicate table to practice and in real life.
-- Above query will create copy the table format from the original dataset.

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;
-- This query will copy all the values inside those formatted columns in duplicate table.

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`)
FROM layoffs_staging;
-- Assign a row number within each group of identical records.
-- The first occurrence gets row_num = 1, while any duplicate records receive row_num > 1.

WITH duplicate_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, 
country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;
-- Identify duplicate records before deletion to verify which rows will be removed.
-- Use a CTE to filter and display duplicate records identified using ROW_NUMBER().

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';
-- Check Casper records to identify which rows are actual duplicates. (Dates are same in 2 rows)

WITH duplicate_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, 
country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
DELETE 
FROM duplicate_cte
WHERE row_num > 1;
-- Remove duplicate records identified using ROW_NUMBER().
-- Cannot delete from a CTE in MySQL because it is not an updatable table.


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num`INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
-- Create a separate staging table for data cleaning.
-- Add a permanent 'row_num' column because MySQL cannot delete records directly from a CTE.


SELECT*
FROM layoffs_staging2
WHERE row_num > 1;
-- Verify that the staging table has been created successfully.
-- No records are returned because the table is currently empty.

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, 
country, funds_raised_millions) AS row_num
FROM layoffs_staging;
-- Copy all records from the original table into the staging table
-- while generating and storing row numbers for duplicate detection.


DELETE
FROM layoffs_staging2
WHERE row_num > 1;
-- Delete duplicate records while keeping the first occurrence (row_num = 1).

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;
-- Verify that all duplicate records have been removed.
-- No rows should be returned.

SELECT *
FROM layoffs_staging2;
-- Display the cleaned dataset after removing duplicate records.





-- Standardizing data

SELECT company, trim(company)
FROM layoffs_staging2;
-- Identifying unnecessary leading/trailing spaces.

UPDATE layoffs_staging2
SET company = TRIM(company);
-- Remove leading and trailing spaces from company names.

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;
-- Review all unique industry values to identify inconsistent naming.

SELECT *
FROM layoffs_staging2
where industry = 'Crypto%';
-- Incorrect approach: '=' searches for an exact match and does not support wildcard patterns.

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';
-- Find all records where the industry starts with 'Crypto'.

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';
-- Standardize all Crypto-related industry names into a single value ('Crypto')

SELECT *
FROM layoffs_staging2
WHERE country LIKE 'United States%'
ORDER BY 1;
-- Identify country names with inconsistent formatting (e.g., trailing periods).

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;
-- Compare the original and cleaned country names after removing trailing periods.

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';
-- Remove trailing periods from country names to ensure consistent formatting.

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;
-- Preview the conversion of the date column from text to DATE format.

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
-- Convert all date values from text format to SQL DATE format.

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;
-- Change the data type of the date column from TEXT to DATE.

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
-- Identify records where both layoff count and layoff percentage are missing.

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '' ;
-- Replace blank industry values with NULL for consistent missing-value handling.

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';
-- Display records with missing industry values.

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';
-- Inspect Bally records to determine whether the missing industry can be recovered.

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;
-- Match records from the same company to find available industry values
-- that can be used to fill missing entries.

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry= t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;
-- Fill missing industry values using the existing industry value
-- from another record belonging to the same company.

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
-- Recheck records where both layoff count and percentage are missing
-- before deciding whether to remove them.

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
-- Remove records that contain no layoff information,
-- as they provide no useful analytical value.

SELECT *
FROM layoffs_staging2;
-- Display the final cleaned dataset after all data cleaning steps.

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
-- Remove the helper column used for duplicate detection,
-- as it is no longer required in the cleaned dataset.






