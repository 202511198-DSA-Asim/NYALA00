# NYALA 00 — East African Community Trade Tariffs

## Project Overview

This academic project implements a PostgreSQL database for managing countries, goods, trade agreements, and percentage-based trade tariffs.

The database supports historical tariff records, reporting queries, views, indexing, and role-based access control.

## Project Information

- **Course:** SQL Database Systems
- **Group:** NYALA 00
- **Category:** Trade
- **Database system:** PostgreSQL
- **Development interface:** pgAdmin 4
- **Database name:** `eac_trade_tariffs`
- **Schema:** `eac`
- **GitHub username:** `mbarkdlwd-blip`

The finalized group member list and individual contributions will be added before submission.

## Scope and Data Limitations

This project uses a small educational dataset.

- The four countries are a sample, not a complete list of East African Community members.
- Goods codes are internal project identifiers, not official customs classification codes.
- All agreement records beginning with `DEMO` are fictional.
- All tariff percentages are fictional and must not be treated as official rates.
- Agreement membership does not automatically change tariff rates.
- The model stores one tariff rate per goods item, origin country, destination country, and date.
- Tariffs are percentage-based; fixed charges and other customs procedures are outside the current scope.
- Shipment records, trade volumes, and customs revenue are not included.
- Country-specific agreement joining and withdrawal dates are not tracked.

## Database Tables

| Table | Purpose |
|---|---|
| `countries` | Country names and two-letter codes |
| `goods_categories` | Educational goods classifications |
| `goods` | Goods, internal codes, and category references |
| `trade_agreements` | Agreement names, dates, and descriptions |
| `agreement_countries` | Links agreements to participating countries |
| `tariff_rates` | Tariff percentages, trade directions, and validity periods |

## Relationships

- One category can contain many goods.
- One goods item can have many tariff records.
- Each tariff references an origin country and a destination country.
- Countries and agreements have a many-to-many relationship through `agreement_countries`.
- The composite primary key in `agreement_countries` prevents duplicate membership records.

The [reviewed ERD](diagrams/NYALA_00_ERD.svg), its [PNG export](diagrams/NYALA_00_ERD.png), and the original pgAdmin source are provided in the `diagrams` folder. The original screenshot is preserved in `docs/screenshots/`; its relationship lines are not visible. The reviewed diagram shows all six foreign-key relationships.

## Integrity Rules

The implementation includes:

- Primary keys and foreign keys.
- Unique country names, country codes, goods codes, category names, and agreement names.
- Required fields enforced with `NOT NULL`.
- Checks against blank names and invalid country-code formats.
- Nonnegative tariff percentages, excluding `NaN`.
- Different origin and destination countries.
- Valid start and end dates.
- Restricted deletion of referenced records.
- An exclusion constraint preventing overlapping tariff periods for the same goods item and trade direction.

Tariff start and end dates are inclusive. A null end date means that no end date has been specified.

The overlap constraint uses the PostgreSQL `btree_gist` extension.

## Sample Dataset

| Table | Records |
|---|---:|
| `countries` | 4 |
| `goods_categories` | 4 |
| `goods` | 8 |
| `trade_agreements` | 3 |
| `agreement_countries` | 8 |
| `tariff_rates` | 12 |

On the fixed reference date `2026-11-05`, the tariff dataset contains:

- 10 active records.
- 1 expired record.
- 1 future record.

## SQL Files and Execution Order

The existing project database is `eac_trade_tariffs`. Connect to it through the pgAdmin Query Tool. This review does not require creating or rebuilding a database.

The setup order below documents the original implementation for a separately authorized installation into an empty database. Do not rerun setup or sample-data scripts on the working database. The corrected `08_queries.sql` and `09_ctes.sql` contain read-only analytical queries.

Run the setup and sample-data files in this order:

1. `01_initial_tables.sql`
2. `02_goods.sql`
3. `03_trade_agreements.sql`
4. `04_tariff_rates.sql`
5. `05_sample_goods_and_countries.sql`
6. `06_sample_agreements.sql`
7. `07_sample_tariffs.sql`

Then run the reporting and security files:

8. `08_queries.sql`
9. `09_ctes.sql`
10. `10_views.sql`
11. `11_indexes.sql`
12. `12_security.sql`

Finally, execute the tests section by section:

13. `13_security_tests.sql`
14. `14_constraint_tests.sql`

### Execution Notes

- The creation and insertion scripts are intended for an initially empty project database. They are not designed for repeated execution against an already populated database.
- Run the indexing comparison sections individually to capture the before and after execution plans.
- Security setup requires an administrator with permission to create roles and grant privileges.
- PostgreSQL roles are shared across databases on the same server. When rebuilding on the same server, the existing `nyala00_reader` and `nyala00_editor` roles must be accounted for before rerunning role creation.
- Some tests intentionally produce errors. Run each test separately and execute its `ROLLBACK` afterward.
- Expected-error test scripts should not be executed as one uninterrupted batch.
- Tests require the sample data and an administrator able to `SET ROLE`. In test 14, category `-1` must not exist. Capture each expected error before running its `ROLLBACK`; see [test instructions and evidence](docs/test_results.md).
- The overlap test attempts an identity-generating insert. PostgreSQL sequence values consumed by an attempted insert are not restored by rollback, even though its row changes are rolled back.

## Queries and CTEs

The examples demonstrate:

- Filtering and ordering.
- Joining related tables.
- Grouping and aggregate functions.
- Filtering groups with `HAVING`.
- Common Table Expressions using `WITH`.

The CTE example calculates the average active tariff on `2026-11-05` and returns tariff records above that average.

For the sample data, the average is **10.30%**.

This is an unweighted average of tariff records, not a trade-weighted economic indicator.

## Views

### `eac.v_tariff_details`

Combines tariff records with goods, category, and country names.

### `eac.v_active_tariffs`

Returns tariffs active on PostgreSQL's `CURRENT_DATE`.

Its results can change as the date changes, even when the stored records remain unchanged.

## Indexing

The index `idx_tariff_destination_start` covers:

- `destination_country_id`
- `effective_from`

It supports queries filtering by importing country and start date.

The project includes `EXPLAIN (ANALYZE, BUFFERS)` statements for inspecting execution plans before and after index creation.

With only 12 tariff records, PostgreSQL may choose a sequential scan. Index creation alone does not demonstrate a performance improvement.

## Database Security

Two restricted, non-login roles are defined:

| Role | Permissions |
|---|---|
| `nyala00_reader` | Read the two reporting views |
| `nyala00_editor` | Read, insert, and update the six project tables; read the reporting views; use identity sequences |

Neither role is granted permission to delete project records or create tables in the `eac` schema.

General access through `PUBLIC` is revoked on the project schema, tables, views, and sequences.

Security tests use `SET LOCAL ROLE` within a transaction. `ROLLBACK` restores the previous role and reverses temporary data changes.

These tests demonstrate database authorization. They do not demonstrate password authentication or separate user login sessions.

Permissions for future objects must be reviewed and granted explicitly.

## Validation

The test scripts cover:

- Reader access to reporting views.
- Denial of direct table access for the reader.
- Editor updates followed by rollback.
- Denial of deletion for the editor.
- Rejection of negative tariff percentages.
- Rejection of overlapping tariff periods.
- Rejection of invalid category references.
- Rejection of agreement end dates preceding start dates.

After the temporary tests, the tariff table should retain 12 records and no temporary test changes.

Screenshots, observed results, static checks, and evidence gaps are recorded in [test results](docs/test_results.md). The two added integrity tests have not been executed against the working database.

## Submission

SQL scripts, diagrams, and Markdown documentation will be submitted through the class's central GitHub repository coordinated by the Class Representative.

A presentation is outside this review and is not included in this package.

## Technical Reference

- [PostgreSQL range types and exclusion constraints](https://www.postgresql.org/docs/18/rangetypes.html#RANGETYPES-CONSTRAINT)
- [PostgreSQL btree_gist extension](https://www.postgresql.org/docs/18/btree-gist.html)
- [pgAdmin ERD Tool](https://www.pgadmin.org/docs/pgadmin4/latest/erd_tool.html)

## Repository Structure

```text
NYALA00/
├── README.md
├── sql/
│   └── SQL scripts 01–12
├── tests/
│   ├── 13_security_tests.sql
│   └── 14_constraint_tests.sql
├── docs/
│   ├── database_design.md
│   ├── test_results.md
│   ├── review_notes.md
│   └── screenshots/
└── diagrams/
    └── ERD sources (.pgerd, .svg) and reviewed PNG
```

The execution order listed above remains unchanged. Scripts 01–12 are located in `sql/`, and scripts 13–14 are located in `tests/`.

### Supporting Documentation
- [Implementation and test results](docs/test_results.md)
- [Database design and data dictionary](docs/database_design.md)
- [Implementation screenshots](docs/screenshots/)
- [Database diagrams](diagrams/)
- [Security and constraint test scripts](tests/)
- [Review changes and validation limits](docs/review_notes.md)
