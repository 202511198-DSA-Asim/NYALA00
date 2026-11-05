BEGIN;

UPDATE eac.tariff_rates
SET tariff_percent = -5
WHERE tariff_id = (
    SELECT MIN(tariff_id)
    FROM eac.tariff_rates
);
ROLLBACK;

BEGIN;

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
    goods_id,
    origin_country_id,
    destination_country_id,
    tariff_percent,
    effective_from,
    effective_to,
    'Temporary overlap test'
FROM eac.tariff_rates
ORDER BY tariff_id
LIMIT 1;
ROLLBACK;

BEGIN;

UPDATE eac.goods
SET category_id = -1
WHERE goods_id = (
    SELECT MIN(goods_id)
    FROM eac.goods
);
ROLLBACK;

BEGIN;

UPDATE eac.trade_agreements
SET end_date = start_date - 1
WHERE agreement_id = (
    SELECT MIN(agreement_id)
    FROM eac.trade_agreements
);
ROLLBACK;

SELECT
    COUNT(*) AS tariff_count,
    COUNT(*) FILTER (
        WHERE tariff_percent < 0
    ) AS negative_tariffs,
    COUNT(*) FILTER (
        WHERE notes = 'Temporary overlap test'
    ) AS overlap_test_records
FROM eac.tariff_rates;
