SELECT * 
FROM SQLPORTPRJ1..CovidDeaths
order by 3,4

--SELECT * 
--FROM SQLPORTPRJ1..CovidVaccinations
--order by 3,4

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM SQLPORTPRJ1..CovidDeaths
Where location like 'Canada'
order by 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, date, Population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
FROM SQLPORTPRJ1..CovidDeaths
Where location like 'Canada'
order by 1,2

-- Lookiong at Countries with Highest Infection Rate  compared to Population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM SQLPORTPRJ1..CovidDeaths
--Where location like 'Canada'
group by Location, Population
order by PercentagePopulationInfected desc

-- Showing Countries with highest Death Count per Population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM SQLPORTPRJ1..CovidDeaths
--Where location like 'Canada'
Where continent is not null
group by Location
order by TotalDeathCount desc

-- Let's break things down by continent
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM SQLPORTPRJ1..CovidDeaths
--Where location like 'Canada'
Where continent is null
group by location
order by TotalDeathCount desc

-- Showing the continent with the highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM SQLPORTPRJ1..CovidDeaths
--Where location like 'Canada'
Where continent is null
and location NOT IN ('High income','Upper middle income','Lower middle income','Low income','World')
group by location
order by TotalDeathCount desc

--GLOBAL NUMBERS
SELECT  SUM(new_cases) as total_cases, SUM (new_deaths) as total_deaths,  
CASE
        WHEN SUM(new_cases) = 0 THEN NULL 
        ELSE SUM(new_deaths) / SUM(new_cases) * 100
    END as DeathPercentage
FROM SQLPORTPRJ1..CovidDeaths
Where continent is not null
--Group by date
order by 1,2

--Looking at total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location)
,SUM(CONVERT(BIGINT, ISNULL(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
From SQLPORTPRJ1..CovidDeaths dea
Join SQLPORTPRJ1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location)
,SUM(CONVERT(BIGINT, ISNULL(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
From SQLPORTPRJ1..CovidDeaths dea
Join SQLPORTPRJ1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated

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
--, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location)
,SUM(CONVERT(BIGINT, ISNULL(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
From SQLPORTPRJ1..CovidDeaths dea
Join SQLPORTPRJ1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location)
,SUM(CONVERT(BIGINT, ISNULL(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
From SQLPORTPRJ1..CovidDeaths dea
Join SQLPORTPRJ1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 
--order by 2,3

SELECT * FROM dbo.PercentPopulationVaccinated