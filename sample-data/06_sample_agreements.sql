BEGIN;

-- Fictional agreements for educational use only.
INSERT INTO eac.trade_agreements (
    agreement_name,
    start_date,
    end_date,
    description
)
VALUES
    (
        'DEMO Regional Trade Agreement',
        DATE '2025-01-01',
        NULL,
        'Fictional educational agreement involving four countries.'
    ),
    (
        'DEMO Agricultural Cooperation',
        DATE '2026-01-01',
        DATE '2028-12-31',
        'Fictional educational agreement involving Kenya and Uganda.'
    ),
    (
        'DEMO Textile Trade Agreement',
        DATE '2024-01-01',
        DATE '2025-12-31',
        'Fictional expired agreement involving Tanzania and Rwanda.'
    );

-- Link each agreement to its participating countries.
-- Look up IDs using agreement names and country codes.
INSERT INTO eac.agreement_countries (
    agreement_id,
    country_id
)
SELECT
    (
        SELECT agreement_id
        FROM eac.trade_agreements
        WHERE agreement_name = sample.agreement_name
    ),
    (
        SELECT country_id
        FROM eac.countries
        WHERE iso_code = sample.iso_code
    )
FROM (
    VALUES
        ('DEMO Regional Trade Agreement', 'KE'),
        ('DEMO Regional Trade Agreement', 'UG'),
        ('DEMO Regional Trade Agreement', 'TZ'),
        ('DEMO Regional Trade Agreement', 'RW'),

        ('DEMO Agricultural Cooperation', 'KE'),
        ('DEMO Agricultural Cooperation', 'UG'),

        ('DEMO Textile Trade Agreement', 'TZ'),
        ('DEMO Textile Trade Agreement', 'RW')
) AS sample (agreement_name, iso_code);

COMMIT;

-- Verify agreements and their participating countries.
SELECT
    a.agreement_name,
    a.start_date,
    a.end_date,
    COUNT(ac.country_id) AS member_count,
    STRING_AGG(
        c.country_name,
        ', ' ORDER BY c.country_name
    ) AS participating_countries
FROM eac.trade_agreements AS a
LEFT JOIN eac.agreement_countries AS ac
    ON ac.agreement_id = a.agreement_id
LEFT JOIN eac.countries AS c
    ON c.country_id = ac.country_id
GROUP BY
    a.agreement_id,
    a.agreement_name,
    a.start_date,
    a.end_date
ORDER BY a.agreement_name;