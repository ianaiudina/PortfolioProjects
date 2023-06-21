SELECT * 
FROM CovidDeaths
ORDER BY 3,4

SELECT * 
FROM CovidVaccinations
ORDER BY 3,4


-- Select data that I'm going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2


-- Comparing Total Cases and Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM CovidDeaths
ORDER BY 1,2

-- Doing the same but focusing on Canada

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM CovidDeaths
WHERE location = 'Canada'
ORDER BY 1,2


-- Comparing Total Cases and Population. Find out what % of population contracted COVID-19.

SELECT location, date, population, total_cases, (total_cases/population)*100 AS contracted_percentage
FROM CovidDeaths
WHERE location ='Canada'
ORDER BY 1,2


-- Selecting countries with the highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS highest_infection_count, 
	MAX((total_cases/population)*100) AS contracted_percentage
FROM CovidDeaths
GROUP BY location, population
ORDER BY contracted_percentage DESC


-- Selecting the countries with the highest death count per population

SELECT location, MAX(cast(total_deaths as int)) AS total_death_count
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count DESC



-- CONTINENT BREAKDOWN

-- Showing the continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS total_death_count
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC

-- Alternative:

SELECT location, MAX(cast(total_deaths as int)) AS total_death_count
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC



-- GLOBAL BREAKDOWN

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, 
	   SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


-- Join the two tables together and use CTE
-- Looking at the total population vs. vaccinated population

WITH pop_vs_vacc (continent, location, date, population, new_vacc, rolling_vacc)
AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS int)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_vacc
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location 
	AND d.date = v.date
WHERE d.continent IS NOT NULL
)
SELECT *, (rolling_vacc/population)*100 FROM pop_vs_vacc ORDER BY 2,3


-- Use Temp Table

DROP TABLE IF EXISTS #PercentPopVacc
CREATE TABLE #PercentPopVacc
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vacc numeric,
rolling_vacc numeric
)

INSERT INTO #PercentPopVacc
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS int)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_vacc
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location 
	AND d.date = v.date
WHERE d.continent IS NOT NULL

SELECT *, (rolling_vacc/population)*100 FROM #PercentPopVacc ORDER BY 2,3




-- Create a view

CREATE VIEW PercentPopVacc AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS int)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_vacc
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location 
	AND d.date = v.date
WHERE d.continent IS NOT NULL


SELECT *
FROM PercentPopVacc
