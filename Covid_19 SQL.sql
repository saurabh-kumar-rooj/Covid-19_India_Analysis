create  database covid_19
use Covid_19
select * from district_table
select * from time_series


-- Weekly evolution of number of confirmed cases, recovered cases, deaths, tests. For instance, your Excel chart should be able to compare Week 3 of May with Week 2 of August -- 
SELECT 
    state,
    year,
    Month_name,
    Month_number,
    Week_number,
    SUM(total_confirmed) AS confirmed,
    SUM(total_deceased) AS deceased,
    SUM(total_recovered) AS recovered,
    SUM(total_tested) AS tested,
    SUM(total_vaccinated) AS vaccinated
FROM 
    (
        SELECT 
            state,
            total_confirmed,
            total_recovered,
            total_deceased,
            total_tested,
            (total_vaccinated1 + total_vaccinated2) AS total_vaccinated,
            MONTH(Date) AS Month_number,
            DATE,
            MONTHNAME(Date) AS Month_name,
            YEAR(Date) AS year,
            (DATEDIFF(Date, DATE_ADD(Date, INTERVAL 1 - DAY(Date) DAY)) DIV 7 + 1) AS Week_number
        FROM 
            time_series
    ) AS table1
GROUP BY 
    state,
    Month_number,
    Month_name,
    year,
    Week_number
ORDER BY 
    Month_number,
    Week_number
    
    
---  Let’s call `testing ratio(tr) = (number of tests done) / (population)`, now categorize every district in one of the following categories:
--     - Category A: 0.05 ≤ tr ≤ 0.1
--     - Category B: 0.1 < tr ≤ 0.3
--     - Category C: 0.3 < tr ≤ 0.5
--     - Category D: 0.5 < tr ≤ 0.75
--     - Category E: 0.75 < tr ≤ 1.0
-- Now perform an analysis of several deaths across all categories.
SELECT 
    state, 
    District,
    total_confirmed, 
    total_deceased, 
    total_recovered,
    total_tested,
    (total_vaccinated1 + total_vaccinated2) as total_vaccinated,
    meta_population,
    (CAST(total_tested AS DECIMAL(10,2)) / CAST(meta_population AS DECIMAL(10,2))) AS Testing_ratio,
    CASE 
        WHEN (CAST(total_tested AS DECIMAL(10,2)) / CAST(meta_population AS DECIMAL(10,2))) BETWEEN 0.05 AND 0.1 THEN 'Category A'
        WHEN (CAST(total_tested AS DECIMAL(10,2)) / CAST(meta_population AS DECIMAL(10,2))) BETWEEN 0.1 AND 0.3 THEN 'Category B'
        WHEN (CAST(total_tested AS DECIMAL(10,2)) / CAST(meta_population AS DECIMAL(10,2))) BETWEEN 0.3 AND 0.5 THEN 'Category C'
        WHEN (CAST(total_tested AS DECIMAL(10,2)) / CAST(meta_population AS DECIMAL(10,2))) BETWEEN 0.5 AND 0.75 THEN 'Category D'
        WHEN (CAST(total_tested AS DECIMAL(10,2)) / CAST(meta_population AS DECIMAL(10,2))) BETWEEN 0.75 AND 1.0 THEN 'Category E'
    END AS Category
FROM district_table
WHERE meta_population != 0 AND total_tested != 0

-- INSIGHT 1
SELECT 
    state,
    DATE_FORMAT(date, '%M') as Date,
    YEAR(date) as year,
    SUM(total_recovered) as '1st_vaccination',
    SUM(total_vaccinated2) as '2nd_vaccination' 
FROM time_series
GROUP BY state, DATE_FORMAT(date, '%M'), YEAR(date);


-- insight 2

SELECT 
    state,
    DATE_FORMAT(date, '%M') as Date,
    YEAR(date) as year,
    SUM(total_recovered) as 'Recovery_rate'
FROM time_series
GROUP BY state, DATE_FORMAT(date, '%M'), YEAR(date);

-- INSIGHT 3

select state,SUM(total_recovered) as 'total_recovered',sum(total_confirmed) as 'total_confirmed'
from district_table
group by state

-- insight 4
SELECT 
    state,
    MONTHNAME(date) as month_name,
    MONTH(date) as month_num,
    SUM(total_confirmed) as no_of_cases
FROM time_series
GROUP BY state, MONTHNAME(date), MONTH(date)
ORDER BY month_num, no_of_cases DESC;

-- Insight 5

SELECT 
    state,
    MONTHNAME(date) as month_name,
    MONTH(date) as month_num,
    SUM(total_tested) as no_of_tested
FROM time_series
GROUP BY state, MONTHNAME(date), MONTH(date)
ORDER BY month_num, no_of_tested DESC;