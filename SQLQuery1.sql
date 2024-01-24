Select *
From PortfolioProject..CovidDeaths$
where continent is not null
order by 3, 4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3, 4

--select data we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2

--Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
where location='pakistan'
order by 1,2

--Looking at Total Cases vs Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((cast(total_cases as float)/cast(population as float)))*100 as 
	PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--where location='pakistan'
group by location, population
order by 1,2

--Looking at Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by TotalDeathsCount desc

--Let's break things down by continents

Select location, MAX(cast(total_deaths as int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths$
where continent is null and location != 'World' and location != 'High income'and location != 'Upper middle income' 
and location != 'Lower middle income' and location != 'Low income'
group by location
order by TotalDeathsCount desc

--Let's break things down by Total Cases per Million

Select location, date, total_cases, population, (cast(total_cases as float)/population)*1000000 as TotalCasesPerMillion
From PortfolioProject..CovidDeaths$
where continent is not null
order by  1, 2

--GLOBAL NUMBERS

Select SUM(cast(new_cases as int)) as TotalCasesOnDay, SUM(cast(new_deaths as int)) as TotalDeathsOnday,
	(SUM(cast(new_deaths as float))/SUM(cast(new_cases as int)))*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--Total cases on a specific day in a country

Select location, date, count(total_cases) as TotalCases
From PortfolioProject..CovidDeaths$
where continent is not null and date='2020-03-08'
group by location, date
order by 1,2

--Total cases on a specific day

Select sum(cast(total_cases as int)) as TotalCases
From PortfolioProject..CovidDeaths$
where continent is not null and date='2020-03-08'

--Looking at Total Population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as TotalNewVac
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location =vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2, 3

--Total New Tests by each Country

Select location, count(new_tests) as TotalNewTests
From PortfolioProject..CovidVaccinations$
where continent is not null
group by location
order by 1,2

--Total New Tests by each Continent

Select continent, count(new_tests) as TotalNewTests
From PortfolioProject..CovidVaccinations$
where continent is not null
group by continent
order by 1,2

--Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, TotalNewVac)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as TotalNewVac
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location =vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2, 3
)
select *, (TotalNewVac/population)*100 as PercentageOfPeopleVaccinated
From PopvsVac
order by 2, 3

--Temp Table

drop table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated(
	continent varchar(255),
	location varchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	TotalNewVac numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as TotalNewVac
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location =vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2, 3

select *, (TotalNewVac/population)*100 as PercentageOfPeopleVaccinated
From #PercentPopulationVaccinated
order by 2, 3

--Create views to store data for later visualization

Drop VIew if exists PercentPopulationVaccinated

Create View PercentPopulationVaccinated
	as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as TotalNewVac
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location =vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2, 3

select *
From PercentPopulationVaccinated