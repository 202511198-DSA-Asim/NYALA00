-- Update statistics before comparing execution plans.
ANALYZE eac.tariff_rates;

-- BEFORE: tariffs for Uganda on the reference date.
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    tariff_id,
    goods_id,
    tariff_percent
FROM eac.tariff_rates
WHERE destination_country_id = (
    SELECT country_id
    FROM eac.countries
    WHERE iso_code = 'UG'
)
AND effective_from <= DATE '2026-11-05'
AND (
    effective_to IS NULL
    OR effective_to >= DATE '2026-11-05'
);

-- Support filtering by importing country and start date.
CREATE INDEX idx_tariff_destination_start
ON eac.tariff_rates (
    destination_country_id,
    effective_from
);

ANALYZE eac.tariff_rates;

-- AFTER: repeat the same query for a fair comparison.
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    tariff_id,
    goods_id,
    tariff_percent
FROM eac.tariff_rates
WHERE destination_country_id = (
    SELECT country_id
    FROM eac.countries
    WHERE iso_code = 'UG'
)
AND effective_from <= DATE '2026-11-05'
AND (
    effective_to IS NULL
    OR effective_to >= DATE '2026-11-05'
);

SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'eac'
  AND tablename = 'tariff_rates'
ORDER BY indexname;