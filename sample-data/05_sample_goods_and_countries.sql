BEGIN;

-- 1. Sample countries
INSERT INTO eac.countries (country_name, iso_code)
VALUES
    ('Kenya', 'KE'),
    ('Uganda', 'UG'),
    ('Tanzania', 'TZ'),
    ('Rwanda', 'RW');

-- 2. Educational goods categories
INSERT INTO eac.goods_categories (category_name, description)
VALUES
    ('Agricultural Products', 'Primary agricultural goods'),
    ('Processed Foods', 'Processed food products'),
    ('Textiles', 'Fabrics and clothing'),
    ('Construction Materials', 'Materials used in construction');

-- 3. Sample goods
-- Look up category IDs by name rather than assuming their numbers.
INSERT INTO eac.goods (
    goods_name,
    goods_code,
    category_id,
    description
)
SELECT
    sample.goods_name,
    sample.goods_code,
    (
        SELECT category_id
        FROM eac.goods_categories
        WHERE category_name = sample.category_name
    ),
    sample.description
FROM (
    VALUES
        (
            'Coffee Beans', 'AGR-001',
            'Agricultural Products', 'Sample unroasted coffee beans'
        ),
        (
            'Tea Leaves', 'AGR-002',
            'Agricultural Products', 'Sample tea leaves'
        ),
        (
            'Wheat Flour', 'FOOD-001',
            'Processed Foods', 'Sample wheat flour'
        ),
        (
            'Cooking Oil', 'FOOD-002',
            'Processed Foods', 'Sample vegetable cooking oil'
        ),
        (
            'Cotton Fabric', 'TEX-001',
            'Textiles', 'Sample cotton fabric'
        ),
        (
            'Cotton Shirts', 'TEX-002',
            'Textiles', 'Sample cotton shirts'
        ),
        (
            'Cement', 'CON-001',
            'Construction Materials', 'Sample construction cement'
        ),
        (
            'Steel Bars', 'CON-002',
            'Construction Materials', 'Sample reinforcing steel bars'
        )
) AS sample (
    goods_name,
    goods_code,
    category_name,
    description
);

COMMIT;

-- Verify the number of records in each populated table
SELECT 'countries' AS table_name, COUNT(*) AS total_records
FROM eac.countries

UNION ALL

SELECT 'goods_categories', COUNT(*)
FROM eac.goods_categories

UNION ALL

SELECT 'goods', COUNT(*)
FROM eac.goods;