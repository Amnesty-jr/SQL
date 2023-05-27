SELECT *
FROM portfolio.dbo.netflix_tittles


-- I want to standardize my date format
SELECT date_added,
	CONVERT(DATE, date_added) AS new_date
FROM portfolio.dbo.netflix_tittles

UPDATE portfolio.dbo.netflix_tittles
SET new_date = CONVERT(DATE, date_added)

ALTER TABLE portfolio.dbo.netflix_tittles
ADD new_date date


-- Changing the Months From Numbers to Text
SELECT
	  new_date,
	  DATENAME(month, new_date)
FROM portfolio.dbo.netflix_tittles
ORDER BY new_date DESC

ALTER TABLE portfolio.dbo.netflix_tittles
ADD month_of_date NVARCHAR(255)

UPDATE portfolio.dbo.netflix_tittles
SET month_of_date = DATENAME(month, new_date)


-- I want to clean the country table by breaking it out and adding everything into one column
SELECT country,
  PARSENAME(REPLACE(country, ',', '.'), 5),
  PARSENAME(REPLACE(country, ',', '.'), 4),
  PARSENAME(REPLACE(country, ',', '.'), 3),
  PARSENAME(REPLACE(country, ',', '.'), 2),
  PARSENAME(REPLACE(country, ',', '.'), 1)
FROM portfolio.dbo.netflix_tittles
ORDER BY country DESC

ALTER TABLE portfolio.dbo.netflix_tittles
ADD new_country NVARCHAR(255)

UPDATE portfolio.dbo.netflix_tittles
SET new_country =   PARSENAME(REPLACE(country, ',', '.'), 5)

UPDATE portfolio.dbo.netflix_tittles
SET new_country =   PARSENAME(REPLACE(country, ',', '.'), 4)

UPDATE portfolio.dbo.netflix_tittles
SET new_country =   PARSENAME(REPLACE(country, ',', '.'), 3)

UPDATE portfolio.dbo.netflix_tittles
SET new_country =   PARSENAME(REPLACE(country, ',', '.'), 2)

UPDATE portfolio.dbo.netflix_tittles
SET new_country =   PARSENAME(REPLACE(country, ',', '.'), 1)

--i want to clean the new country column by removing the white spaces
UPDATE portfolio.dbo.netflix_tittles
SET new_country = TRIM(new_country)


-- I want to clean the duration table by replacing the nulls with the ones in rating
SELECT rating, duration, ISNULL(duration, rating)
FROM portfolio.dbo.netflix_tittles
WHERE duration is NULL

UPDATE portfolio.dbo.netflix_tittles
SET duration = ISNULL(duration, rating)
FROM portfolio.dbo.netflix_tittles
WHERE duration is NULL


-- I want to check for the diector with the highest Realease
SELECT Top 10 director,
CASE WHEN director = 'RaÃºl Campos, Jan Suter' THEN 'Raul Campos, Jan Suter'
ELSE director
END AS TOP_10_director,
COUNT(director) AS HighestRelease
FROM portfolio.dbo.netflix_tittles
GROUP BY director
ORDER BY COUNT(director) DESC


--I want to determine whether Netflix has been more focused on TV shows or movies
WITH CTE AS(
SELECT DISTINCT(type), COUNT(type) AS amt
FROM portfolio.dbo.netflix_tittles
GROUP BY type
)

SELECT type,
ROUND(((amt)/(SELECT SUM(amt) FROM CTE)),2) * 100 AS Percentage_type
FROM CTE
GROUP BY type, amt
ORDER BY amt DESC

--Determination on the type of Film Released on Netflix
SELECT DISTINCT(type), COUNT(type) AS amt
FROM portfolio.dbo.netflix_tittles
GROUP BY type
ORDER BY amt DESC


-- The month director releases the most
SELECT 
	month_of_date,
	COUNT(month_of_date) AS TotalReleaseInAMonth
FROM portfolio.dbo.netflix_tittles
WHERE month_of_date is NOT NULL
GROUP BY month_of_date
ORDER BY TotalReleaseInAMonth DESC


-- Top 10 countries that produce the most movies
SELECT TOP 10 new_country, COUNT(new_country) AS PopularCountry
FROM portfolio.dbo.netflix_tittles
GROUP BY new_country
ORDER BY PopularCountry DESC


-- The year with more tvshow and movie release in the last 10 years
WITH Highestyear AS(
SELECT DISTINCT(type), release_year,
COUNT(release_year) OVER (PARTITION BY type ORDER BY release_year DESC) AS TotalRelease
FROM portfolio.dbo.netflix_tittles
)

SELECT TOP 20 *
FROM Highestyear
ORDER BY release_year DESC, TotalRelease DESC


-- The Most rating released by Netflix in the last 10 years for movie
WITH Releasedtype AS (
SELECT type, release_year, rating,
COUNT(rating) OVER (PARTITION BY release_year ORDER BY rating) AS PopularRating
FROM portfolio.dbo.netflix_tittles
)

SELECT  DISTINCT(release_year), type, rating, PopularRating
FROM Releasedtype
ORDER BY release_year DESC


--Removing Columns That are not useful
SELECT *
FROM portfolio.dbo.netflix_tittles

ALTER TABLE portfolio.dbo.netflix_tittles
DROP COLUMN date_added, month_of_newdate