
-- Covid 19 Data Exploration 

-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types



Select *
From PortfolioProject.CovidDeaths
Where continent is not null 
order by 3,4;


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.CovidDeaths
Where continent is not null 
order by 1,2;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.CovidDeaths
Where location like '%States%'
and continent is not null 
order by 1,2;


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.CovidDeaths
-- Where location like '%states%'
order by 1,2;


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc;



-- Countries with Highest Death Count per Population

Select distinct Total_deaths
From coviddeaths;

Update coviddeaths
Set Total_deaths = null
Where Total_deaths = '';

Alter Table coviddeaths
Modify Column total_deaths integer;


Select Location, MAX(Total_deaths) as TotalDeathCount
From PortfolioProject.CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc;



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(Total_deaths) as TotalDeathCount
From PortfolioProject.CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc;


-- GLOBAL NUMBERS

Select distinct new_deaths
From coviddeaths;

Update coviddeaths
Set new_deaths = null
Where new_deaths = '';


Alter Table coviddeaths
Modify Column new_deaths integer;


Select SUM(new_cases) as total_cases, SUM(new_deaths ) as total_deaths, SUM(new_deaths )/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject.CovidDeaths
where continent is not null 
order by 1,2;



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select distinct new_vaccinations
From covidvaccinations;


Update covidvaccinations
Set new_vaccinations = null
Where new_vaccinations = '';


Alter Table covidvaccinations
Modify Column new_vaccinations integer;


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject.CovidDeaths dea
Join PortfolioProject.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject.CovidDeaths dea
Join PortfolioProject.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;



-- Using Temp Table to perform Calculation on Partition By in previous query

Create Table `Percent_Population_Vaccinated`
(
Continent text,
Location text,
`Date` text,
Population int,
New_vaccinations int,
RollingPeopleVaccinated  int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


Insert into Percent_Population_Vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject.CovidDeaths dea
Join PortfolioProject.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date;


Select *, (RollingPeopleVaccinated/Population)*100
From Percent_Population_Vaccinated;

DROP TABLE if exists Percent_Population_Vaccinated;

-- Creating View to store data for later visualizations

Create View Percent_Population_Vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject.CovidDeaths dea
Join PortfolioProject.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null ;




