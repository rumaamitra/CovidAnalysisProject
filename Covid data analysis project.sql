select * from dbo.CovidRelatedDeaths order by 3,4;
select * from dbo.CovidVaccinations order by 3,4;
select location,date,total_cases,new_cases,total_deaths,population
from dbo.CovidRelatedDeaths order by 1,2;

--Likelihood of dying if one contracts Covid in a country
select location, date, total_cases, total_deaths, cast(total_deaths as numeric)*100/cast(total_cases as numeric) as DeathPercentage 
from dbo.CovidRelatedDeaths where location='India' order by 1,2;

--How the likehood of death due to Covid changed over the years?
select location,YEAR(date) as Year,max(cast(total_deaths as numeric))*100/max(cast(total_cases as numeric)) as Death_Ratio 
from dbo.CovidRelatedDeaths group by location,YEAR(date) order by location,year
--Most developing nations struggled to prevent deaths due to infection in the 1st 2 years as the death ratio jumped up from 2020 to 2021 and then showed a downward trend in 2023. 
--These countries do not have the advanced infrastructer and skilled medical resources to proactively handle pandemic like situation.
--Developed nations demonstrated their maturity in handling disruptive situations and their advnced medical prowess as the death likelihood came down year on year

--What % of population contracted covid in India?
select location, date, population, total_cases, cast(total_cases as numeric)*100/population as InfectedPercentage 
from dbo.CovidRelatedDeaths where location='India' order by 1,2;

--What countries had the highest infection rates compared to the population?
select location, population, max(total_cases) as HighestInfectedCount, max(cast(total_cases as numeric)*100/population) as HighestInfectedRate 
from dbo.CovidRelatedDeaths where continent is not null group by location, population order by HighestInfectedRate desc;
--The highestInfection rate being 70.1%, India and China,the 2 most populous countries did a tremendous job at contatining the spread, 
--maintaining infection rate below 5% by introducing strict lockdown and policies pertaining to inward/outward/within country movements

--Countries with highest death rate per population
select location, population, max(total_deaths) as HighestDeathCount, max(cast(total_deaths as numeric)*100/population) as HighestDeathRate 
from dbo.CovidRelatedDeaths where continent is not null group by location, population order by HighestDeathRate desc;

--Which Continent has the highest death count?
select continent, max(cast(total_deaths as int)) as MaxDeathCount from dbo.CovidRelatedDeaths where continent is not null group by continent  order by MaxDeathCount desc;
--North America hadthe highest death count followed by South America and Asia

--Global death % change YoY
select Year(date), sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths, sum(new_deaths)*100/sum(new_cases) as GlobalDeathPercentage 
from dbo.CovidRelatedDeaths group by Year(date) order by YEAR(date);
--The death rate globally has shown YoY decline from when it began until 2022

--Find how many got vaccinated daily and the Rolling Total vaccination count per day
select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as int) as NewVaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingTotalVaccinations
from dbo.CovidRelatedDeaths dea join dbo.CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null order by 2,3;

--Find out which countries started the vaccination drive early
select dea.location, MIN(dea.date) as VaccinationStartDate
from dbo.CovidRelatedDeaths dea join dbo.CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null and cast(vac.new_vaccinations as int) is not null
group by dea.location order by VaccinationStartDate;
--Norway, US,Canada were the earliest vaccination drivers to start it in Dec-2020. 
--84.1% of the total countries had started vaccinating their population by mid-2021

--What is the % of vaccinated population
with VacPop 
as
(select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as int) as NewVaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingTotalVaccinations
from dbo.CovidRelatedDeaths dea join dbo.CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null)
select *, (RollingTotalVaccinations/population)*100 from VacPop;