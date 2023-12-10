-- Displaying data ordered by column 3 than 4
SELECT *
FROM PortfolioProject.dbo.DeathsCovid
WHERE DATALENGTH(continent) > 0 
ORDER BY location DESC 


-- Calculating Death Percentage and ordered by col 1 than 2
-- Shows likelihood of dying from COVID in each country
SELECT location, date, total_cases, total_deaths, (total_deaths /total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.DeathsCovid
WHERE DATALENGTH(continent) > 0
ORDER by 1,2

-- Calculating Death Percentage in United States 
SELECT location, date,  total_cases, total_deaths, (total_deaths /total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.DeathsCovid
WHERE location LIKE '%states%'
AND DATALENGTH(continent) > 0 
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID
SELECT location, date, population, total_cases, (total_cases /population)*100 AS PercentPopInfected
FROM PortfolioProject.dbo.DeathsCovid
WHERE location LIKE '%states%'
AND DATALENGTH(continent) > 0 
ORDER BY 1,2

-- Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopInfected
FROM PortfolioProject.dbo.DeathsCovid
WHERE DATALENGTH(continent) > 0 
GROUP BY location, population
ORDER BY PercentPopInfected DESC

-- Countries with highest death count
SELECT location, continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.DeathsCovid
WHERE DATALENGTH(continent) > 0 
GROUP BY location, continent
ORDER BY TotalDeathCount DESC

-- Highest deaths - broken down by continent 
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.DeathsCovid
WHERE DATALENGTH(continent) !> 0 AND location NOT LIKE '%income%' AND location NOT LIKE 'World' AND location NOT LIKE 'European Union'
GROUP BY continent, location 
ORDER by TotalDeathCount DESC

-- Global numbers - NULLIF used to Handle Divide by Zero
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(NULLIF(new_deaths,0))/SUM(NULLIF(new_cases,0))*100 AS DeathPercentage
FROM PortfolioProject.dbo.DeathsCovid
WHERE DATALENGTH(continent) > 0
GROUP BY date 
ORDER BY 1,2

-- Looking at total population vs. vaccinations
SELECT dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject.dbo.DeathsCovid dea
JOIN PortfolioProject.dbo.VaccinationsCovid vac
ON dea.location = vac.location
AND dea.date =vac.date
WHERE DATALENGTH(dea.continent) > 0
ORDER BY 2,3

--Rolling people vaccinated by date
SELECT dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.DeathsCovid dea
JOIN PortfolioProject.dbo.VaccinationsCovid vac
ON dea.location = vac.location
AND dea.date =vac.date
WHERE DATALENGTH(dea.continent) > 0
ORDER BY 2,3

--Use Common Table Expression (CTE)
WITH PopVsVac (continent,location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS(
SELECT dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.DeathsCovid dea
JOIN PortfolioProject.dbo.VaccinationsCovid vac
ON dea.location = vac.location
AND dea.date =vac.date
WHERE DATALENGTH(dea.continent) > 0
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac

--Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.DeathsCovid dea
JOIN PortfolioProject.dbo.VaccinationsCovid vac
ON dea.location = vac.location
AND dea.date =vac.date
WHERE DATALENGTH(dea.continent) > 0

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- VIEW FOR VISUALIZATIONS

CREATE VIEW PercentPopVaccinated AS
SELECT dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.DeathsCovid dea
JOIN PortfolioProject.dbo.VaccinationsCovid vac
ON dea.location = vac.location
AND dea.date =vac.date
WHERE DATALENGTH(dea.continent) > 0

SELECT * 
FROM PercentPopVaccinated
