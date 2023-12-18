

Select
	*
From
	PortfolioProject1..CovidDeaths
Where
	continent is not null
Order By 3,4

--Select
--	*
--From
--	PortfolioProject1..CovidVaccinations
--Order By 3,4


Select
	location, date, total_cases, new_cases, total_deaths, population
From
	PortfolioProject1..CovidDeaths
Order By
	1,2


--Total Cases vs Total Deaths
--Likelihood of death after contraction
Select 
	continent,location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as Death_Percentage
From
	PortfolioProject1..CovidDeaths
Where
	location = 'Philippines'
Order By
	1,2

--Total cases vs Population
--Percentage of population that got covid from Jan. 2020 to April 2021
Select 
	continent,location, date,population, total_cases,  (total_cases / population) * 100 as Case_Percentage
From
	PortfolioProject1..CovidDeaths
Where
	location = 'Philippines'
Order By
	1,2

--Countries highest infection rate Jan. 2020 to April 2021
Select 
	continent, location,population, MAX(total_cases) as Highest_Infection_Count,  (MAX(total_cases) / population) * 100 as Highest_Infection_Percentage
From
	PortfolioProject1..CovidDeaths
Where
	continent is not null
Group By
	continent, location, population
Order By
	Highest_Infection_Percentage DESC

--Countries death count per population Jan. 2020 to April 2021
Select 
	continent,location, MAX(cast(total_deaths as int)) as Death_Count
From
	PortfolioProject1..CovidDeaths
Where
	continent is not null
Group By
	continent,location
Order By
	Death_Count DESC

--Continental death count Jan. 2020 to April 2021
Select 
	continent, sum(cast(total_deaths as int)) as Death_Count
From
	PortfolioProject1..CovidDeaths
Where
	continent is not null
Group By
	continent
Order By
	Death_Count DESC

--Global numbers
Select 
	date, SUM(new_cases) as Global_cases, SUM(cast(new_deaths as int)) as Global_deaths, 
	Sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
From
	PortfolioProject1..CovidDeaths
Where
	continent is not null
Group by date 
Order By
	1,2


--Total population vs vaccinations
Select
	dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
	Sum(cast(new_vaccinations as int)) OVER 
		(Partition By dea.location Order By dea.location, dea.date) as Rolling_Total_Vaccinations
	
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
On
	dea.location = vac.location
	and dea.date = vac.date
Where
	dea.continent is not null
Order By
	2,3

--Vaccination vs population percentage Jan.2020 to April 2021
WITH PopvsVac (continent, location, date, population, new_Vaccinations, Rolling_Total_Vaccinations)
as
(
Select
	dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
	Sum(cast(new_vaccinations as int)) OVER 
		(Partition By dea.location Order By dea.location, dea.date) as Rolling_Total_Vaccinations
	
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
On
	dea.location = vac.location
	and dea.date = vac.date
Where
	dea.continent is not null
)
Select
	*, (Rolling_Total_Vaccinations/population)*100 as PopPercent_Vaccinated
From PopvsVac


--Temp Table alternative
DROP Table if exists #PercentPopVac
Create Table #PercentPopVac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vac numeric,
RollingTotalVac numeric
)
INSERT INTO #PercentPopVac
Select
	dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
	Sum(cast(new_vaccinations as int)) OVER 
		(Partition By dea.location Order By dea.location, dea.date) as Rolling_Total_Vaccinations
	
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
On
	dea.location = vac.location
	and dea.date = vac.date
Where
	dea.continent is not null
Order By
	2,3

Select
	*, (RollingTotalVac/population)*100 as PopPercent_Vaccinated
From #PercentPopVac


--View to store data for visualization
Create View PercentPopVac as
Select
	dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
	Sum(cast(new_vaccinations as int)) OVER 
		(Partition By dea.location Order By dea.location, dea.date) as Rolling_Total_Vaccinations
	
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
On
	dea.location = vac.location
	and dea.date = vac.date
Where
	dea.continent is not null
--Order By 2,3