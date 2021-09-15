/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM CovidDeath;

--Selecting data to be used
SELECT location, CovidDeath.date, total_cases, new_cases, total_deaths, population
FROM CovidDeath;

-- looking at total cases vs total deaths
-- shows the likelihood of dying if one gets covid in his country
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS REAL)/total_cases) * 100 AS death_percentage
FROM CovidDeath
WHERE location LIKE '%india%';

-- looking at total cases vs population
SELECT location, date, total_cases, population, (CAST(total_cases AS REAL)/population) * 100 AS case_percentage
FROM CovidDeath
WHERE location LIKE '%india%';

-- looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS Highest_Infection, MAX(CAST(total_cases AS REAL)/population) * 100 AS infection_percentage
FROM CovidDeath
GROUP BY location, population
ORDER BY infection_percentage DESC;
--WHERE location LIKE '%india%'

-- showing the countries with highest death count per population
SELECT location, MAX(CAST(total_deaths as INT)) AS death_count 
FROM CovidDeath
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY death_count DESC;

SELECT location, MAX(CAST(total_deaths as INT)) AS death_count 
FROM CovidDeath
WHERE continent IS NULL
GROUP BY location
ORDER BY death_count DESC;


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) AS total_deaths, SUM(cast(new_deaths AS REAL))/SUM(New_Cases)*100 AS death_percentage
FROM CovidDeath
--Where location like '%states%'
WHERE continent IS NOT NULL ;
--Group By date;



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_count
From CovidDeath dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null ;

--USING CTE

WITH pop_vac(continent, location, date, population, new_vaccinations, rolling_count)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_count
From CovidDeath dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
);
SELECT *, (CAST(rolling_count AS REAL)/population)*100 AS vaccinated_population
FROM pop_vac;


--TEMP TABLE
DROP TABLE IF EXISTS PercentPopVaccinated;
CREATE TEMP TABLE IF NOT EXISTS PercentPopVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_count REAL
);

Insert into PercentPopVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_count
From CovidDeath dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;

Select *, (rolling_count/population)*100 AS vaccinated_percentage 
From PercentPopVaccinated ;


--Creating views for visualization
CREATE VIEW PercentPopVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_count
From CovidDeath dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;