/* ============================================================================
   Migration Project - Emigration Analysis
   ----------------------------------------------------------------------------
   Table  : emigration (imported via MySQL Table Data Import Wizard)
   Columns: Districts, `2014` ... `2025`, Total
   ============================================================================ */


/* ----------------------------------------------------------------------------
   0. Setup
   ---------------------------------------------------------------------------- */

CREATE DATABASE Emigration_project;

USE Emigration_project;

-- Data imported using the Table Data Import Wizard and named "emigration".

SELECT *
FROM emigration;


/* ----------------------------------------------------------------------------
   1. Top 10 districts by total emigration
   ---------------------------------------------------------------------------- */

SELECT
    Districts,
    Total
FROM emigration
ORDER BY Total DESC
LIMIT 10;


/* ----------------------------------------------------------------------------
   2. Year-wise emigration trend with year-over-year growth
   ---------------------------------------------------------------------------- */

WITH yearly AS (
    SELECT 2014 AS Year, SUM(`2014`) AS Total FROM emigration
    UNION ALL SELECT 2015, SUM(`2015`) FROM emigration
    UNION ALL SELECT 2016, SUM(`2016`) FROM emigration
    UNION ALL SELECT 2017, SUM(`2017`) FROM emigration
    UNION ALL SELECT 2018, SUM(`2018`) FROM emigration
    UNION ALL SELECT 2019, SUM(`2019`) FROM emigration
    UNION ALL SELECT 2020, SUM(`2020`) FROM emigration
    UNION ALL SELECT 2021, SUM(`2021`) FROM emigration
    UNION ALL SELECT 2022, SUM(`2022`) FROM emigration
    UNION ALL SELECT 2023, SUM(`2023`) FROM emigration
    UNION ALL SELECT 2024, SUM(`2024`) FROM emigration
    UNION ALL SELECT 2025, SUM(`2025`) FROM emigration
),

growth AS (
    SELECT
        Year,
        Total,
        LAG(Total) OVER (ORDER BY Year) AS Previous_Year
    FROM yearly
)

SELECT
    Year,
    Total,
    ROUND((Total - Previous_Year) * 100.0 / Previous_Year, 2) AS Growth_Percentage
FROM growth
ORDER BY Year;


/* ----------------------------------------------------------------------------
   3. Highest and lowest emigration years
   ---------------------------------------------------------------------------- */

WITH yearly AS (
    SELECT 2014 AS Year, SUM(`2014`) AS Total FROM emigration
    UNION ALL SELECT 2015, SUM(`2015`) FROM emigration
    UNION ALL SELECT 2016, SUM(`2016`) FROM emigration
    UNION ALL SELECT 2017, SUM(`2017`) FROM emigration
    UNION ALL SELECT 2018, SUM(`2018`) FROM emigration
    UNION ALL SELECT 2019, SUM(`2019`) FROM emigration
    UNION ALL SELECT 2020, SUM(`2020`) FROM emigration
    UNION ALL SELECT 2021, SUM(`2021`) FROM emigration
    UNION ALL SELECT 2022, SUM(`2022`) FROM emigration
    UNION ALL SELECT 2023, SUM(`2023`) FROM emigration
    UNION ALL SELECT 2024, SUM(`2024`) FROM emigration
    UNION ALL SELECT 2025, SUM(`2025`) FROM emigration
)

SELECT
    Year,
    Total,
    CASE
        WHEN Total = (SELECT MAX(Total) FROM yearly) THEN 'Highest Emigration'
        WHEN Total = (SELECT MIN(Total) FROM yearly) THEN 'Lowest Emigration'
    END AS Emigration_Status
FROM yearly
WHERE Total = (SELECT MAX(Total) FROM yearly)
   OR Total = (SELECT MIN(Total) FROM yearly);


/* ----------------------------------------------------------------------------
   4. Rank districts by total emigration (2014-2025)
   ---------------------------------------------------------------------------- */

SELECT
    Districts,
    Total_Emigrants,
    RANK() OVER (ORDER BY Total_Emigrants DESC) AS District_Rank
FROM (
    SELECT
        Districts,
        COALESCE(`2014`, 0)
            + COALESCE(`2015`, 0)
            + COALESCE(`2016`, 0)
            + COALESCE(`2017`, 0)
            + COALESCE(`2018`, 0)
            + COALESCE(`2019`, 0)
            + COALESCE(`2020`, 0)
            + COALESCE(`2021`, 0)
            + COALESCE(`2022`, 0)
            + COALESCE(`2023`, 0)
            + COALESCE(`2024`, 0)
            + COALESCE(`2025`, 0) AS Total_Emigrants
    FROM emigration
) AS district_totals
ORDER BY District_Rank;


/* ----------------------------------------------------------------------------
   5. Top 5 districts for each year
   ---------------------------------------------------------------------------- */

WITH yearly_districts AS (
    SELECT Districts, 2014 AS Year, `2014` AS Emigrants FROM emigration
    UNION ALL SELECT Districts, 2015, `2015` FROM emigration
    UNION ALL SELECT Districts, 2016, `2016` FROM emigration
    UNION ALL SELECT Districts, 2017, `2017` FROM emigration
    UNION ALL SELECT Districts, 2018, `2018` FROM emigration
    UNION ALL SELECT Districts, 2019, `2019` FROM emigration
    UNION ALL SELECT Districts, 2020, `2020` FROM emigration
    UNION ALL SELECT Districts, 2021, `2021` FROM emigration
    UNION ALL SELECT Districts, 2022, `2022` FROM emigration
    UNION ALL SELECT Districts, 2023, `2023` FROM emigration
    UNION ALL SELECT Districts, 2024, `2024` FROM emigration
    UNION ALL SELECT Districts, 2025, `2025` FROM emigration
),

ranked AS (
    SELECT
        Districts,
        Year,
        Emigrants,
        DENSE_RANK() OVER (
            PARTITION BY Year
            ORDER BY Emigrants DESC
        ) AS District_Rank
    FROM yearly_districts
)

SELECT *
FROM ranked
WHERE District_Rank <= 5
ORDER BY Year, District_Rank;


/* ----------------------------------------------------------------------------
   6. Year-over-year change for each district
   ---------------------------------------------------------------------------- */

WITH yearly_districts AS (
    SELECT Districts, 2014 AS Year, `2014` AS Emigrants FROM emigration
    UNION ALL SELECT Districts, 2015, `2015` FROM emigration
    UNION ALL SELECT Districts, 2016, `2016` FROM emigration
    UNION ALL SELECT Districts, 2017, `2017` FROM emigration
    UNION ALL SELECT Districts, 2018, `2018` FROM emigration
    UNION ALL SELECT Districts, 2019, `2019` FROM emigration
    UNION ALL SELECT Districts, 2020, `2020` FROM emigration
    UNION ALL SELECT Districts, 2021, `2021` FROM emigration
    UNION ALL SELECT Districts, 2022, `2022` FROM emigration
    UNION ALL SELECT Districts, 2023, `2023` FROM emigration
    UNION ALL SELECT Districts, 2024, `2024` FROM emigration
    UNION ALL SELECT Districts, 2025, `2025` FROM emigration
),

changes AS (
    SELECT
        Districts,
        Year,
        Emigrants,
        LAG(Emigrants) OVER (
            PARTITION BY Districts
            ORDER BY Year
        ) AS Previous_Year
    FROM yearly_districts
)

SELECT
    Districts,
    Year,
    Emigrants,
    Previous_Year,
    Emigrants - Previous_Year AS Emigration_Change,
    ROUND(
        (Emigrants - Previous_Year) * 100.0 / NULLIF(Previous_Year, 0),
        2
    ) AS Growth_Percentage
FROM changes
ORDER BY Districts, Year;


/* ----------------------------------------------------------------------------
   7. District ranking frequency (number of Top-5 appearances)
   ---------------------------------------------------------------------------- */

WITH yearly_districts AS (
    SELECT Districts, 2014 AS Year, `2014` AS Emigrants FROM emigration
    UNION ALL SELECT Districts, 2015, `2015` FROM emigration
    UNION ALL SELECT Districts, 2016, `2016` FROM emigration
    UNION ALL SELECT Districts, 2017, `2017` FROM emigration
    UNION ALL SELECT Districts, 2018, `2018` FROM emigration
    UNION ALL SELECT Districts, 2019, `2019` FROM emigration
    UNION ALL SELECT Districts, 2020, `2020` FROM emigration
    UNION ALL SELECT Districts, 2021, `2021` FROM emigration
    UNION ALL SELECT Districts, 2022, `2022` FROM emigration
    UNION ALL SELECT Districts, 2023, `2023` FROM emigration
    UNION ALL SELECT Districts, 2024, `2024` FROM emigration
    UNION ALL SELECT Districts, 2025, `2025` FROM emigration
),

ranked AS (
    SELECT
        Districts,
        Year,
        Emigrants,
        DENSE_RANK() OVER (
            PARTITION BY Year
            ORDER BY Emigrants DESC
        ) AS District_Rank
    FROM yearly_districts
)

SELECT
    Districts,
    COUNT(*) AS Top_5_Appearances
FROM ranked
WHERE District_Rank <= 5
GROUP BY Districts
ORDER BY Top_5_Appearances DESC;


/* ----------------------------------------------------------------------------
   8. Rank districts by average annual emigration
   ---------------------------------------------------------------------------- */

WITH yearly_districts AS (
    SELECT Districts, 2014 AS Year, `2014` AS Emigrants FROM emigration
    UNION ALL SELECT Districts, 2015, `2015` FROM emigration
    UNION ALL SELECT Districts, 2016, `2016` FROM emigration
    UNION ALL SELECT Districts, 2017, `2017` FROM emigration
    UNION ALL SELECT Districts, 2018, `2018` FROM emigration
    UNION ALL SELECT Districts, 2019, `2019` FROM emigration
    UNION ALL SELECT Districts, 2020, `2020` FROM emigration
    UNION ALL SELECT Districts, 2021, `2021` FROM emigration
    UNION ALL SELECT Districts, 2022, `2022` FROM emigration
    UNION ALL SELECT Districts, 2023, `2023` FROM emigration
    UNION ALL SELECT Districts, 2024, `2024` FROM emigration
    UNION ALL SELECT Districts, 2025, `2025` FROM emigration
),

district_averages AS (
    SELECT
        Districts,
        ROUND(AVG(Emigrants), 2) AS Average_Annual_Emigration
    FROM yearly_districts
    GROUP BY Districts
)

SELECT
    Districts,
    Average_Annual_Emigration,
    DENSE_RANK() OVER (ORDER BY Average_Annual_Emigration DESC) AS Average_Rank
FROM district_averages
ORDER BY Average_Rank;


/* ----------------------------------------------------------------------------
   9. Highest percentage growth between consecutive years (Top 10)
   ---------------------------------------------------------------------------- */

WITH yearly_districts AS (
    SELECT Districts, 2014 AS Year, `2014` AS Emigrants FROM emigration
    UNION ALL SELECT Districts, 2015, `2015` FROM emigration
    UNION ALL SELECT Districts, 2016, `2016` FROM emigration
    UNION ALL SELECT Districts, 2017, `2017` FROM emigration
    UNION ALL SELECT Districts, 2018, `2018` FROM emigration
    UNION ALL SELECT Districts, 2019, `2019` FROM emigration
    UNION ALL SELECT Districts, 2020, `2020` FROM emigration
    UNION ALL SELECT Districts, 2021, `2021` FROM emigration
    UNION ALL SELECT Districts, 2022, `2022` FROM emigration
    UNION ALL SELECT Districts, 2023, `2023` FROM emigration
    UNION ALL SELECT Districts, 2024, `2024` FROM emigration
    UNION ALL SELECT Districts, 2025, `2025` FROM emigration
),

growth AS (
    SELECT
        Districts,
        Year,
        Emigrants,
        LAG(Emigrants) OVER (
            PARTITION BY Districts
            ORDER BY Year
        ) AS Previous_Year
    FROM yearly_districts
)

SELECT
    Districts,
    Year,
    Emigrants,
    Previous_Year,
    ROUND(
        (Emigrants - Previous_Year) * 100.0 / NULLIF(Previous_Year, 0),
        2
    ) AS Growth_Percentage
FROM growth
WHERE Previous_Year > 0
ORDER BY Growth_Percentage DESC
LIMIT 10;


/* ----------------------------------------------------------------------------
   10. Largest absolute increases (Top 10)
   ---------------------------------------------------------------------------- */

WITH yearly_districts AS (
    SELECT Districts, 2014 AS Year, `2014` AS Emigrants FROM emigration
    UNION ALL SELECT Districts, 2015, `2015` FROM emigration
    UNION ALL SELECT Districts, 2016, `2016` FROM emigration
    UNION ALL SELECT Districts, 2017, `2017` FROM emigration
    UNION ALL SELECT Districts, 2018, `2018` FROM emigration
    UNION ALL SELECT Districts, 2019, `2019` FROM emigration
    UNION ALL SELECT Districts, 2020, `2020` FROM emigration
    UNION ALL SELECT Districts, 2021, `2021` FROM emigration
    UNION ALL SELECT Districts, 2022, `2022` FROM emigration
    UNION ALL SELECT Districts, 2023, `2023` FROM emigration
    UNION ALL SELECT Districts, 2024, `2024` FROM emigration
    UNION ALL SELECT Districts, 2025, `2025` FROM emigration
),

changes AS (
    SELECT
        Districts,
        Year,
        Emigrants,
        LAG(Emigrants) OVER (
            PARTITION BY Districts
            ORDER BY Year
        ) AS Previous_Year
    FROM yearly_districts
)

SELECT
    Districts,
    Year,
    Previous_Year,
    Emigrants,
    Emigrants - Previous_Year AS Absolute_Increase
FROM changes
WHERE Previous_Year IS NOT NULL
ORDER BY Absolute_Increase DESC
LIMIT 10;


/* ----------------------------------------------------------------------------
   11. Largest annual declines (Top 10)
   ---------------------------------------------------------------------------- */

WITH yearly_districts AS (
    SELECT Districts, 2014 AS Year, `2014` AS Emigrants FROM emigration
    UNION ALL SELECT Districts, 2015, `2015` FROM emigration
    UNION ALL SELECT Districts, 2016, `2016` FROM emigration
    UNION ALL SELECT Districts, 2017, `2017` FROM emigration
    UNION ALL SELECT Districts, 2018, `2018` FROM emigration
    UNION ALL SELECT Districts, 2019, `2019` FROM emigration
    UNION ALL SELECT Districts, 2020, `2020` FROM emigration
    UNION ALL SELECT Districts, 2021, `2021` FROM emigration
    UNION ALL SELECT Districts, 2022, `2022` FROM emigration
    UNION ALL SELECT Districts, 2023, `2023` FROM emigration
    UNION ALL SELECT Districts, 2024, `2024` FROM emigration
    UNION ALL SELECT Districts, 2025, `2025` FROM emigration
),

changes AS (
    SELECT
        Districts,
        Year,
        Emigrants,
        LAG(Emigrants) OVER (
            PARTITION BY Districts
            ORDER BY Year
        ) AS Previous_Year
    FROM yearly_districts
)

SELECT
    Districts,
    Year,
    Previous_Year,
    Emigrants,
    Emigrants - Previous_Year AS Absolute_Change
FROM changes
WHERE Previous_Year IS NOT NULL
  AND Emigrants < Previous_Year
ORDER BY Absolute_Change ASC
LIMIT 10;


/* ----------------------------------------------------------------------------
   12. Compare emigration across periods (Pre-COVID / COVID / Post-COVID)
   ---------------------------------------------------------------------------- */

WITH yearly_totals AS (
    SELECT 2017 AS Year, SUM(`2017`) AS Total_Emigrants FROM emigration
    UNION ALL SELECT 2018, SUM(`2018`) FROM emigration
    UNION ALL SELECT 2019, SUM(`2019`) FROM emigration
    UNION ALL SELECT 2020, SUM(`2020`) FROM emigration
    UNION ALL SELECT 2021, SUM(`2021`) FROM emigration
    UNION ALL SELECT 2022, SUM(`2022`) FROM emigration
    UNION ALL SELECT 2023, SUM(`2023`) FROM emigration
    UNION ALL SELECT 2024, SUM(`2024`) FROM emigration
    UNION ALL SELECT 2025, SUM(`2025`) FROM emigration
),

period_comparison AS (
    SELECT
        CASE
            WHEN Year BETWEEN 2017 AND 2019 THEN 'Pre-COVID'
            WHEN Year BETWEEN 2020 AND 2021 THEN 'COVID'
            WHEN Year BETWEEN 2022 AND 2025 THEN 'Post-COVID'
        END AS Period,
        COUNT(*)                         AS Number_of_Years,
        SUM(Total_Emigrants)             AS Total_Emigrants,
        ROUND(AVG(Total_Emigrants), 2)   AS Average_Annual_Emigration
    FROM yearly_totals
    GROUP BY Period
)

SELECT *
FROM period_comparison
ORDER BY FIELD(Period, 'Pre-COVID', 'COVID', 'Post-COVID');


/* ----------------------------------------------------------------------------
   13. Percentage change between periods
   ---------------------------------------------------------------------------- */

WITH yearly_totals AS (
    SELECT 2017 AS Year, SUM(`2017`) AS Total FROM emigration
    UNION ALL SELECT 2018, SUM(`2018`) FROM emigration
    UNION ALL SELECT 2019, SUM(`2019`) FROM emigration
    UNION ALL SELECT 2020, SUM(`2020`) FROM emigration
    UNION ALL SELECT 2021, SUM(`2021`) FROM emigration
    UNION ALL SELECT 2022, SUM(`2022`) FROM emigration
    UNION ALL SELECT 2023, SUM(`2023`) FROM emigration
    UNION ALL SELECT 2024, SUM(`2024`) FROM emigration
    UNION ALL SELECT 2025, SUM(`2025`) FROM emigration
),

period_averages AS (
    SELECT
        CASE
            WHEN Year BETWEEN 2017 AND 2019 THEN 'Pre-COVID'
            WHEN Year BETWEEN 2020 AND 2021 THEN 'COVID'
            WHEN Year BETWEEN 2022 AND 2025 THEN 'Post-COVID'
        END AS Period,
        AVG(Total) AS Average_Emigration
    FROM yearly_totals
    GROUP BY Period
)

SELECT
    ROUND(pre.Average_Emigration,  2) AS Pre_COVID_Average,
    ROUND(cov.Average_Emigration,  2) AS COVID_Average,
    ROUND(post.Average_Emigration, 2) AS Post_COVID_Average,

    ROUND(
        (cov.Average_Emigration - pre.Average_Emigration)
        / pre.Average_Emigration * 100,
        2
    ) AS COVID_Percentage_Change,

    ROUND(
        (post.Average_Emigration - pre.Average_Emigration)
        / pre.Average_Emigration * 100,
        2
    ) AS Post_COVID_Percentage_Change

FROM period_averages AS pre
JOIN period_averages AS cov  ON cov.Period  = 'COVID'
JOIN period_averages AS post ON post.Period = 'Post-COVID'
WHERE pre.Period = 'Pre-COVID';
