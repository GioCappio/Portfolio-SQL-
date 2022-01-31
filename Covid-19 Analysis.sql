-- Some data exploration first

SELECT  *
FROM `thermal-highway-331208.Covid.deaths` 
ORDER BY location, date;

--SELECT *
--FROM thermal-highway-331208.Covid.vaccinations
--ORDER BY location, date;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `thermal-highway-331208.Covid.deaths`
WHERE  continent is not null
ORDER BY 1,2;

-- Looking at tot cases vs tot deaths for Italy and Bulgaria
-- Shows the lethality rate, i.e. the number of people died on the number of people who caught the deseas.
-- due to difference in the way countries decide to count how many people have been sick, this number can 
-- vary quite a bit thorugh different countries.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM `thermal-highway-331208.Covid.deaths`
where location like 'Bul%' or location like 'Italy'
and  continent is not null
ORDER BY 1,2;

-- Looking at population vs tot deaths for Italy and Bulgaria
-- Shows the mortality rate, that is the number of deaths on the total poulation
-- Ne deriva che il tasso di letalità è una percentuale più consistente rispetto 
-- a quella del tasso di mortalità, che però restituisce un dato più rilevante per 
-- la valutazione dei rischi che comporta un’epidemia per tutta la popolazione.

SELECT location, date, population, (total_deaths/population)*100 as Death_Percentage
FROM `thermal-highway-331208.Covid.deaths`
where location like 'Italy' or location like 'Bulgaria'
and  continent is not null
ORDER BY 1,2;

-- Which country has the highest infection rate compared to population

SELECT location, population, MAX(total_cases) as highest_infection_count, 
MAX((total_deaths/population))*100 as Max_Mortality_Rate, MAX(total_cases/population)*100 as
Max_population_infected_perc
FROM `thermal-highway-331208.Covid.deaths`
-- where location like 'Italy' or location like 'Bulgaria'
WHERE   continent is not null
GROUP BY location, population
ORDER BY Max_population_infected_perc desc;

-- Shows countries with highest deaths count

SELECT location, population, MAX(total_deaths) as death_count, 
MAX((total_deaths/population))*100 as Mortality_Rate
FROM `thermal-highway-331208.Covid.deaths`
-- where location like 'Italy' or location like 'Bulgaria'
WHERE continent is not null
GROUP BY location, population
ORDER BY Mortality_Rate desc;

-- from this view, we have few aggregate data that we shouldn't have
-- like continents, or aggregation by income.
-- it is necesseray to investingate the issue deeper

SELECT *
FROM `thermal-highway-331208.Covid.deaths`
WHERE location like '%income%';

SELECT location, SUM(total_deaths)
FROM `thermal-highway-331208.Covid.deaths`
WHERE continent is null
GROUP BY location;

-- It appears that by fcusing on the observations that have the variable
-- continent is null we intercepts all of the problematic observations.
-- So to remove it is sufficient to add to all the previous, and future, 
-- queries the command "where continent is not null".


-- Show mortality rate rank, by continents and by income bracket:

SELECT location, population, MAX(total_deaths) as death_count, 
MAX((total_deaths/population))*100 as Mortality_Rate
FROM `thermal-highway-331208.Covid.deaths`
-- where location like 'Italy' or location like 'Bulgaria'
WHERE continent is null
GROUP BY location, population
ORDER BY Mortality_Rate desc;

-- world break down
SELECT SUM(population), MAX(total_cases) as world_tot_cases, MAX(total_deaths) as world_tot_deaths,
(MAX(total_deaths)/MAX(total_cases))*100 as lethality_rate
FROM `thermal-highway-331208.Covid.deaths`
WHERE continent is not null 
order by 1,2;

-- Join the deaths data with the vaccinations data
SELECT dea.continent, dea.location, dea.date, dea.population, dea.total_deaths,
    dea.total_cases, vac.new_vaccinations, vac.total_vaccinations, vac.total_boosters,
    SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Sum_vacc
FROM `thermal-highway-331208.Covid.deaths` dea
FULL OUTER JOIN `thermal-highway-331208.Covid.vaccinations` vac
on dea.iso_code=vac.iso_code
AND dea.date=vac.date
WHERE dea.continent is not null
ORDER BY dea.location,  dea.date;

-- I created a new varable, which is the sum of all new vaccinations, divided per country 
-- and per day. In theory, this new variable should be equivalent to the already existing variable
-- total_vaccinations. but that is not the case. The problem appears to be that for some day, the value 
-- for new vaccinations are missing, but they are still counted in the total vaccinations.
-- My guess is that the data for the weekend are not reported, in the new vaccinations variables, and therefore, 
-- the new variable does not count them. 

-- However, I want to create  a CTE with the new variable created.

-- CTE

WITH PopandVacc as
--    (Continent, Location, Date, Population, New_Vaccinations,Total_Vaccines)
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Sum_vacc
FROM `thermal-highway-331208.Covid.deaths` dea
FULL OUTER JOIN `thermal-highway-331208.Covid.vaccinations` vac
on dea.iso_code=vac.iso_code
AND dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY dea.location,  dea.date
)
SELECT *, (Sum_vacc/population)*100 as perc_vacc
FROM PopandVacc;

-- Creating View to store data for later visualisation

DROP TABLE IF EXISTS `thermal-highway-331208.Covid.PercPopVaccinated`
CREATE VIEW  `thermal-highway-331208.Covid.PercPopVaccinated`
(Continent, Location, Date, Population, New_Vaccinations,Total_Vaccines)
as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Sum_vacc
FROM `thermal-highway-331208.Covid.deaths` dea
FULL OUTER JOIN `thermal-highway-331208.Covid.vaccinations` vac
on dea.iso_code=vac.iso_code
AND dea.date=vac.date
WHERE dea.continent is not null;
