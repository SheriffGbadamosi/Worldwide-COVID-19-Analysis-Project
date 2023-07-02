/*
Covid-19 Worldwide Data Exploration 

Using Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

-- Understanding the two Data Sets
SELECT *
FROM CovidDeaths
WHERE continent is not null 
ORDER BY 3,4

SELECT *
FROM CovidVaccinations
WHERE continent is not null 
ORDER BY 3,4

-- 1) Calculating the Death Percentage using Total Cases vs Total Deaths

SELECT Location, Date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null 
ORDER BY 1,2


-- 2) Calculating the percentage of the world population that contracted Covid-19

SELECT Continent, Location, Date, Population, Total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- 3) Calculating the Countries with Highest Infection Rate compared to Population (from highest to lowest)

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
WHERE continent is not null
GROUP BY Location, Population
ORDER BY 4 desc


-- 4) To Calculate the Countries with Highest Death Count per Population (from highest to lowest)

SELECT Location, Population, MAX(total_deaths) as HighestDeathCount,  Max((total_deaths/population))*100 as PercentPopulationDeath
FROM CovidDeaths
WHERE continent is not null
GROUP BY Location, Population
ORDER BY 4 desc


-- 5) To Calculate the Countries with Highest Death Count

SELECT Location, MAX(CONVERT(int, Total_deaths)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null 
GROUP BY Location
ORDER BY 2 desc



-- 6) What contintents has the highest death count per population

SELECT Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount ASC



-- 7) Showing the daily global cases

SELECT SUM(new_cases) as total_cases, SUM(CONVERT(int, new_deaths)) as total_deaths, SUM(CONVERT(int, new_deaths))/SUM(New_Cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null 
--GROUP BY Date
ORDER BY 1,2

-- Other method

SELECT Date, SUM(new_cases) as total_cases, SUM(CONVERT(int, new_deaths)) as total_deaths, 
    CASE 
        WHEN SUM(new_cases) != 0 THEN SUM(CONVERT(int, new_deaths))*1.0/SUM(new_cases)*100 
        ELSE NULL
    END AS DeathPercentage
FROM CovidDeaths
WHERE Continent is not NULL
GROUP BY Date
ORDER BY Date 



-- 8) Total number of people vaccinated at the end of each day (Rolling Count)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- 9) Using CTE to perform Calculate the PercentageVaccinated

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
From PopvsVac



-- Using Temp Table to perform Calculatate the PercentageVaccinated as above

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
From #PercentPopulationVaccinated




-- 10) Creating Views for visualizations

CREATE VIEW DeathPercentage as
SELECT Location, Date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null 

CREATE VIEW PercentPopulationInfected as
SELECT Continent, Location, Date, Population, Total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM CovidDeaths
WHERE continent is not null

CREATE VIEW HighestInfectCountry as
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
WHERE continent is not null
GROUP BY Location, Population

CREATE VIEW PercentPopulationDeath as
SELECT Location, Population, MAX(total_deaths) as HighestDeathCount,  Max((total_deaths/population))*100 as PercentPopulationDeath
FROM CovidDeaths
WHERE continent is not null
GROUP BY Location, Population

CREATE VIEW TotalDeathCount as
SELECT Location, MAX(CONVERT(int, Total_deaths)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null 
GROUP BY Location

CREATE VIEW GlobalCasesPerDay As 
SELECT SUM(new_cases) as total_cases, SUM(CONVERT(int, new_deaths)) as total_deaths, SUM(CONVERT(int, new_deaths))/SUM(New_Cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null 
GROUP BY Date

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

CREATE VIEW PercentageVaccinated as
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
From PopvsVac



