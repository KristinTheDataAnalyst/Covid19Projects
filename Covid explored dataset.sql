--Data Exploration
Select *
From PortfolioProject..CovidDeaths
oRDER BY 3,4

--Select *
--From PortfolioProject..CovidVaccination
--Order by 3,4

--Try to select the data thata will be used in this project

Select Location, Date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
oRDER BY 1,2

--Review the total cases vs total deaths
-- This is a rough estimate of people dying if thet contract covid in their country
Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%netherlands%'
oRDER BY 1,2

--Total cases vs population
Select Location, Date, total_cases, population, (total_deaths/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%Netherlands%'
oRDER BY 1,2

--Countries with the highest cases compared to population
Select Location, Population, MAX(total_cases) as HighestCasesCount, MAX(total_cases/population)*100 as PercentPopulationCases
From PortfolioProject..CovidDeaths
--Where Location like '%States%'
Group by Location,Population
oRDER BY PercentPopulationCases desc


--Countries with Highest death rate
Select Location, MAX(cast(total_deaths as int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths
--Where Location like '%States%'
Where continent is null
Group by Location
oRDER BY TotalDeathsCount desc

--Continents with the Highest death rate
Select Continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths
--Where Location like '%States%'
Where continent is not null
Group by Continent
oRDER BY TotalDeathsCount desc


--Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
oRDER BY 1,2

--Total population vs Vaccinations
Select *
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
    ON dea.location = vac.location
   and dea.date = vac.date


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (Cast(vac.new_vaccinations as int)) over (Partition by dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
    ON dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--Use CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVacinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (Cast(vac.new_vaccinations as int)) over (Partition by dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
    ON dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVacinated/Population)*100
From PopvsVac

--Temp Table
Drop Table if Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) over (Partition by dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
    On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Create view to save data for visualization on BI Tool

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) over (Partition by dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
    On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

--Query off the view
Select *
From #PercentPopulationVaccinated
