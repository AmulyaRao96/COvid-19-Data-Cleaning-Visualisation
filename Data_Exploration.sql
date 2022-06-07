select * from coviddeaths
order by 3,4

select * from covidvaccinations
order by 3,4

--for visualisation
1.
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

2.
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

3.
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

4.
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc


--querrying to see the total cases and and deaths as against population
select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2

--looking at the total number of cases vs deaths wrt to location and date
--fix the 0 percentage issue
--fixed the issue by changing the data type of the total_cases and total_deaths to float
select location,date,total_cases,total_deaths, (total_deaths /total_cases)*100  as DeathPercentage
from CovidDeaths
order by 1,2

--just to see the total cases vs deaths scenarios in India  and it can be seen
--that it gradually increase in 2020 and reach its peak in April -May and then it decrease(deathpercentage)
select location,date,total_cases,total_deaths, (total_deaths /total_cases)*100  as DeathPercentage
from CovidDeaths
where location='India'
order by 1,2

--total cases vs the population
select location,date,total_cases,population,(total_cases/population)*100 CasesPercentage
from CovidDeaths

--for India
select location,date,total_cases,population,(total_cases/population)*100 CasesPercentage
from CovidDeaths
where location='India'

--to see which countries have highest infection rate(percent of population infected) when compared to population
select location,population,Max(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as PercentagePopulationInfected
from CovidDeaths
--where location ='India'
group by location,population
order by PercentagePopulationInfected desc

--to see the highest percentage of people who died in each country
select location,population,max(total_deaths)as HighestDeaths,Max((total_deaths/population))*100 as HighestDeathPercentage
from CovidDeaths
--where location='India'
group by location,population
order by HighestDeathPercentage desc


--query to see the highest number of deaths in each country

select location,max(cast(total_deaths as int)) as TotalDeaths
from CovidDeaths
where continent is not null
and total_deaths is not null
group by location
order by TotalDeaths desc

--to check the max deaths by continent
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from coviddeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers
select location,date,total_cases,total_deaths, (total_deaths /total_cases)*100  as DeathPercentage
from CovidDeaths
where continent is not null
--where location='India'
order by 1,2

select date,sum(new_cases)as NewCases,sum(new_deaths) as NewDeaths,(sum(new_deaths)/sum(new_cases))*100 Deathpercentage
from CovidDeaths
where continent is not null
group by date
--where location='India'
order by 1,2

select location,date,sum(new_cases) as NewCases
where continent is not null
group by date,location
--where location='India'
order by 1,2


--querrying through the covidvaccinations table now

select * from covidvaccinations


select * from coviddeaths dea
join covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date

--looking at totalpoulation vs the ones that have been vaccinated in the world
select dea.location,sum(population)as Total_population,sum(people_fully_vaccinated)as Total_vaccinated from coviddeaths dea
join covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
group by dea.location,population
order by dea.location

-- to see how different countries are performing in terms of vaccinations in a day
select dea.continent,dea.location,dea.date,population,vac.new_vaccinations from coviddeaths dea
join covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--and dea.location='Canada'
order by 2,3

--to get a rolling count
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(vac.new_vaccinations)over(partition by dea.location order by dea.location,dea.date) from coviddeaths dea
join covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--and dea.location='Canada'
order by 2,3

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
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

DROP Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent char(255),
Location  char(255),
Date date,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated

-- Creating View to store data for later visualizations
Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 


