BEGIN;

-- 1. Create restricted roles for this project..
CREATE ROLE nyala00_reader
    NOLOGIN
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE
    NOREPLICATION
    NOBYPASSRLS;

CREATE ROLE nyala00_editor
    NOLOGIN
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE
    NOREPLICATION
    NOBYPASSRLS;

-- 2. Remove general access to project objects..
-- PUBLIC means every PostgreSQL role.
REVOKE ALL PRIVILEGES ON SCHEMA eac FROM PUBLIC;

REVOKE ALL PRIVILEGES
ON ALL TABLES IN SCHEMA eac
FROM PUBLIC;

REVOKE ALL PRIVILEGES
ON ALL SEQUENCES IN SCHEMA eac
FROM PUBLIC;

-- 3. Allow both roles to access the project schema.
-- USAGE does not allow creating tables.
GRANT USAGE ON SCHEMA eac
TO nyala00_reader, nyala00_editor;

-- 4. Reader: access only the two reporting views.
GRANT SELECT
ON eac.v_tariff_details, eac.v_active_tariffs
TO nyala00_reader;

-- 5. Editor: read, insert and update the six tables.
GRANT SELECT, INSERT, UPDATE
ON
    eac.countries,
    eac.goods_categories,
    eac.goods,
    eac.trade_agreements,
    eac.agreement_countries,
    eac.tariff_rates
TO nyala00_editor;

-- Allow use of automatically generated IDs.
GRANT USAGE
ON ALL SEQUENCES IN SCHEMA eac
TO nyala00_editor;

-- Editor can also read the reporting views.
GRANT SELECT
ON eac.v_tariff_details, eac.v_active_tariffs
TO nyala00_editor;

COMMIT;

-- 6. Check effective permissions.
SELECT
    role_name,
    has_schema_privilege(
        role_name, 'eac', 'USAGE'
    ) AS can_use_schema,
    has_schema_privilege(
        role_name, 'eac', 'CREATE'
    ) AS can_create_tables,
    has_table_privilege(
        role_name, 'eac.v_active_tariffs', 'SELECT'
    ) AS can_read_view,
    has_table_privilege(
        role_name, 'eac.tariff_rates', 'SELECT'
    ) AS can_read_tariff_table,
    has_table_privilege(
        role_name, 'eac.tariff_rates', 'INSERT'
    ) AS can_insert_tariffs,
    has_table_privilege(
        role_name, 'eac.tariff_rates', 'UPDATE'
    ) AS can_update_tariffs,
    has_table_privilege(
        role_name, 'eac.tariff_rates', 'DELETE'
    ) AS can_delete_tariffs
FROM (
    VALUES
        ('nyala00_reader'::TEXT),
        ('nyala00_editor'::TEXT)
) AS roles(role_name);
