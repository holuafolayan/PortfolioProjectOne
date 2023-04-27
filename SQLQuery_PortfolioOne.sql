SELECT *
FROM ProjectPortfolio..CovidDeath$

SELECT *
FROM ProjectPortfolio..Vaccine$


--Total Cases vs Death

SELECT Location, date, total_cases, total_deaths, CAST (total_deaths AS decimal)/ CAST (total_cases AS decimal) *100 as Death_Percent
FROM ProjectPortfolio..CovidDeath$
ORDER BY 1,2

---Death_percentage--Total_death against Total_cases 
SELECT Location, date, total_cases, total_deaths, CAST (total_deaths AS decimal)/ CAST (total_cases AS decimal) *100 as Death_Percent
FROM ProjectPortfolio..CovidDeath$
WHERE location like 'Nigeria'
ORDER BY 1,2

--Population_Infected Total_cases against Population 
SELECT Location, date, total_cases, population, CAST (total_cases AS decimal)/ CAST (population AS decimal) *100 as Population_Infected
FROM ProjectPortfolio..CovidDeath$
ORDER BY 1,2

-- Population_Infected--Total/Population 

SELECT Location, population, MAX (total_cases) AS Highest, MAX (total_cases/population) AS Population_Infected
FROM ProjectPortfolio..CovidDeath$
WHERE Continent IS NOT NULL
GROUP BY location, population
ORDER BY  Population_Infected DESC

SELECT Location, MAX (total_cases) AS Highest, MAX (total_cases/population) AS Population_Infected
FROM ProjectPortfolio..CovidDeath$
WHERE Continent IS NOT NULL
GROUP BY location
ORDER BY  Population_Infected DESC

SELECT Location, MAX (total_cases) AS Highest, MAX (total_cases/population) AS Population_Infected
FROM ProjectPortfolio..CovidDeath$
WHERE Continent IS NULL
GROUP BY location
ORDER BY  Population_Infected DESC

SELECT continent, MAX (total_cases) AS Highest, MAX (total_cases/population) AS Population_Infected
FROM ProjectPortfolio..CovidDeath$
WHERE Continent IS NULL
GROUP BY continent
ORDER BY  Population_Infected DESC

SELECT continent, MAX (total_cases) AS Highest, MAX (total_cases/population) AS Population_Infected
FROM ProjectPortfolio..CovidDeath$
WHERE Continent IS not NULL
GROUP BY continent
ORDER BY  Population_Infected DESC



SET ANSI_WARNINGS OFF
GO

SELECT date , SUM(new_cases) as total_cases, SUM(CAST (new_deaths AS int)) as total_death, SUM(CAST (new_deaths AS int))/ SUM(NULLIF (new_cases,0)) *100 AS Death_percent
FROM ProjectPortfolio..CovidDeath$
WHERE new_cases IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as total_cases, SUM(CAST (new_deaths AS int)) as total_death, SUM(CAST (new_deaths AS int))/ SUM(NULLIF (new_cases,0)) *100 AS Global_report
FROM ProjectPortfolio..CovidDeath$
WHERE new_cases IS NOT NULL
ORDER BY 1,2

--JOINING Death and Vaccine Tables

SELECT * 
FROM ProjectPortfolio..CovidDeath$ CDS
JOIN ProjectPortfolio..Vaccine$ VAC
ON CDS.location = VAC.location
AND CDS.date=VAC.date

--Total Death Vs Vaccinantion 
SELECT CDS.continent, CDS.location, CDS.date, CDS.population, VAC.new_vaccinations
FROM ProjectPortfolio..CovidDeath$ CDS
JOIN ProjectPortfolio..Vaccine$ VAC
ON CDS.location = VAC.location
AND CDS.date=VAC.date
WHERE CDS.continent IS NOT NULL 
ORDER BY 1,2,3

SELECT CDS.continent, CDS.location, CDS.date, CDS.population, VAC.new_vaccinations, SUM (CAST(VAC.new_vaccinations AS BIGINT)) OVER (PARTITION BY CDS.location)
FROM ProjectPortfolio..CovidDeath$ CDS
JOIN ProjectPortfolio..Vaccine$ VAC
ON CDS.location = VAC.location
AND CDS.date=VAC.date
WHERE CDS.continent IS NOT NULL 
ORDER BY 1,2,3


SELECT CDS.continent, CDS.location, CDS.date, CDS.population, VAC.new_vaccinations, SUM (CAST(VAC.new_vaccinations AS BIGINT)) OVER (PARTITION BY CDS.location) AS Rolling_Vac
FROM ProjectPortfolio..CovidDeath$ CDS
JOIN ProjectPortfolio..Vaccine$ VAC
ON CDS.location = VAC.location
AND CDS.date=VAC.date
WHERE CDS.continent IS NOT NULL 
ORDER BY 2,3

--USE CTE 

With PopVac (continent,location,date,population,new_vaccinations, Rolling_Vac) AS
(
SELECT CDS.continent, CDS.location, CDS.date, CDS.population, VAC.new_vaccinations, SUM (CAST(VAC.new_vaccinations AS BIGINT)) OVER (PARTITION BY CDS.location) AS Rolling_Vac
FROM ProjectPortfolio..CovidDeath$ CDS
JOIN ProjectPortfolio..Vaccine$ VAC
ON CDS.location = VAC.location
AND CDS.date=VAC.date
WHERE CDS.continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT *
FROM PopVac

--CREATE TEMP TABLE 
Drop Table if exists PopulationVaccinenated 
CREATE Table PopulationVaccinenated 
( continent nvarchar(200),
location nvarchar(200),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_Vac numeric)
INSERT INTO PopulationVaccinenated 
SELECT CDS.continent, CDS.location, CDS.date, CDS.population, VAC.new_vaccinations, SUM (CAST(VAC.new_vaccinations AS BIGINT)) OVER (PARTITION BY CDS.location) AS Rolling_Vac
FROM ProjectPortfolio..CovidDeath$ CDS
JOIN ProjectPortfolio..Vaccine$ VAC
ON CDS.location = VAC.location
AND CDS.date=VAC.date
WHERE CDS.continent IS NOT NULL 
--ORDER BY 2,3
SELECT *, (Rolling_Vac/population) AS Vac_Status
FROM PopulationVaccinenated 


--Creating Vitualization Views

Create View Vac_Status AS
SELECT CDS.continent, CDS.location, CDS.date, CDS.population, VAC.new_vaccinations, SUM (CAST(VAC.new_vaccinations AS BIGINT)) OVER (PARTITION BY CDS.location) AS Rolling_Vac
FROM ProjectPortfolio..CovidDeath$ CDS
JOIN ProjectPortfolio..Vaccine$ VAC
ON CDS.location = VAC.location
AND CDS.date=VAC.date
WHERE CDS.continent IS NOT NULL 
--ORDER BY 2,3

 SELECT * 
  FROM Vac_Status