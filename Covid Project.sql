
SELECT * FROM [Covid deaths]
WHERE continent IS NOT NULL
ORDER BY 3,4


SELECT * FROM [Covid vacinations]
ORDER BY 3,4


SELECT location,date,total_cases,new_cases,total_deaths,population FROM [Covid deaths]
ORDER BY 1,2

--Looking at total cases vs total deaths
--Likelyhood of dying from Covid if you contract it in United States
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage 
FROM [Covid deaths]
WHERE location LIKE '%States%'
AND continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid in United States
SELECT location,date,total_cases,population,(total_cases/population)*100 AS InfectedPercentage
FROM [Covid deaths]
WHERE location LIKE '%States%'
ORDER BY 1,2

--Shows what percentage of population got Covid in different countries
SELECT location,date,total_cases,population,(total_cases/population)*100 AS InfectedPercentage 
FROM [Covid deaths]
--WHERE location LIKE '%States%'
ORDER BY 1,2


--Looking at countries with highest infection rate compared to population

SELECT location,population,MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population)*100) AS InfectedPercentage 
FROM [Covid deaths]
--WHERE location LIKE '%States%'
GROUP BY location,population
ORDER BY InfectedPercentage DESC


--Showing Countries with Highest Death Count per Population

SELECT location,MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM [Covid deaths]
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--Lets break it down by continent
--Showing highest death counts by continent
SELECT continent,MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM [Covid deaths]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers

SELECT 
    --date,
    SUM(new_cases) AS TotalCases,
    SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
    CASE WHEN SUM(new_cases) = 0 THEN NULL ELSE SUM(CAST(new_deaths AS INT)) / SUM(new_cases) END AS death_rate
FROM [Covid deaths]
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2



--Looking at Total Population vs Vaccinations
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location)
FROM [Covid deaths] dea
JOIN [Covid vacinations] vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM [Covid deaths] dea
JOIN [Covid vacinations] vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--CTE

WITH PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM [Covid deaths] dea
JOIN [Covid vacinations] vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL)
SELECT *,(RollingPeopleVaccinated/population)*100 
FROM PopvsVac


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM [Covid deaths] dea
JOIN [Covid vacinations] vac
ON dea.location = vac.location AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL

SELECT *,(RollingPeopleVaccinated/population)*100 FROM #PercentPopulationVaccinated


--CREATING VIEWS FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM [Covid deaths] dea
JOIN [Covid vacinations] vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
