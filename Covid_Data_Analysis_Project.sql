Select *
From PortfolioProject ..covidDeath
where continent is not null
order by 3, 4


--Select *
--From PortfolioProject ..covidVaccination
--order by 3, 4

--select data we are going to use

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject ..covidDeath
where continent is not null
order by 1, 2

--Looking at TOTAL CASES VS TOTAL DEATH
-- Showing the likiklyhood of daying if you get Covid in Ethiopia

Select location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 as DeathPercentage
From PortfolioProject ..covidDeath
Where location like '%Ethiopia%'
and continent is not null
order by 1, 2

--looking at TOTAL CASES VS POPULATIONS
-- shows the percentage of populations get COVID in Ethiopia

Select location, date, population, total_cases, (total_cases/population)*100 as InfectedPopulationPercentage
From PortfolioProject ..covidDeath
Where location like '%Ethiopia%'
and continent is not null
order by 1, 2

-- shows the percentage of populations get COVID internatonal

Select location, date, population, total_cases, (total_cases/population)*100 as InfectedPopulationPercentage
From PortfolioProject ..covidDeath
where continent is not null
order by 1, 2

-- looing at the counteirs with highest infected precentage 

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPopulationPercentage
From PortfolioProject ..covidDeath
where continent is not null
Group by location, population
Order by InfectedPopulationPercentage desc

-- looking at countries with highest death count per population

Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject ..covidDeath
where continent is not null
Group by location
Order by TotalDeathCount desc


-- showing death count by countinent with the higest count

Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject ..covidDeath
where continent is not null
Group by continent
Order by TotalDeathCount desc

--check this more corect 
Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject ..covidDeath
where continent is null
Group by location
Order by TotalDeathCount desc

--Global Number

Select date, sum(new_cases) as total_cases,  sum(CAST(new_deaths as int)) as total_death, sum(CAST(new_deaths as int))/ sum(new_cases)*100 as DeathPercentage
From PortfolioProject ..covidDeath
where continent is not null
Group by date
Order by 1, 2 desc

-- Total case up to date 

Select sum(new_cases) as total_cases,  sum(CAST(new_deaths as int)) as total_death, sum(CAST(new_deaths as int))/ sum(new_cases)*100 as DeathPercentage
From PortfolioProject ..covidDeath
where continent is not null
Order by 1, 2 desc

--Joint Vaccination table with Death Table

select *
from PortfolioProject..covidDeath dea
join  PortfolioProject..covidVaccination vac
on dea.location = vac.location
and dea.date = vac.date

-- looking at TOTAL population Vs Vaccination
-- a)frist vaccination date 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..covidDeath dea
join  PortfolioProject..covidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
Order by dea.date

-- b) check this out
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,-- SUM(Cast(vac.new_vaccinations as int)), 
from PortfolioProject..covidDeath dea
join  PortfolioProject..covidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
Order by 2, 3



Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.DATE) as RollingPepoleVaccinated
from PortfolioProject..covidDeath dea
join  PortfolioProject..covidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
Order by 2, 3

-- WITH CTE
with popvsvac (continent, location, date, population, new_vaccinations, RollingPepoleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPepoleVaccinated
from PortfolioProject..covidDeath dea
join  PortfolioProject..covidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2, 3
)
Select * , (RollingPepoleVaccinated/ population)* 100
from popvsvac
Order by 2, 3


-- TEMP TABLE

Create table PercentPopulationVaccenated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPepoleVaccinated numeric
)

Insert into PercentPopulationVaccenated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPepoleVaccinated
from PortfolioProject..covidDeath dea
join  PortfolioProject..covidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 

Select * , (RollingPepoleVaccinated/ population)* 100
from PercentPopulationVaccenated

-- other option
drop table if exists PercentPopulationVaccenated
Create table PercentPopulationVaccenated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPepoleVaccinated numeric
)

Insert into PercentPopulationVaccenated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPepoleVaccinated
from PortfolioProject..covidDeath dea
join  PortfolioProject..covidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null 

Select * , (RollingPepoleVaccinated/ population)* 100
from PercentPopulationVaccenated

-- Creating view to store data later for vizulazation

Create View  PercentPopulationVaccenatted as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPepoleVaccinated
from PortfolioProject..covidDeath dea
join  PortfolioProject..covidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 

Select *
from PercentPopulationVaccenatted
