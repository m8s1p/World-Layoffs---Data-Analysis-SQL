-- Exploratory Data Analysis
# Usually executed with a particular goal or defined outcome

SELECT *
FROM layoffs_staging2;


SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;
# Gives us the total number of employees laid off, and percentage, across all companies


SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;
# Returns all the companies that laid of 100% of there staff (1 = 100% in mysql), i.e. the company folded
# ordered by total laid off in descending order

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
# The same as above but ordered by funds raised


SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;
# Returns the total number of employees laid off by company, in descending order


SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;
# Shows the date range of the data


-- Can use the same quesry from above to check other data relating to the total_laid_off
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;
# By Industry

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;
# By Country

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;
# By Year. NB date is written as `date`, as this is a keyord in mysql
# Ordered by the dtae column - the number in the order line can be either column/field name or its number

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;
# On the stage the business is at


SELECT company, AVG(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;
# Can look at percentage of laid off but doesn't really give us any usable data


-- Can use a rolling sum to find the progression of layoffs over time

SELECT SUBSTRING(`date`,6,2) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `MONTH`
;
# This doesn't work as it just shows a months but each year is grouped together

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
;
# Now returns individual months and put in ascending order which we can then use in a CTE

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off,
SUM(total_off) OVER(ORDER BY `MONTH`) as rolling_total
FROM Rolling_Total;
# With the previous query as a CTE, we can now query that data and find the rolling total, by month,
# over the whole date range of the data


-- Building on the above we can go back and add the coutry column to breakdown the rolling figure
# even further
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off), country
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`, country
ORDER BY 1 ASC
;
# This is the query to be used in the CTE

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off, country
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`, country
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off, country,
SUM(total_off) OVER(ORDER BY `MONTH`, country) as rolling_total
FROM Rolling_Total
WHERE total_off IS NOT NULL
AND `MONTH` = '2020-05'
;
# The complete query using a CTE. NB ORDER BY in the OVER function - add further columns to 
# order on more than one field and we can further limit it to just one month


-- We want to break down the below query by year
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC
;
# Query to be used in CTE

WITH company_year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), 
Company_Year_Rank AS
(
SELECT *, 
DENSE_RANK() OVER (PARTITION BY  years ORDER BY total_laid_off DESC) AS Ranking
FROM company_year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE ranking <= 5
;
# Ny chaining 2 CTEs together we can show the top 5 companies, by year, of number of employees laid
# off and by how many.  NB we used the first CTE so that we could query on the results, we then used the
# second CTE so that we could filter the data






