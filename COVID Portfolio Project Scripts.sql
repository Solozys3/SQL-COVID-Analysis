
Select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--from PortfolioProject..CovidVaccinations
--order by 3,4



Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
Order by 1,2


-- Loking at Total Cases Vs Total Deaths


Select Location, date, total_cases, total_deaths, (cast(total_deaths as float) / cast(total_cases as float))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
order by 1,2

Select Location, date, total_cases, total_deaths, (cast(total_deaths as float) / cast(total_cases as float))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where Location = 'Nigeria'
order by 1,2

-- Loking at Total Cases Vs Population

Select Location, date, population, total_cases, (cast(total_cases as float) / cast(population as float))*100 as CasePercentage
from PortfolioProject..CovidDeaths
where Location = 'Nigeria'
order by 1,2


-- Countries with highest infection rate compared to population


Select Location, date, population, total_cases, (cast(total_cases as float) / cast(population as float))*100 as CasePercentage
from PortfolioProject..CovidDeaths
order by 5 DESC

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(Cast(total_cases as float) / cast(population as float))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
Order by 4 DESC


--- Showing countries with Highest Death count per Population

Select Location, Population, MAX(total_deaths) as TotalDeathCount, MAX(Cast(total_deaths as float) / cast(population as float))*100 as PercentPopulationDeath
From PortfolioProject..CovidDeaths
Group by Location, Population
Order by 4 DESC

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group by Location 
Order by 2 desc


--- By Continent ---

-- Highest Death count per population --

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group by continent
Order by 2 desc


--- Global Numbers ---

Select Location, date, total_cases, total_deaths, (cast(total_deaths as int) / cast(total_cases as int))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2

-- By Date

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
 CASE 
        WHEN SUM(new_cases) = 0 THEN NULL
        ELSE SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100
    END AS DeathPercentage
From CovidDeaths
where continent is not null
Group by date
order by 4 desc

-- Overall Death Percentage

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
 CASE 
        WHEN SUM(new_cases) = 0 THEN NULL
        ELSE SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100
    END AS DeathPercentage
From CovidDeaths
where continent is not null
-- Group by date
--order by 4 desc



----- VACCINATIONS ---

Select *
from CovidVaccinations

select *
from CovidDeaths dea
Join CovidVaccinations vac
	on dea.Location = vac.Location
	and dea.Date = vac.Date

--- Total Polulation vs Vaccinations

SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
    CovidDeaths dea
JOIN 
    CovidVaccinations vac ON dea.Location = vac.Location AND dea.Date = vac.Date
WHERE 
    dea.continent IS NOT NULL
ORDER BY 
    dea.location, 
    dea.date


-- USE CTE

With PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
    CovidDeaths dea
JOIN 
    CovidVaccinations vac ON dea.Location = vac.Location AND dea.Date = vac.Date
WHERE 
    dea.continent IS NOT NULL
--- ORDER BY dea.location, dea.date
)
Select *, (RollingPeopleVaccinated/Population)*100 as PopVsVacPercentage
from PopVsVac


-- max 

With PopVsVac (continent, location, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT 
    dea.continent, 
    dea.location, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
    CovidDeaths dea
JOIN 
    CovidVaccinations vac ON dea.Location = vac.Location AND dea.Date = vac.Date
WHERE 
    dea.continent IS NOT NULL
--- ORDER BY dea.location, dea.date
)
SELECT 
    continent, 
    location, 
    MAX(population) AS max_population,
    MAX(RollingPeopleVaccinated) AS max_rolling_vaccinated
FROM 
    PopVsVac
GROUP BY 
    continent, 
    location
	Order  by 4 DESC


--- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT 
    dea.continent, 
    dea.location, 
	dea.date,
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
    CovidDeaths dea
JOIN 
    CovidVaccinations vac ON dea.Location = vac.Location AND dea.Date = vac.Date
WHERE 
    dea.continent IS NOT NULL
--- ORDER BY dea.location, dea.date

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
SELECT 
    dea.continent, 
    dea.location, 
	dea.date,
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
    CovidDeaths dea
JOIN 
    CovidVaccinations vac ON dea.Location = vac.Location AND dea.Date = vac.Date
WHERE 
    dea.continent IS NOT NULL
--- ORDER BY dea.location, dea.date


Select *
from PercentPopulationVaccinated