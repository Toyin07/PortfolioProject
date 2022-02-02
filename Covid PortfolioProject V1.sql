select * from PortfolioProject..['Covid death$']
order by 3, 4

--select * from PortfolioProject..['Covid vaccination$']
--order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..['Covid death$']
order by 1, 2

-- Looking at Total cases vs total deaths

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..['Covid death$']
where location like '%Kingdom%'
order by 1, 2

--Looking at total  cases vs population

select location, date, Population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..['Covid death$']
where location like '%Kingdom%'
order by 1, 2

-- Looking at countries with highest infection rate

select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..['Covid death$']
--where location like '%Kingdom%'
group by location, Population
order by PercentagePopulationInfected desc

--Showing the countries with the highest death count population

select location, MAX(cast(Total_deaths as int)) as TotalDeathsCount
from PortfolioProject..['Covid death$']
--where location like '%Kingdom%'
where continent is not null
group by location
order by TotalDeathsCount desc


-- LETS BREAKTHINGS DOWN BY CONTINENT
--Showing continent with highest deaths Count

select continent, MAX(cast(Total_deaths as int)) as TotalDeathsCount
from PortfolioProject..['Covid death$']
--where location like '%Kingdom%'
where continent is not null
group by continent
order by TotalDeathsCount desc

-- Global Numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..['Covid death$']
--where location like '%Kingdom%'
where continent is not null
--group by date
order by 1, 2

--Looking at total Population vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, RollingPeoplevaccinated/population*100
from PortfolioProject..['Covid death$'] dea
join PortfolioProject..['Covid vaccination$'] vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3





-- use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, RollingPeoplevaccinated/population*100
from PortfolioProject..['Covid death$'] dea
join PortfolioProject..['Covid vaccination$'] vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--TEMP TABLE

Create table #PercentagePopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, RollingPeoplevaccinated/population*100
from PortfolioProject..['Covid death$'] dea
join PortfolioProject..['Covid vaccination$'] vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentagePopulationVaccinated

-- Creating view to store later for visualisation

Create view PercentagePopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, RollingPeoplevaccinated/population*100
from PortfolioProject..['Covid death$'] dea
join PortfolioProject..['Covid vaccination$'] vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentagePopulationVaccinated