BEGIN;

CREATE TABLE eac.trade_agreements (
    agreement_id INTEGER GENERATED ALWAYS AS IDENTITY,
    agreement_name VARCHAR(200) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    description TEXT,

    CONSTRAINT pk_trade_agreements
        PRIMARY KEY (agreement_id),

    CONSTRAINT uq_trade_agreements_name
        UNIQUE (agreement_name),

    CONSTRAINT chk_trade_agreements_name
        CHECK (btrim(agreement_name) <> ''),

    CONSTRAINT chk_trade_agreements_dates
        CHECK (
            end_date IS NULL
            OR end_date >= start_date
        )
);

-- Agreement countries: الدول المشاركة في الاتفاقيات
CREATE TABLE eac.agreement_countries (
    agreement_id INTEGER NOT NULL,
    country_id INTEGER NOT NULL,

    CONSTRAINT pk_agreement_countries
        PRIMARY KEY (agreement_id, country_id),

    CONSTRAINT fk_agreement_countries_agreement
        FOREIGN KEY (agreement_id)
        REFERENCES eac.trade_agreements (agreement_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_agreement_countries_country
        FOREIGN KEY (country_id)
        REFERENCES eac.countries (country_id)
        ON DELETE RESTRICT
);

COMMIT;

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'eac'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;