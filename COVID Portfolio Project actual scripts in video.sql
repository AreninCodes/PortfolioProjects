USE [Portfolio Project]
GO

Select *
From [dbo].[covid deaths]
Where continent is not null
order by 3,4


-- Shows Likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [dbo].[covid deaths]
Where Location like '%states%'
Order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM [dbo].[covid deaths]
--Where Location like '%states%'
Order by 1,2


-- Looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
FROM [dbo].[covid deaths]
--Where Location like '%states%'
Group by Location, Population
Order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select Location, Max(total_deaths) as TotalDeathCount
FROM [dbo].[covid deaths]
--Where Location like '%states%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT


Select continent, Max(total_deaths) as TotalDeathCount
FROM [dbo].[covid deaths]
--Where Location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Showing continents with the highest death count per population

Select continent, Max(total_deaths) as TotalDeathCount
FROM [dbo].[covid deaths]
--Where Location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS

-- deaths per case by day

Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM [dbo].[covid deaths]
--Where Location like '%states%'
where continent is not null
Group by date
Order by 1,2

-- overall deaths per case

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM [dbo].[covid deaths]
--Where Location like '%states%'
where continent is not null
Order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated
FROM [dbo].[covid deaths] as dea
Join [dbo].[covid vaccinations] as vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated
FROM [dbo].[covid deaths] as dea
Join [dbo].[covid vaccinations] as vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




-- Temp Table
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM [dbo].[covid deaths] as dea
Join [dbo].[covid vaccinations] as vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM [dbo].[covid deaths] as dea
Join [dbo].[covid vaccinations] as vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *
From PercentPopulationVaccinated