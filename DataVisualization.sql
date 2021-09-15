-- Extracting data for visualization on Tableau Public
/*
Queries used for Tableau Project
*/

-- 1. 

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS REAL))/SUM(New_Cases)*100 AS DeathPercentage
FROM CovidDeath
--Where location like '%india%'
WHERE continent IS NOT NULL;
--Group By date

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location

--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date

-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT location, SUM(CAST(new_deaths AS INT)) AS total_death_count
FROM CovidDeath
--Where location like '%india%'
WHERE continent IS NULL 
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY total_death_count DESC;

-- 3.

SELECT location, population, MAX(total_cases) as highest_infection_count,  Max(CAST(total_cases AS REAL)/population)*100 as percent_population_infected
From CovidDeath
--Where location like '%india%'
GROUP BY location, population
ORDER BY percent_population_infected DESC;


-- 4.

SELECT location, population,date, MAX(total_cases) as highest_infected_count,  Max(CAST(total_cases AS REAL)/population)*100 as percent_population_infected
From CovidDeath
--Where location like '%india%'
Group by location, population, date
ORDER BY percent_population_infected DESC