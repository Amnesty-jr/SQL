SELECT *
FROM portfolio.dbo.CovidDeaths
WHERE continent is not null
order by 3,4

-- I am going to select data tha I would be using

SELECT location,
		date,
		total_cases,
		new_cases,
		total_deaths,
		population

FROM portfolio.dbo.CovidDeaths

WHERE continent is not null

ORDER BY 1,2


-- Total Cases Vs Total Deaths

SELECT location,
		date,
		total_cases,
		total_deaths,
		(total_deaths/total_cases) * 100 AS death_percentage

FROM portfolio.dbo.CovidDeaths

WHERE continent is not null

ORDER BY 1,2

-- Total Cases Vs Population

SELECT location,
		date,
		total_cases,
		population,
		(total_cases/population) * 100 AS patient_percentage

FROM portfolio.dbo.CovidDeaths

WHERE continent is not null

ORDER BY 1,2

-- Countries with the Highhest Infection Rate 
SELECT location,
		MAX(total_cases) AS max_infection,
		population,
		MAX((total_cases/population)) * 100 AS patient_percentage

FROM portfolio.dbo.CovidDeaths

WHERE continent is not null

GROUP BY location,
		population

ORDER BY 4

-- Highest Death Count Per Population (location)
SELECT location,
		MAX(CAST(total_deaths AS int)) AS count_of_totaldeath

FROM portfolio.dbo.CovidDeaths

WHERE continent is not null

GROUP BY location
		
ORDER BY count_of_totaldeath desc

-- Highest Death Count Per Population (continent)
SELECT location,
		MAX(CAST(total_deaths AS int)) AS count_of_totaldeath

FROM portfolio.dbo.CovidDeaths

WHERE continent is not null

GROUP BY location
		
ORDER BY count_of_totaldeath desc

--showing continent with highest death count

--global numbers
SELECT
		date,
		SUM(new_cases) AS total_cases,
		SUM(CAST(new_deaths AS int)) AS  total_deaths,
		SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS death_percentage

FROM portfolio.dbo.CovidDeaths

WHERE continent is not null

GROUP BY date

ORDER BY 1,2

--death percentage over the world

SELECT
		SUM(new_cases) AS total_cases,
		SUM(CAST(new_deaths AS int)) AS  total_deaths,
		SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS death_percentage

FROM portfolio.dbo.CovidDeaths

WHERE continent is not null

ORDER BY 1,2

-- JOINING THE TWO TABLES
-- Total Population Vs Vaccination
SELECT dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea. date) AS cum_people_vacinnated

FROM portfolio.dbo.CovidDeaths AS dea
JOIN portfolio.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	 AND dea.date = vac.date

WHERE dea.continent is not null

ORDER BY 2,3


--USING A CTE because we want to divide the new column (cum_people vaccinated) but it's going to bring out an error cause it's a new column

WITH popvsvac(continent,location,date,population,new_vaccinations,cum_people_vacinnated)
AS
(
SELECT dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea. date) AS cum_people_vacinnated

FROM portfolio.dbo.CovidDeaths AS dea
JOIN portfolio.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	 AND dea.date = vac.date

WHERE dea.continent is not null

-- ORDER BY 2,3
)

SELECT *, (cum_people_vacinnated/population)*100 as percentage_vaccinated
FROM popvsvac


--TEMP TABLE

DROP TABLE IF EXISTS #percentagepopvac
CREATE TABLE #percentagepopvac
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
cum_people_vacinnated numeric
)

INSERT INTO #percentagepopvac
SELECT dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea. date) AS cum_people_vacinnated

FROM portfolio.dbo.CovidDeaths AS dea
JOIN portfolio.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	 AND dea.date = vac.date

--WHERE dea.continent is not null

-- ORDER BY 2,3

SELECT *, (cum_people_vacinnated/population)*100 as percentage_vaccinated
FROM #percentagepopvac


-- Creating view to store data for later visualization

CREATE VIEW percentagepopvac AS
SELECT dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea. date) AS cum_people_vacinnated

FROM portfolio.dbo.CovidDeaths AS dea
JOIN portfolio.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	 AND dea.date = vac.date

WHERE dea.continent is not null

-- ORDER BY 2,3

select *
from percentagepopvac


/*
Queries used for Tableau Project
*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc