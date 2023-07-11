--select * 
--from portfolioProject..covidDeaths
--order by 3,4

--select * from portfolioProject..covidVaccinations order by 3,4;

select location , date, total_cases, new_cases, total_deaths, population from portfolioProject..covidDeaths order by 1,2;

--total cases vs total deaths

select  location , date, total_cases, total_deaths,
(total_deaths/total_cases)*100 as deathPercentage
from portfolioProject..covidDeaths 
where location like '%India%'
order by 1,2;

--looking at total case vs population
--shows what percentage of population to covid

select  location , date, population, total_cases,total_deaths, 
(total_cases/population)*100 as PercentagePopulation
from portfolioProject..covidDeaths 
where location like '%states%'
order by 1,2;


--looking at country highest infection rate compared to population
select  location , population, max(total_cases) as highestInfectionCount,
max((total_cases/population))*100 as PercentePopulationInfected
from portfolioProject..covidDeaths 
--where location like '%states%'
group by location, population
order by PercentePopulationInfected desc;
--order by population desc;

--showing country highest death count per population
select location,  max(cast (total_deaths as int)) as totalDeathCount 
from portfolioProject..covidDeaths 
where continent is not null
group by location
order by totalDeathCount desc;

--lets break thiings down by continent
select location,  max(cast (total_deaths as int)) as totalDeathCount 
from portfolioProject..covidDeaths 
where continent is null
group by location
order by totalDeathCount desc;

--
select date, sum(new_cases) as total_cases,  
sum(cast (new_deaths as int)) as totalDeaths,
sum(cast (new_deaths as int))/sum(new_cases)*100 as DeathsPercentage
from portfolioProject..covidDeaths 
where continent is not null
group by date
order by 1,2;

--total cases
select sum(new_cases) as total_cases,  
sum(cast (new_deaths as int)) as totalDeaths,
sum(cast (new_deaths as int))/sum(new_cases)*100 as DeathsPercentage
from portfolioProject..covidDeaths 
where continent is not null
order by 1,2; 


select * from portfolioProject..CovidVaccinations;

--looking at total population vs vaccinations

select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
from portfolioProject..covidDeaths dea
join portfolioProject..CovidVaccinations vac on 
dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3;


select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (Partition by
dea.location order by dea.location , dea.date)
as cummulativePeopleVaccinated
from portfolioProject..covidDeaths dea
join portfolioProject..CovidVaccinations vac on 
dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3; 

--CTE

with PopvsVac(continent, location , date, population , 
new_vaccinations,
cummulativePeopleVaccinated) as
(
select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (Partition by
dea.location order by dea.location , dea.date)
as cummulativePeopleVaccinated
from portfolioProject..covidDeaths dea
join portfolioProject..CovidVaccinations vac on 
dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
) 
select * , (cummulativePeopleVaccinated/population)*100 
from PopvsVac;

--temp table

drop table if exists  #percentPopulationVaccinated
create table #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cummulativePeopleVaccinated numeric
)

insert into  #percentPopulationVaccinated
select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (Partition by
dea.location order by dea.location , dea.date)
as cummulativePeopleVaccinated
from portfolioProject..covidDeaths dea
join portfolioProject..CovidVaccinations vac on 
dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select * , (cummulativePeopleVaccinated/population)*100 
from #percentPopulationVaccinated; 


-- views 

create view percentPopulationVaccinatedvw as
select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (Partition by
dea.location order by dea.location , dea.date)
as cummulativePeopleVaccinated
from portfolioProject..covidDeaths dea
join portfolioProject..CovidVaccinations vac on 
dea.location = vac.location and dea.date = vac.date
where dea.continent is not null;


select * from   percentPopulationVaccinatedvw ;