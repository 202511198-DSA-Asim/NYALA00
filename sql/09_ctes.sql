-- Find active tariffs above the overall active-tariff average.
WITH active_tariffs AS (
    -- Step 1: Select tariffs active on the reference date.
    SELECT
        goods_id,
        origin_country_id,
        destination_country_id,
        tariff_percent
    FROM eac.tariff_rates
    WHERE effective_from <= DATE '2026-11-05'
      AND (
          effective_to IS NULL
          OR effective_to >= DATE '2026-11-05'
      )
),
tariff_average AS (
    -- Step 2: Calculate the average of those active records.
    SELECT AVG(tariff_percent) AS average_percent
    FROM active_tariffs
)
-- Step 3: Display records above that average.
SELECT
    g.goods_name,
    origin.country_name AS origin_country,
    destination.country_name AS destination_country,
    t.tariff_percent,
    ROUND(a.average_percent, 2) AS overall_average_percent,
    ROUND(
        t.tariff_percent - a.average_percent,
        2
    ) AS percentage_points_above_average
FROM active_tariffs AS t
JOIN eac.goods AS g
    ON g.goods_id = t.goods_id
JOIN eac.countries AS origin
    ON origin.country_id = t.origin_country_id
JOIN eac.countries AS destination
    ON destination.country_id = t.destination_country_id
CROSS JOIN tariff_average AS a
WHERE t.tariff_percent > a.average_percent
ORDER BY t.tariff_percent DESC, g.goods_name;