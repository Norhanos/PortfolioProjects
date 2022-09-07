SELECT location, ROUND((MAX(CONVERT(total_cases,signed))/AVG(population))*100,2) AS CasesPerPop, 
ROUND((MAX(CONVERT(total_deaths,signed))/AVG(population))*100,3) AS DeathsPerPop,
ROUND((MAX(CONVERT(total_deaths,signed))/MAX(CONVERT(total_cases,signed)))*100,3) AS DeathsPerCase
FROM CovidDeaths
WHERE continent !='' AND location !='North Korea'
GROUP BY location
ORDER BY DeathsPerCase DESC
;
