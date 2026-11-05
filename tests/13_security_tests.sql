BEGIN;

SET LOCAL ROLE nyala00_reader;

SELECT current_user AS testing_as;

SELECT goods_name, tariff_percent
FROM eac.v_active_tariffs
ORDER BY tariff_percent DESC, tariff_id;

ROLLBACK;


BEGIN;

SET LOCAL ROLE nyala00_reader;

SELECT * FROM eac.tariff_rates;

ROLLBACK;

BEGIN;

SET LOCAL ROLE nyala00_editor;

UPDATE eac.tariff_rates
SET notes = 'Temporary security test'
WHERE tariff_id = (
    SELECT MIN(tariff_id)
    FROM eac.tariff_rates
)
RETURNING tariff_id, notes;

ROLLBACK;


BEGIN;

SET LOCAL ROLE nyala00_editor;

DELETE FROM eac.tariff_rates
WHERE FALSE;
ROLLBACK;

SELECT
    current_user AS connected_user,
    COUNT(*) AS tariff_count,
    COUNT(*) FILTER (
        WHERE notes = 'Temporary security test'
    ) AS remaining_test_changes
FROM eac.tariff_rates;