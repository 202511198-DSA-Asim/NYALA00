BEGIN;

CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TABLE eac.tariff_rates (
    tariff_id INTEGER GENERATED ALWAYS AS IDENTITY,
    goods_id INTEGER NOT NULL,
    origin_country_id INTEGER NOT NULL,
    destination_country_id INTEGER NOT NULL,
    tariff_percent NUMERIC(7, 3) NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE,
    notes TEXT,

    CONSTRAINT pk_tariff_rates
        PRIMARY KEY (tariff_id),

    CONSTRAINT fk_tariff_goods
        FOREIGN KEY (goods_id)
        REFERENCES eac.goods (goods_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_tariff_origin
        FOREIGN KEY (origin_country_id)
        REFERENCES eac.countries (country_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_tariff_destination
        FOREIGN KEY (destination_country_id)
        REFERENCES eac.countries (country_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_tariff_percent
        CHECK (
            tariff_percent >= 0
            AND tariff_percent <> 'NaN'::NUMERIC
        ),

    CONSTRAINT chk_tariff_different_countries
        CHECK (origin_country_id <> destination_country_id),

    CONSTRAINT chk_tariff_dates
        CHECK (
            isfinite(effective_from)
            AND (
                effective_to IS NULL
                OR (
                    isfinite(effective_to)
                    AND effective_to >= effective_from
                )
            )
        ),

    CONSTRAINT ex_tariff_no_overlap
        EXCLUDE USING gist (
            goods_id WITH =,
            origin_country_id WITH =,
            destination_country_id WITH =,
            daterange(effective_from, effective_to, '[]') WITH &&
        )
);

COMMIT;

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'eac'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;