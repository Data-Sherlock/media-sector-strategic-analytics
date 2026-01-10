-- Business Request – 1: Monthly Circulation Drop Check 
WITH circulation_with_previous AS (
    -- Get current and previous month circulation for each city
    SELECT 
        City_ID,
        State AS city_name,
        Month,
        Net_Circulation,
        LAG(Net_Circulation) OVER (
            PARTITION BY City_ID 
            ORDER BY Month
        ) AS prev_month_circulation
    FROM news_megazine.print_sales
    WHERE Month IS NOT NULL
),
mom_decline AS (
    -- Calculate month-over-month decline
    SELECT 
        city_name,
        Month,
        net_circulation,
        prev_month_circulation,
        (prev_month_circulation - net_circulation) AS circulation_decline
    FROM circulation_with_previous
    WHERE prev_month_circulation IS NOT NULL
        AND net_circulation < prev_month_circulation  -- Only declines
)
-- Get top 3 sharpest declines
SELECT 
    city_name,
    Month AS month,
    net_circulation
FROM mom_decline
ORDER BY circulation_decline DESC
LIMIT 3;


-- Business Request – 2: Yearly Revenue Concentration by Category 




-- Try this query to see ALL categories with their percentages (not filtered by >50%)
WITH quarterly_revenue AS (
    SELECT 
        ar.ad_category,
        ac.standard_ad_category AS category_name,
        -- Multiple extraction methods to handle different formats
        COALESCE(
            CASE WHEN ar.quarter LIKE '%-Q%' THEN LEFT(ar.quarter, 4) END,
            CASE WHEN ar.quarter LIKE '%Qtr%' THEN RIGHT(ar.quarter, 4) END,
            CASE WHEN ar.quarter LIKE 'Q%-%' THEN RIGHT(ar.quarter, 4) END
        ) AS year,
        ar.ad_revenue
    FROM news_megazine.ad_revenue ar
    LEFT JOIN news_megazine.ad_catagory ac 
        ON ar.ad_category = ac.ad_category_id
),
yearly_totals AS (
    SELECT 
        year,
        SUM(ad_revenue) AS total_revenue_year
    FROM quarterly_revenue
    WHERE year IS NOT NULL
    GROUP BY year
),
category_yearly AS (
    SELECT 
        qr.year,
        qr.category_name,
        SUM(qr.ad_revenue) AS category_revenue
    FROM quarterly_revenue qr
    WHERE qr.year IS NOT NULL
    GROUP BY qr.year, qr.category_name
)
-- Show ALL categories with percentages (remove the WHERE filter to debug)
SELECT 
    cy.year,
    cy.category_name,
    cy.category_revenue,
    yt.total_revenue_year,
    ROUND((cy.category_revenue / yt.total_revenue_year * 100), 2) AS pct_of_year_total
FROM category_yearly cy
JOIN yearly_totals yt ON cy.year = yt.year
-- Remove the filter temporarily to see all results
-- WHERE (cy.category_revenue / yt.total_revenue_year) > 0.50
ORDER BY year, pct_of_year_total DESC;




-- Business Request – 3: 2024 Print Efficiency Leaderboard 


WITH city_2024_totals AS (
    -- Sum all 2024 data for each city
    SELECT 
        City_ID,
        State AS city_name,
        SUM(Copies_Sold + copies_returned) AS copies_printed_2024,
        SUM(Net_Circulation) AS net_circulation_2024
    FROM news_megazine.p_sales 
    WHERE Month LIKE '24-%'  -- Filter for 2024 data (format: 24-mmm)
    GROUP BY City_ID, State
),
efficiency_calc AS (
    -- Calculate efficiency ratio
    SELECT 
        city_name,
        copies_printed_2024,
        net_circulation_2024,
        ROUND(net_circulation_2024 / copies_printed_2024, 4) AS efficiency_ratio
    FROM city_2024_totals
    WHERE copies_printed_2024 > 0  -- Avoid division by zero
),
ranked_efficiency AS (
    -- Rank cities by efficiency
    SELECT 
        city_name,
        copies_printed_2024,
        net_circulation_2024,
        efficiency_ratio,
        RANK() OVER (ORDER BY efficiency_ratio DESC) AS efficiency_rank_2024
    FROM efficiency_calc
)
-- Return top 5
SELECT 
    city_name,
    copies_printed_2024,
    net_circulation_2024,
    efficiency_ratio,
    efficiency_rank_2024
FROM ranked_efficiency
WHERE efficiency_rank_2024 <= 5
ORDER BY efficiency_rank_2024;


--  Business Request – 4 : Internet Readiness Growth (2021) 


WITH q1_2021 AS (
    -- Get Q1 2021 internet penetration for each city
    SELECT 
        city_id,
        internet_penetration AS internet_rate_q1_2021
    FROM news_megazine.city_readiness
    WHERE quarter = '2021-Q1'
),
q4_2021 AS (
    -- Get Q4 2021 internet penetration for each city
    SELECT 
        city_id,
        internet_penetration AS internet_rate_q4_2021
    FROM news_megazine.city_readiness
    WHERE quarter = '2021-Q4'
),
city_comparison AS (
    -- Join Q1 and Q4 data and calculate delta
    SELECT 
        q1.city_id,
        q1.internet_rate_q1_2021,
        q4.internet_rate_q4_2021,
        (q4.internet_rate_q4_2021 - q1.internet_rate_q1_2021) AS delta_internet_rate
    FROM q1_2021 q1
    INNER JOIN q4_2021 q4 ON q1.city_id = q4.city_id
),
with_city_names AS (
    -- Add city names from p_sales table
    SELECT DISTINCT
        cc.city_id,
        ps.State AS city_name,
        cc.internet_rate_q1_2021,
        cc.internet_rate_q4_2021,
        cc.delta_internet_rate
    FROM city_comparison cc
    LEFT JOIN news_megazine.p_sales ps ON cc.city_id = ps.City_ID
)
-- Return city with highest improvement
SELECT 
    city_name,
    internet_rate_q1_2021,
    internet_rate_q4_2021,
    delta_internet_rate
FROM with_city_names
ORDER BY delta_internet_rate DESC
LIMIT 1;


-- Business Request – 5: Consistent Multi-Year Decline (2019→2024) 

WITH yearly_circulation AS (
    -- Calculate yearly net circulation per city
    SELECT 
        City_ID,
        State AS city_name,
        year,
        SUM(Net_Circulation) AS yearly_net_circulation
    FROM news_megazine.p_sales
    WHERE year BETWEEN '2019' AND '2024'
    GROUP BY City_ID, State, year
),
yearly_ad_revenue AS (
    -- Calculate yearly ad revenue (total market-wide)
    SELECT 
        year,
        SUM(ad_revenue) AS yearly_ad_revenue
    FROM news_megazine.ad_revenue
    WHERE year BETWEEN '2019' AND '2024'
    GROUP BY year
),
combined_yearly AS (
    -- Combine circulation and ad revenue by year
    SELECT 
        yc.City_ID,
        yc.city_name,
        yc.year,
        yc.yearly_net_circulation,
        ya.yearly_ad_revenue
    FROM yearly_circulation yc
    LEFT JOIN yearly_ad_revenue ya ON yc.year = ya.year
),
with_previous_year AS (
    -- Get previous year values for comparison
    SELECT 
        City_ID,
        city_name,
        year,
        yearly_net_circulation,
        yearly_ad_revenue,
        LAG(yearly_net_circulation) OVER (PARTITION BY City_ID ORDER BY year) AS prev_circulation,
        LAG(yearly_ad_revenue) OVER (PARTITION BY City_ID ORDER BY year) AS prev_ad_revenue
    FROM combined_yearly
),
decline_check AS (
    -- Check if each year declined from previous
    SELECT 
        City_ID,
        city_name,
        year,
        yearly_net_circulation,
        yearly_ad_revenue,
        CASE 
            WHEN prev_circulation IS NULL THEN 0
            WHEN yearly_net_circulation < prev_circulation THEN 1
            ELSE 0
        END AS circulation_declined,
        CASE 
            WHEN prev_ad_revenue IS NULL THEN 0
            WHEN yearly_ad_revenue < prev_ad_revenue THEN 1
            ELSE 0
        END AS ad_revenue_declined
    FROM with_previous_year
),
city_summary AS (
    -- Count decline years for each city
    SELECT 
        City_ID,
        city_name,
        SUM(CASE WHEN year > '2019' THEN 1 ELSE 0 END) AS comparison_years,
        SUM(CASE WHEN year > '2019' AND circulation_declined = 1 THEN 1 ELSE 0 END) AS circ_decline_count,
        SUM(CASE WHEN year > '2019' AND ad_revenue_declined = 1 THEN 1 ELSE 0 END) AS ad_decline_count
    FROM decline_check
    GROUP BY City_ID, city_name
),
city_flags AS (
    -- Flag cities with significant declining trend (3+ years out of 5)
    SELECT 
        City_ID,
        city_name,
        circ_decline_count,
        ad_decline_count,
        CASE 
            WHEN circ_decline_count >= 3 THEN 'Yes'
            ELSE 'No'
        END AS is_declining_print,
        CASE 
            WHEN ad_decline_count >= 3 THEN 'Yes'
            ELSE 'No'
        END AS is_declining_ad_revenue
    FROM city_summary
)
-- Final result with all required fields
SELECT 
    dc.city_name,
    dc.year,
    dc.yearly_net_circulation,
    dc.yearly_ad_revenue,
    cf.is_declining_print,
    cf.is_declining_ad_revenue,
    CASE 
        WHEN cf.is_declining_print = 'Yes' AND cf.is_declining_ad_revenue = 'Yes' THEN 'Yes'
        ELSE 'No'
    END AS is_declining_both
FROM decline_check dc
JOIN city_flags cf ON dc.City_ID = cf.City_ID
WHERE cf.is_declining_print = 'Yes' 
   OR cf.is_declining_ad_revenue = 'Yes'
ORDER BY dc.city_name, dc.year;



-- Business Request – 6 : 2021 Readiness vs Pilot Engagement Outlier 


WITH readiness_2021 AS (
    -- Calculate average readiness score for 2021 (average across all quarters)
    SELECT 
        city_id,
        AVG((smartphone_penetration + internet_penetration + literacy_rate) / 3) AS readiness_score_2021
    FROM news_megazine.city_readiness
    WHERE quarter LIKE '2021-%'
    GROUP BY city_id
),
engagement_2021 AS (
    -- Calculate digital pilot engagement metrics for 2021
    -- Note: digital_pilot should have city_id column
    SELECT 
        city_id,
        SUM(users_reached) AS total_users_reached,
        SUM(downloads_or_accesses) AS total_downloads,
        AVG(avg_bounce_rate) AS avg_bounce_rate,
        -- Engagement rate = downloads / users_reached
        CASE 
            WHEN SUM(users_reached) > 0 
            THEN ROUND((SUM(downloads_or_accesses) / SUM(users_reached)) * 100, 2)
            ELSE 0 
        END AS engagement_rate
    FROM news_megazine.digital_pilot
    WHERE launch_month LIKE '2021-%'
    GROUP BY city_id
),
combined_data AS (
    -- Combine readiness and engagement data by city_id
    SELECT 
        ps.City_ID,
        ps.State AS city_name,
        r.readiness_score_2021,
        e.engagement_rate AS engagement_metric_2021
    FROM readiness_2021 r
    JOIN engagement_2021 e ON r.city_id = e.city_id
    LEFT JOIN news_megazine.p_sales ps ON r.city_id = ps.City_ID
    WHERE r.readiness_score_2021 IS NOT NULL 
      AND e.engagement_rate IS NOT NULL
    GROUP BY ps.City_ID, ps.State, r.readiness_score_2021, e.engagement_rate
),
ranked_data AS (
    -- Rank cities by readiness (descending) and engagement (ascending)
    SELECT 
        city_name,
        ROUND(readiness_score_2021, 2) AS readiness_score_2021,
        engagement_metric_2021,
        RANK() OVER (ORDER BY readiness_score_2021 DESC) AS readiness_rank_desc,
        RANK() OVER (ORDER BY engagement_metric_2021 ASC) AS engagement_rank_asc
    FROM combined_data
)
-- Identify the outlier: highest readiness but bottom 3 engagement
SELECT 
    city_name,
    readiness_score_2021,
    engagement_metric_2021,
    readiness_rank_desc,
    engagement_rank_asc,
    CASE 
        WHEN readiness_rank_desc = 1 AND engagement_rank_asc <= 3 THEN 'Yes'
        ELSE 'No'
    END AS is_outlier
FROM ranked_data
WHERE engagement_rank_asc <= 3  -- Bottom 3 in engagement
ORDER BY readiness_rank_desc, engagement_rank_asc
;
