Drop table if exists CovidDeaths;

BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS CovidDeaths(
iso_code TEXT, continent TEXT, location TEXT, date TEXT,
 population TEXT, total_cases TEXT, new_cases TEXT, new_cases_smoothed TEXT,
 total_deaths TEXT, new_deaths TEXT, new_deaths_smoothed TEXT, total_cases_per_million TEXT,
 new_cases_per_million TEXT, new_cases_smoothed_per_million TEXT, total_deaths_per_million TEXT, new_deaths_per_million TEXT,
 new_deaths_smoothed_per_million TEXT, reproduction_rate TEXT, icu_patients TEXT, icu_patients_per_million TEXT,
 hosp_patients TEXT, hosp_patients_per_million TEXT, weekly_icu_admissions TEXT, weekly_icu_admissions_per_million TEXT,
 weekly_hosp_admissions TEXT, weekly_hosp_admissions_per_million TEXT);
commit;

Drop table if exists CovidVaccinations;
BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS CovidVaccinations(
iso_code TEXT, continent TEXT, location TEXT, date TEXT,
 new_tests TEXT, total_tests TEXT, total_tests_per_thousand TEXT, new_tests_per_thousand TEXT,
 new_tests_smoothed TEXT, new_tests_smoothed_per_thousand TEXT, positive_rate TEXT, tests_per_case TEXT,
 tests_units TEXT, total_vaccinations TEXT, people_vaccinated TEXT, people_fully_vaccinated TEXT,
 new_vaccinations TEXT, new_vaccinations_smoothed TEXT, total_vaccinations_per_hundred TEXT, people_vaccinated_per_hundred TEXT,
 people_fully_vaccinated_per_hundred TEXT, new_vaccinations_smoothed_per_million TEXT, stringency_index TEXT, population_density TEXT,
 median_age TEXT, aged_65_older TEXT, aged_70_older TEXT, gdp_per_capita TEXT,
 extreme_poverty TEXT, cardiovasc_death_rate TEXT, diabetes_prevalence TEXT, female_smokers TEXT,
 male_smokers TEXT, handwashing_facilities TEXT, hospital_beds_per_thousand TEXT, life_expectancy TEXT,
 human_development_index TEXT);
 commit;
 
Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order By location, date;

--##converting text to required format

ALTER TABLE CovidDeaths ALTER COLUMN total_deaths TYPE float using total_deaths::float;
--USING (CASE WHEN total_deaths = '' THEN 0 ELSE total_deaths::int END);
ALTER TABLE CovidDeaths ALTER COLUMN total_cases TYPE float using total_cases::float;
--USING (CASE WHEN total_cases = '' THEN 0.0 ELSE total_cases::int END);
ALTER TABLE CovidDeaths ALTER COLUMN population TYPE numeric
  USING (CASE WHEN population = '' THEN 0.0 ELSE population::numeric END);

--Looking at total cases vs total deaths
--likelihood of deaths if someone contract covid in Canada


Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
From CovidDeaths
Where location = 'Canada'
Order By location, date;

--Looking total cases vs populations
--Percentage of people got COVID

Select location, date, total_cases, population, (total_cases/population)*100 as cases_rate
From CovidDeaths
Where location = 'Canada'
Order By location, date;

--Looking at countries with highest infection rate

Select location, population, max(total_cases) as highest_cases, max((total_cases/population)*100) as cases_rate_per_population
From CovidDeaths
Group By location, population
Having max((total_cases/population)*100) is not null
Order By highest_cases_rate desc;

--Showing countries with highest death rates per population

Select location, population, max(total_deaths) as highest_deaths, max((total_deaths/population)*100) as deaths_rate_per_population
From CovidDeaths
Group By location, population
Having max((total_deaths/population)*100) is not null
Order By deaths_rate_per_population desc;

--Showing countries with highest death counts per population

Select location, population, max(total_deaths) as highest_deaths, max((total_deaths/population)*100) as deaths_rate_per_population
From CovidDeaths
Group By location, population
Having max((total_deaths/population)*100) is not null
Order By deaths_rate_per_population desc;

--Showing continent with total death count

Select continent, max(cast (total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeathCount desc;

--Worlwide covid scenario by date

Select date, sum(cast(new_cases as int)) as world_cases, 
sum(cast(new_deaths as int)) as world_deaths,
(sum(cast(new_deaths as int))/sum(cast(new_cases as float)))*100 as world_death_rate
From CovidDeaths
Where continent is not null
Group by date
Order by date;

--Total vaccination by country/location

Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
 SUM(cast(v.new_vaccinations as int)) OVER (Partition by d.location Order by d.location, d.date)
From covidDeaths as d
Join covidVaccinations as v
	ON d.date = v.date
	and d.location = v.location
Where d.continent is not null
Order by d.location, d.date;

With cte as (
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(cast(v.new_vaccinations as int)) OVER (Partition by d.location Order by d.location, d.date)
as RollingPeopleVaccinated
From covidDeaths as d
Join covidVaccinations as v
	ON d.date = v.date
	and d.location = v.location
Where d.continent is not null
Order by d.location, d.date
	)
Select *, (RollingPeopleVaccinated/Population*100) as perc_vaccination
From cte;

--Creating Temp Table

Drop table if exists PercentPeopleVaccinated;
Create table PercentPeopleVaccinated
(
Continent varchar(255),
Location varchar(255),
Date date,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
perc_vaccination numeric
)
;
Insert into PercentPeopleVaccinated
(With cte as (
Select d.continent, d.location, cast(d.date as date), d.population, cast(v.new_vaccinations as numeric),
SUM(cast(v.new_vaccinations as int)) OVER (Partition by d.location Order by d.location, d.date)
as RollingPeopleVaccinated
From covidDeaths as d
Join covidVaccinations as v
	ON d.date = v.date
	and d.location = v.location
Where d.continent is not null
Order by d.location, d.date
	)
Select *, (RollingPeopleVaccinated/Population*100) as perc_vaccination
From cte)
;

--Creating View for later use

Create view PeopleVaccinated as

(With cte as (
Select d.continent, d.location, cast(d.date as date), d.population, cast(v.new_vaccinations as numeric),
SUM(cast(v.new_vaccinations as int)) OVER (Partition by d.location Order by d.location, d.date)
as RollingPeopleVaccinated
From covidDeaths as d
Join covidVaccinations as v
	ON d.date = v.date
	and d.location = v.location
Where d.continent is not null
Order by d.location, d.date
	)
Select *, (RollingPeopleVaccinated/Population*100) as perc_vaccination
From cte)
;
 