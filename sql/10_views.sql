BEGIN;

-- View 1: All tariff records with readable names.
CREATE VIEW eac.v_tariff_details AS
SELECT
    t.tariff_id,
    g.goods_code,
    g.goods_name,
    category.category_name,
    origin.country_name AS origin_country,
    destination.country_name AS destination_country,
    t.tariff_percent,
    t.effective_from,
    t.effective_to,
    t.notes
FROM eac.tariff_rates AS t
JOIN eac.goods AS g
    ON g.goods_id = t.goods_id
JOIN eac.goods_categories AS category
    ON category.category_id = g.category_id
JOIN eac.countries AS origin
    ON origin.country_id = t.origin_country_id
JOIN eac.countries AS destination
    ON destination.country_id = t.destination_country_id;

-- View 2: Tariffs active on the database's current date.
CREATE VIEW eac.v_active_tariffs AS
SELECT
    tariff_id,
    goods_code,
    goods_name,
    category_name,
    origin_country,
    destination_country,
    tariff_percent,
    effective_from,
    effective_to,
    notes
FROM eac.v_tariff_details
WHERE effective_from <= CURRENT_DATE
  AND (
      effective_to IS NULL
      OR effective_to >= CURRENT_DATE
  );

COMMIT;

-- Verify both views.
SELECT
    CURRENT_DATE AS database_today,
    (SELECT COUNT(*) FROM eac.v_tariff_details)
        AS total_tariff_records,
    (SELECT COUNT(*) FROM eac.v_active_tariffs)
        AS active_tariff_records;

		-- Read the active tariffs without repeating the joins.
SELECT
    goods_name,
    origin_country,
    destination_country,
    tariff_percent
FROM eac.v_active_tariffs
ORDER BY tariff_percent DESC, tariff_id;