

SELECT *
FROM [portfolio project 1].[dbo].[covid deaths]
Where continent is not null
order by 3,4

--

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [portfolio project 1].[dbo].[covid deaths]
order by 1,2 

-- 

ALTER TABLE [portfolio project 1].[dbo].[covid deaths] ALTER COLUMN [total_deaths][decimal]
ALTER TABLE [portfolio project 1].[dbo].[covid deaths] ALTER COLUMN [total_cases][decimal]
ALTER TABLE [portfolio project 1].[dbo].[covid deaths] ALTER COLUMN [new_cases][decimal]
ALTER TABLE [portfolio project 1].[dbo].[covid deaths] ALTER COLUMN [new_deaths][decimal]

-- total cases vs total deaths, or likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM [portfolio project 1].[dbo].[covid deaths]
WHERE location like '%states%'
and continent is not null
order by 1,2 

-- Total cases vs population, what percentage got covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM [portfolio project 1].[dbo].[covid deaths]
--WHERE location like '%states%'
order by 1,2 


--Countries with highest infectin rate compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentageInfected
FROM [portfolio project 1].[dbo].[covid deaths]
--WHERE location like '%states%'
Group by Location, population
order by PercentageInfected desc


--Countries with highest death count 

SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM [portfolio project 1].[dbo].[covid deaths]
--WHERE location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc





--	BREAKDOWN OF DEATHS BY CONTINENT

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM [portfolio project 1].[dbo].[covid deaths]
--WHERE location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc



--USE LOCATION FOR ACCURACY 

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM [portfolio project 1].[dbo].[covid deaths]
--WHERE location like '%states%'
Where continent is null
Group by location
order by TotalDeathCount desc



--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(Nullif(new_cases,0))*100 as DeathPercentage
FROM [portfolio project 1].[dbo].[covid deaths]
--WHERE location like '%states%'
where continent is not null
--Group by date
order by 1,2 



--TOTAL DEATH RATE OVERALL

SELECT  SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(Nullif(new_cases,0))*100 as DeathPercentage
FROM [portfolio project 1].[dbo].[covid deaths]
--WHERE location like '%states%'
where continent is not null
order by 1,2 



--TOTAL POLULATION VS VACCINATIONS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as decimal)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [portfolio project 1].[dbo].[covid deaths] dea
Join [portfolio project 1].[dbo].[covid-vaccinations] vac
On dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3



--Use CTE 

With PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as decimal)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [portfolio project 1].[dbo].[covid deaths] dea
Join [portfolio project 1].[dbo].[covid-vaccinations] vac
On dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 
From PopVsVac



--Temp Table

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
, SUM(Cast(vac.new_vaccinations as decimal)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [portfolio project 1].[dbo].[covid deaths] dea
Join [portfolio project 1].[dbo].[covid-vaccinations] vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 
From #PercentPopulationVaccinated 



--	creating view to store data for visuals

Create View PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as decimal)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [portfolio project 1].[dbo].[covid deaths] dea
Join [portfolio project 1].[dbo].[covid-vaccinations] vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated