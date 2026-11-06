BEGIN;

-- Fictional tariff rates for educational use only.
INSERT INTO eac.tariff_rates (
    goods_id,
    origin_country_id,
    destination_country_id,
    tariff_percent,
    effective_from,
    effective_to,
    notes
)
SELECT
    (
        SELECT goods_id
        FROM eac.goods
        WHERE goods_code = sample.goods_code
    ),
    (
        SELECT country_id
        FROM eac.countries
        WHERE iso_code = sample.origin_code
    ),
    (
        SELECT country_id
        FROM eac.countries
        WHERE iso_code = sample.destination_code
    ),
    sample.tariff_percent,
    sample.effective_from,
    sample.effective_to,
    'DEMO ONLY: fictional tariff, not an official rate.'
FROM (
    VALUES
        -- Coffee: consecutive periods with no overlap
        ('AGR-001', 'UG', 'KE', 10.000,
         DATE '2025-01-01', DATE '2025-12-31'),

        ('AGR-001', 'UG', 'KE', 5.000,
         DATE '2026-01-01', NULL::DATE),

        -- Tea
        ('AGR-002', 'KE', 'RW', 0.000,
         DATE '2026-01-01', NULL::DATE),

        -- Wheat flour
        ('FOOD-001', 'TZ', 'UG', 12.500,
         DATE '2026-01-01', NULL::DATE),

        -- Cooking oil
        ('FOOD-002', 'KE', 'TZ', 15.000,
         DATE '2026-01-01', NULL::DATE),

        -- Cotton fabric
        ('TEX-001', 'TZ', 'RW', 8.000,
         DATE '2026-01-01', NULL::DATE),

        -- Cotton shirts
        ('TEX-002', 'KE', 'UG', 20.000,
         DATE '2026-01-01', NULL::DATE),

        -- Cement
        ('CON-001', 'TZ', 'RW', 10.000,
         DATE '2026-01-01', NULL::DATE),

        -- Steel bars: current and future periods
        ('CON-002', 'KE', 'UG', 25.000,
         DATE '2026-01-01', DATE '2026-12-31'),

        ('CON-002', 'KE', 'UG', 22.000,
         DATE '2027-01-01', NULL::DATE),

        -- Same goods, different trading routes
        ('AGR-001', 'RW', 'TZ', 7.500,
         DATE '2026-01-01', NULL::DATE),

        ('FOOD-001', 'UG', 'KE', 0.000,
         DATE '2026-01-01', NULL::DATE)
) AS sample (
    goods_code,
    origin_code,
    destination_code,
    tariff_percent,
    effective_from,
    effective_to
);

COMMIT;

-- Display tariffs with readable names.
-- Fixed reference date keeps the demonstration reproducible.
SELECT
    g.goods_name,
    origin.country_name AS origin_country,
    destination.country_name AS destination_country,
    t.tariff_percent,
    t.effective_from,
    t.effective_to,
    CASE
        WHEN t.effective_from > DATE '2026-11-05'
            THEN 'Future'
        WHEN t.effective_to < DATE '2026-11-05'
            THEN 'Expired'
        ELSE 'Active'
    END AS status_on_reference_date
FROM eac.tariff_rates AS t
JOIN eac.goods AS g
    ON g.goods_id = t.goods_id
JOIN eac.countries AS origin
    ON origin.country_id = t.origin_country_id
JOIN eac.countries AS destination
    ON destination.country_id = t.destination_country_id
ORDER BY
    g.goods_name,
    origin.country_name,
    destination.country_name,
    t.effective_from;