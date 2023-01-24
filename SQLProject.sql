SELECT *
FROM PortfolioProject..COVIDDeaths
where continent is NOT NULL
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..COVIDVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT Location, date,total_cases,new_cases,total_deaths,population
From PortfolioProject..COVIDDeaths
ORDER by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract COVID in your country
SELECT Location, date,total_cases,total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
From PortfolioProject..COVIDDeaths
WHERE location like '%nepal%'
ORDER by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got COVID
SELECT Location, date,total_cases,population , (total_cases / population) *100 as DeathPercentage
From PortfolioProject..COVIDDeaths
WHERE location like '%nepal%'
ORDER by 1,2

--Looking at countries with Highest Infection Rate compared to Population
SELECT Location, Population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases / population)) *100 as PercentPopulationInfected
From PortfolioProject..COVIDDeaths
--WHERE location like '%nepal%'
GROUP BY Location,Population
ORDER by PercentPopulationInfected DESC

--Showing countries with Highest Death Count per population
SELECT Location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..COVIDDeaths
--WHERE location like '%nepal%'
WHERE continent is NOT NULL
GROUP BY Location
ORDER by TotalDeathCount DESC

--Showing Continents with the Highest death count per population
SELECT [continent], MAX(total_deaths) as TotalDeathCount
From PortfolioProject..COVIDDeaths
--WHERE location like '%nepal%'
WHERE continent is NOT NULL
GROUP BY [continent]
ORDER by TotalDeathCount DESC


--Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..COVIDDeaths
--WHERE location like '%nepal%'
WHERE continent is NOT NULL
--GROUP BY [date]
ORDER by 1,2

--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.[location],dea.[date],dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProject..COVIDDeaths dea
JOIN PortfolioProject..COVIDVaccinations vac
    ON dea.[location]=vac.[location]
    AND dea.[date]=vac.[date]
WHERE dea.continent is NOT NULL
ORDER BY 2,3

--Use CTE
WITH PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.[location],dea.[date],dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProject..COVIDDeaths dea
JOIN PortfolioProject..COVIDVaccinations vac
    ON dea.[location]=vac.[location]
    AND dea.[date]=vac.[date]
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
)

SELECT *,(RollingPeopleVaccinated/population)*100
FROM PopvsVac


--TempTable
DROP TABLE if EXISTS #PercentPopulationVaccinated
Create TABLE #PercentPopulationVaccinated
(
continent NVARCHAR(255),
LOCATION NVARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT into #PercentPopulationVaccinated 
SELECT dea.continent, dea.[location],dea.[date],dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProject..COVIDDeaths dea
JOIN PortfolioProject..COVIDVaccinations vac
    ON dea.[location]=vac.[location]
    AND dea.[date]=vac.[date]
WHERE dea.continent is NOT NULL
--ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProject..COVIDDeaths dea
JOIN PortfolioProject..COVIDVaccinations vac
    ON dea.location=vac.location
    AND dea.date=vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated
