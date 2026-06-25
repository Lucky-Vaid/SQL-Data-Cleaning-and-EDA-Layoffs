-- Exploratory Data

USE  world_layoffs;

SELECT *
FROM layoffs_staging2;
-- Display the cleaned dataset before starting the analysis.

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;
-- Find the highest number of layoffs and the maximum layoff percentage recorded.

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
-- Identify companies that laid off 100% of their workforce,
-- sorted by the amount of funding they had raised.

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;
-- Calculate the total number of layoffs for each company
-- and rank them from highest to lowest.

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;
-- Determine the time period covered by the dataset.

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;
-- Analyze total layoffs across different industries.

SELECT *
FROM layoffs_staging2;
-- Display the cleaned dataset for further exploration.

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;
-- Calculate the total layoffs by country.

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;
-- Analyze yearly layoff trends.

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;
-- Compare layoffs across different funding stages.


SELECT substring(`date`,1,7) as `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;
-- Calculate the total layoffs for each month.


WITH rolling_total AS
(
SELECT substring(`date`,1,7) as `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`,total_off,
SUM(total_off) OVER(ORDER BY `MONTH`) AS Rolling_Total
FROM Rolling_Total;
-- Calculate monthly layoffs and generate a cumulative (running) total
-- to observe how layoffs increased over time.


SELECT company,  YEAR(`date`),  SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company,  YEAR(`date`)
ORDER BY 3 DESC;
-- Calculate the total layoffs for each company by year.


WITH company_year (company,years, total_laid_off) AS
(
SELECT company,  YEAR(`date`),  SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company,  YEAR(`date`)
), company_year_rank AS
(
SELECT *, DENSE_RANK() OVER(PARTITION  BY years ORDER BY total_laid_off DESC) AS Ranking
FROM company_year
WHERE years IS NOT NULL
)
SELECT * 
FROM company_year_rank
WHERE Ranking <= 5;
-- Rank companies by total layoffs within each year
-- and return the top 5 companies with the highest layoffs annually.

