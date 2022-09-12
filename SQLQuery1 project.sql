create database projectportfolio


use  projectportfolio

Select *
From projectportfolio..CovidDeaths
Where continent is not null
order by 3,4

Select Location,date,total_cases,new_cases,total_deaths,population
From projectportfolio..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract the virus

Select Location,date,total_cases,total_deaths,(total_cases/total_deaths)*100 as DeathPercentage
From projectportfolio..CovidDeaths
Where location like '%Zim%'
order by 1,2

-- Looking at Total cases vs Population
-- Shows what percentage of population got covid
Select Location,date,total_cases,Population,(total_cases/population)*100 as DeathPercentage
From projectportfolio..CovidDeaths
Where location like '%Zim%'
order by 1,2

--Looking at Countries with highest infection rate
Select Location,Population, Max(total_cases)as  HighestInfectionCount,Max((total_cases/population))*100 as PercentPopulationInfected
From projectportfolio..CovidDeaths
--Where location like '%Zim%'
Group by Location,Population
order by PercentPopulationInfected asc

-- LETS BREAK THINGS DOWN BY CONTINENT

--showing countries with the highest deathcount
Select Location,MAX(cast(Total_deaths as int ))as TotalDeathCount
From projectportfolio..CovidDeaths
Where continent is not  null
Group by Location
order by TotalDeathCount desc

--Showing the continent with highest deaths
Select continent,MAX(cast(Total_deaths as int ))as TotalDeathCount
From projectportfolio..CovidDeaths
Where continent is not  null
Group by continent
order by TotalDeathCount desc

--Global Numbers.
Select date,SUM(new_cases)as total_cases,SUM(cast(new_deaths as int)) as total_deaths,Sum(cast(new_deaths as int))
/ sum(new_cases)*100  as DeathPercentage
From projectportfolio..CovidDeaths
-- Where location like '%Zim%'
where continent is not null
Group by date
order by 1,2

-- Looking at Total population vs vaccination
/*Select dea.continent,dea.location,dea.date,vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int ))
over (Partition by dea.Location)
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and  dea.date = vac.date
Where dea.continent is not null
order by 2,3*/

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations ))
over (Partition by dea.Location order by dea.location,dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and  dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- USING CTE
With PopvsVac(Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations ))
over (Partition by dea.Location order by dea.location,dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and  dea.date = vac.date
Where dea.continent is not null
-- order by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac

--Temp Table
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations ))
over (Partition by dea.Location order by dea.location,dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and  dea.date = vac.date
--Where dea.continent is not null
-- order by 2,3

select *,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations ))
over (Partition by dea.Location order by dea.location,dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and  dea.date = vac.date
where dea.continent is not null
-- order by 2,3

select *
 From PercentPopulationVaccinated
