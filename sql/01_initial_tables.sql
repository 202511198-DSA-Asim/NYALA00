BEGIN;

CREATE SCHEMA eac;

CREATE TABLE eac.countries (
    country_id INTEGER GENERATED ALWAYS AS IDENTITY,
    country_name VARCHAR(100) NOT NULL,
    iso_code VARCHAR(2) NOT NULL,

    CONSTRAINT pk_countries
        PRIMARY KEY (country_id),

    CONSTRAINT uq_countries_name
        UNIQUE (country_name),

    CONSTRAINT uq_countries_iso
        UNIQUE (iso_code),

    CONSTRAINT chk_countries_name
        CHECK (btrim(country_name) <> ''),

    CONSTRAINT chk_countries_iso
        CHECK (iso_code ~ '^[A-Z]{2}$')
);

-- Goods categories: تصنيفات السلع
CREATE TABLE eac.goods_categories (
    category_id INTEGER GENERATED ALWAYS AS IDENTITY,
    category_name VARCHAR(100) NOT NULL,
    description TEXT,

    CONSTRAINT pk_goods_categories
        PRIMARY KEY (category_id),

    CONSTRAINT uq_goods_categories_name
        UNIQUE (category_name),

    CONSTRAINT chk_goods_categories_name
        CHECK (btrim(category_name) <> '')
);

COMMIT;

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'eac'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;