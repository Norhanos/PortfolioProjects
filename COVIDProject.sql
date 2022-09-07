
/*

This project uses data from: https://ourworldindata.org/covid-deaths

I wrote these querires to run on MySQL. 

*/

-- This query extracts from a table called CovidDeaths and shows the following columns: country name, the number of COVID cases
-- per country population in percent,the number of deaths per country population in percent, and the number of deaths per COVID cases in percent.


SELECT location, ROUND((MAX(CONVERT(total_cases,signed))/AVG(population))*100,2) AS CasesPerPop, 
ROUND((MAX(CONVERT(total_deaths,signed))/AVG(population))*100,3) AS DeathsPerPop,
ROUND((MAX(CONVERT(total_deaths,signed))/MAX(CONVERT(total_cases,signed)))*100,3) AS DeathsPerCase
FROM CovidDeaths
WHERE continent !='' AND location !='North Korea'
GROUP BY location
ORDER BY DeathsPerCase DESC
;


-- This query extracts from a table called CovidDeaths and shows the following columns: continent name, the number of deaths per continent
-- population, and a column which rates the second column as either being "high" or "low" depending on whether the value of the second 
-- column is higher or lower than the averge column value. 


WITH 

DPP (DeathsPerPop) AS
(SELECT MAX(total_deaths)/AVG(population)*100 AS DeathsPerPop
FROM CovidDeaths
WHERE location in (SELECT distinct(continent) 
FROM CovidDeaths
WHERE continent!=''
GROUP BY continent)
GROUP BY location),


LOCDPP(location,DeathsPerPop) AS
(SELECT location, MAX(total_deaths)/AVG(population)*100 AS DeathsPerPop
FROM CovidDeaths
GROUP BY location)



SELECT location, DeathsPerPop,
CASE
WHEN DeathsPerPop>(SELECT avg(DeathsPerPop) FROM DPP) THEN 'High'
ELSE 'Low'
END AS ComparedToAvg
FROM LOCDPP
WHERE location IN (SELECT distinct(continent) 
FROM CovidDeaths
WHERE continent!=''
GROUP BY continent)
ORDER BY location ASC
;


-- This query extracts from a table called CovidDeaths and a table called CovidVaccinations to create a new table called DPCStats (DPC stands
-- for DeathsPerCase). The DPCStats table has two records. One record represents the countries with the twenty highest DPC and the second record
-- represents the countries with the twenty lowest DPC. The DPCStats table shows how the average values of certain columns for these two 
-- groups of countries differ. The columns shown in the DPCStats table are the DPCCateogry (i.e. HighDPC or LowDPC), the average GDP of the 
-- countries in that DPC category, the average number of COVID tests administered per population in that DPC category, the average number of
-- COVID vaccinations administered per population in that DPC category, the average number of smokers per population in that DPC category, 
-- the average stringency index for that DPC category, the number of these countries that are located in Africa, the number of these countries
-- that are located in Asia, the number of these countries that are located in Europe, the number of these countries that are located in North 
-- America, the number of these countries that are located in Oceania, and the number of these countries that are located in South America. 


CREATE TABLE DPCStats (
    DPCCategory text,
    AvgGDP varchar(255),
    AvgTestsPerPop varchar(255),
    AvgVaccsPerPop varchar(255),
    AvgSmokersPerPop varchar(255),
    StringencyIDX varchar(255),
    Africa int,
    Asia int,
               Europe int,
	   NorthAmerica int,
               Oceania int,
               SouthAmerica int
);


CREATE TABLE HighDPC
SELECT cd.location,cd.continent,max(CONVERT(cd.total_deaths,signed))/max(CONVERT(cd.total_cases,signed)) AS DeathsPerCase, AVG(cv.gdp_per_capita) AS GDP ,MAX(CONVERT(cv.total_tests,signed))/AVG(cd.population) AS TestsPerPop,MAX(CONVERT(cv.total_vaccinations,signed))/AVG(cd.population) AS VaccsPerPop, ((AVG(cv.female_smokers) + AVG(cv.male_smokers))/ AVG(cd.population)) AS SmokersPerPop,AVG(cv.stringency_index) AS StringencyIDX
FROM CovidDeaths AS cd
JOIN covidvaccinations AS cv ON cd.location=cv.location AND cd.date=cv.date
WHERE cd.location!='North Korea' AND cd.continent!=''
GROUP BY location,continent
ORDER BY DeathsPerCase DESC
LIMIT 20;


CREATE TABLE LowDPC
SELECT cd.location,cd.continent,max(CONVERT(cd.total_deaths,signed))/max(CONVERT(cd.total_cases,signed)) AS DeathsPerCase, AVG(cv.gdp_per_capita) AS GDP ,MAX(CONVERT(cv.total_tests,signed))/AVG(cd.population) AS TestsPerPop,MAX(CONVERT(cv.total_vaccinations,signed))/AVG(cd.population) AS VaccsPerPop, ((AVG(cv.female_smokers) + AVG(cv.male_smokers))/ AVG(cd.population)) AS SmokersPerPop,AVG(cv.stringency_index) AS StringencyIDX
FROM CovidDeaths AS cd
JOIN covidvaccinations AS cv ON cd.location=cv.location AND cd.date=cv.date
WHERE cd.location!='North Korea' AND cd.continent!=''
GROUP BY location,continent
ORDER BY DeathsPerCase ASC
LIMIT 20;

INSERT INTO DPCStats
VALUES ('HighDPC',
(SELECT ROUND(AVG(GDP),0) FROM HighDPC) ,
(SELECT ROUND((AVG(TestsPerPop))*100,2) FROM HighDPC),
(SELECT ROUND((AVG(VaccsPerPop))*100,2) FROM HighDPC),
(SELECT ROUND((AVG(SmokersPerPop))*100,5) FROM HighDPC),
(SELECT ROUND(AVG(StringencyIDX),2) FROM HighDPC),
(SELECT COUNT(continent) FROM HighDPC WHERE continent='Africa'),
(SELECT COUNT(continent) FROM HighDPC WHERE continent='Asia'),
(SELECT COUNT(continent) FROM HighDPC WHERE continent='Europe'),
(SELECT COUNT(continent) FROM HighDPC WHERE continent='North America'),
(SELECT COUNT(continent) FROM HighDPC WHERE continent='Oceania'),
(SELECT COUNT(continent) FROM HighDPC WHERE continent='South America')
);

INSERT INTO DPCStats
VALUES ('LowDPC',
(SELECT ROUND(AVG(GDP),0) FROM LowDPC) ,
(SELECT ROUND((AVG(TestsPerPop))*100,2) FROM LowDPC),
(SELECT ROUND((AVG(VaccsPerPop))*100,2) FROM LowDPC),
(SELECT ROUND((AVG(SmokersPerPop))*100,5) FROM LowDPC),
(SELECT ROUND(AVG(StringencyIDX),2) FROM LowDPC),
(SELECT COUNT(continent) FROM LowDPC WHERE continent='Africa'),
(SELECT COUNT(continent) FROM LowDPC WHERE continent='Asia'),
(SELECT COUNT(continent) FROM LowDPC WHERE continent='Europe'),
(SELECT COUNT(continent) FROM LowDPC WHERE continent='North America'),
(SELECT COUNT(continent) FROM LowDPC WHERE continent='Oceania'),
(SELECT COUNT(continent) FROM LowDPC WHERE continent='South America')
);

--  This query extracts from a table called CovidDeaths and shows the following columns solely for Egypt in the year 2022: the country name,
-- the date in mm-dd, the total number of tests administered, the rate of positive tests, and the total number of vaccinations administered. 


SELECT location,SUBSTRING(date, 6,10) AS MonthDay,
MAX(CONVERT(total_tests,signed)) OVER (PARTITION BY location ORDER BY location,date) AS TotalTests, 
COALESCE(NULLIF(positive_rate,0),'') AS PositiveRate, 
MAX(CONVERT(total_vaccinations,signed)) OVER (PARTITION BY location ORDER BY location,date) AS TotalVaccs
FROM CovidVaccinations
WHERE location='Egypt' AND date >= '2022-01-01'
;


