
SELECT *
FROM PortifolioProject..CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--FROM PortifolioProject..CovidVaccinations
--where continent is not null
--order by 3,4 


--SELECTING THE REQUIRED DATA

select Location, date, total_cases, new_cases, total_deaths, population
from PortifolioProject..CovidDeaths
order by 1,2


--TOTAL CASES VS TOTAL DEATHS ANALYSIS 
--Shows the chance of Dying If you're diagnosed with Covid in your country

select Location, date, total_cases, total_deaths, Round((total_deaths/total_cases)*100,3) as Death_percentage
from PortifolioProject..CovidDeaths
Where location like '%India%'
order by 1,2 


--TOTAL CASES VS TOTAL POPULATION ANALYSIS
--Shows the Percentage of Population got Covid

select Location,date,population, total_cases,  (total_cases/population)*100 as InfectedPercentage
from PortifolioProject..CovidDeaths
Where location like '%India%'
order by 1,2


--COUNTRIES WITH HIGHEST INFECTION PERCENTAGE

select Location,population, Max(total_cases)as HighestInfectionCount,  Max((total_cases/population))*100 as InfectedPercentage
from PortifolioProject..CovidDeaths
Group By Location,population
order by InfectedPercentage DESC


--COUNTRIES WITH HIGHEST DEATH COUNT

select Location, Max(cast(total_deaths as INT)) AS TotalDeathCount
from PortifolioProject..CovidDeaths
where continent is not null
Group By Location,population
order by TotalDeathCount DESC


--HIGHEST DEATH COUNT BY CONTINENT

select Location, Max(cast(total_deaths as INT)) AS TotalDeathCount
from PortifolioProject..CovidDeaths
where continent is null
Group By Location
order by TotalDeathCount DESC


--GLOBAL NUMBERS

Select sum(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/sum(new_cases) * 100 AS DeathPercentage
from PortifolioProject..CovidDeaths
--Where location like '%India%'
where continent is not null
--Group By date
order by 1


--TOTAL POPULATION VS VACCINATIONS

Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, Sum(CONVERT(INT,CV.new_vaccinations)) over(partition by CD.location ORDER BY  CD.date ) as RunningVaccinationCount
From PortifolioProject..CovidDeaths CD
join PortifolioProject..CovidVaccinations CV
ON CD.location = CV.location AND CD.date = CV.date 
where cd.continent is not null

--Using CTE

With popVSvac as (
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, Sum(CONVERT(INT,CV.new_vaccinations)) over(partition by CD.location ORDER BY  CD.date ) as RunningVaccinationCount
From PortifolioProject..CovidDeaths CD
join PortifolioProject..CovidVaccinations CV
ON CD.location = CV.location AND CD.date = CV.date 
where cd.continent is not null
)
select *, RunningVaccinationCount/population*100 as VaccinationPerc
from popVSvac
---Where location like '%India%'


--Using Temp Table

Drop Table if exists #RunningVaccinationPerc
create Table #RunningVaccinationPerc
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RunningVaccinationCount numeric
)

insert into #RunningVaccinationPerc 
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, Sum(CONVERT(INT,CV.new_vaccinations)) over(partition by CD.location ORDER BY  CD.date ) as RunningVaccinationCount
From PortifolioProject..CovidDeaths CD
join PortifolioProject..CovidVaccinations CV
ON CD.location = CV.location AND CD.date = CV.date 
where cd.continent is not null

select *, RunningVaccinationCount/population*100 as VaccinationPerc
from #RunningVaccinationPerc
--Where location like '%India%'


--Using Views for later Visualizations

Create View RunningVaccinationPerc as 
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, Sum(CONVERT(INT,CV.new_vaccinations)) over(partition by CD.location ORDER BY  CD.date ) as RunningVaccinationCount
From PortifolioProject..CovidDeaths CD
join PortifolioProject..CovidVaccinations CV
ON CD.location = CV.location AND CD.date = CV.date 
where cd.continent is not null

Select *, RunningVaccinationCount/population*100 as VaccinationPerc
from RunningVaccinationPerc
--Where location like '%India%'

