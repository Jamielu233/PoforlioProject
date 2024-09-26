-- see all data
Select *
FROM coviddeaths
Where continent is not null

-- SELECT data that we are going to be using
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM coviddeaths
Where continent is not null
order by 1,2

-- looking at total_case VS total_deaths
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

-- looking at total_case VS population
SELECT location,date,population,total_cases,(total_cases/population)*100 AS PercentageInfective
FROM coviddeaths
Where location like "%states%"
and continent is not null
order by 1,2

SELECT
    location,
    Population,
    MAX(total_cases) as HighestInfestionCount,
    MAX((total_cases/population))*100 AS HightestInfectivePercentage
FROM
    coviddeaths
Where location like '%states%' and continent is not null
Group by
    location,
    population
order by 1,2

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population
Select continent, MAX(cast(Total_deaths as SIGNED)) as TotalDeathCount
From covidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global number
select
    sum(new_cases) as total_new_cases,
    sum(cast(new_deaths as SIGNED)) as total_new_deaths,
    sum(cast(new_deaths as SIGNED))/sum(new_cases)*100 as DeathPercentage
from coviddeaths
where continent is not null
-- GROUP BY  date
order by 1,2


SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location) AS RollingPeopleVaccinated
FROM
    coviddeaths dea
JOIN
    covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
ORDER BY
    dea.location,
    dea.date;

-- use CTE
select *,((RollingPeopleVaccinated/Population)*100) as VaccinationPercentage
FROM (
    SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location) AS RollingPeopleVaccinated
FROM
    coviddeaths dea
JOIN
    covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
) AS CTE


WITH PopvsVic(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS (
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location) AS RollingPeopleVaccinated
    FROM
        coviddeaths dea
    JOIN
        covidvaccinations vac
    ON
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL
)
SELECT *, ((RollingPeopleVaccinated/Population)*100) AS VaccinationPercentage
FROM PopvsVic

-- create tem table
CREATE TEMPORARY TABLE IF NOT EXISTS TempCovidData (
    continent VARCHAR(255),
    location VARCHAR(255),
    date DATETIME,
    Population NUMERIC,
    new_vaccinations INT,
    RollingPeopleVaccinated INT
);
-- 插入数据
INSERT INTO TempCovidData (continent, location, date, Population, new_vaccinations, RollingPeopleVaccinated)
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
    coviddeaths dea
JOIN
    covidvaccinations vac
ON
    dea.location = vac.location AND dea.date = vac.date;

SELECT *
FROM TempCovidData
ORDER BY location, date;

-- Creating View to store data for later visualizations
CREATE VIEW TempCovidData AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
    coviddeaths dea
JOIN
    covidvaccinations vac
ON
    dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;