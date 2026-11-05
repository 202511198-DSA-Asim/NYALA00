-- Q1: List goods and their categories.
SELECT
    g.goods_code,
    g.goods_name,
    c.category_name
FROM eac.goods AS g
JOIN eac.goods_categories AS c
    ON c.category_id = g.category_id
ORDER BY c.category_name, g.goods_name;

-- Q2: Active tariffs above 10% on the reference date.
SELECT
    g.goods_name,
    origin.country_name AS origin_country,
    destination.country_name AS destination_country,
    t.tariff_percent
FROM eac.tariff_rates AS t
JOIN eac.goods AS g
    ON g.goods_id = t.goods_id
JOIN eac.countries AS origin
    ON origin.country_id = t.origin_country_id
JOIN eac.countries AS destination
    ON destination.country_id = t.destination_country_id
WHERE t.effective_from <= DATE '2026-11-05'
  AND (
      t.effective_to IS NULL
      OR t.effective_to >= DATE '2026-11-05'
  )
  AND t.tariff_percent > 10
ORDER BY t.tariff_percent DESC, g.goods_name;

-- Q3: Summarize active tariff records by importing country.
SELECT
    c.country_name AS importing_country,
    COUNT(*) AS tariff_record_count,
    ROUND(AVG(t.tariff_percent), 2) AS average_tariff_percent,
    MIN(t.tariff_percent) AS minimum_tariff_percent,
    MAX(t.tariff_percent) AS maximum_tariff_percent
FROM eac.tariff_rates AS t
JOIN eac.countries AS c
    ON c.country_id = t.destination_country_id
WHERE t.effective_from <= DATE '2026-11-05'
  AND (
      t.effective_to IS NULL
      OR t.effective_to >= DATE '2026-11-05'
  )
GROUP BY c.country_id, c.country_name
ORDER BY average_tariff_percent DESC, c.country_name;

-- Q4: Importing countries with an average active tariff above 10%.
SELECT
    c.country_name AS importing_country,
    ROUND(AVG(t.tariff_percent), 2) AS average_tariff_percent
FROM eac.tariff_rates AS t
JOIN eac.countries AS c
    ON c.country_id = t.destination_country_id
WHERE t.effective_from <= DATE '2026-11-05'
  AND (
      t.effective_to IS NULL
      OR t.effective_to >= DATE '2026-11-05'
  )
GROUP BY c.country_id, c.country_name
HAVING AVG(t.tariff_percent) > 10
ORDER BY average_tariff_percent DESC, c.country_name;
