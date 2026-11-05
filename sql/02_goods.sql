BEGIN;

CREATE TABLE eac.goods (
    goods_id INTEGER GENERATED ALWAYS AS IDENTITY,
    goods_name VARCHAR(150) NOT NULL,
    goods_code VARCHAR(30) NOT NULL,
    category_id INTEGER NOT NULL,
    description TEXT,

    CONSTRAINT pk_goods
        PRIMARY KEY (goods_id),

    CONSTRAINT uq_goods_code
        UNIQUE (goods_code),

    CONSTRAINT chk_goods_name
        CHECK (btrim(goods_name) <> ''),

    CONSTRAINT chk_goods_code
        CHECK (btrim(goods_code) <> ''),

    CONSTRAINT fk_goods_category
        FOREIGN KEY (category_id)
        REFERENCES eac.goods_categories (category_id)
        ON DELETE RESTRICT
);

COMMIT;

SELECT
    column_name,
    data_type,
    is_nullable,
    is_identity
FROM information_schema.columns
WHERE table_schema = 'eac'
  AND table_name = 'goods'
ORDER BY ordinal_position;