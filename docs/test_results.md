# Implementation and Test Results

## Environment and review scope

- Project: NYALA 00 — East African Community Trade Tariffs.
- Author-reported environment: PostgreSQL 18.6 with pgAdmin 4; screenshots identify PostgreSQL 18 Local but do not independently establish the minor version.
- Database: `eac_trade_tariffs`; schema: `eac`.
- Analytical reference date: `2026-11-05`.
- Review: saved SQL, sample data, ERD, and supplied screenshots. No connection to or changes in the working database were made. No new database was created and no full rebuild was performed.

## Evidence reviewed

| Check | Evidence and conclusion |
|---|---|
| Tables and data model | Saved SQL defines six tables; the pgAdmin ERD source has matching columns, keys and six foreign keys. |
| Sample data | Static inspection gives 4 countries, 4 categories, 8 goods, 3 agreements, 8 memberships, and 12 tariffs. |
| Tariff status | Static calculation for 2026-11-05: 10 active, 1 expired, 1 future; active average 10.30%. |
| CTE output | [09_ctes.png](screenshots/09_ctes.png) displays Steel Bars 25%, Cotton Shirts 20%, Cooking Oil 15%, Wheat Flour 12.5%, and overall average 10.30%. |
| HAVING output | Derived from saved data: Uganda 19.17%, Tanzania 11.25%. No dedicated `08_queries` screenshot is supplied. The saved Q1 lacked a semicolon; this is corrected. |
| Views | [10_views1.png](screenshots/10_views1.png) and [10_views2.png](screenshots/10_views2.png) record the historical results. `v_active_tariffs` uses `CURRENT_DATE`, so later results may differ. |
| Index | [11_indexes4.png](screenshots/11_indexes4.png) lists the primary-key index, the GiST exclusion index and `idx_tariff_destination_start`. |
| Permissions | [12_security.png](screenshots/12_security.png) shows reader view SELECT true, base-table SELECT/INSERT/UPDATE/DELETE false; editor table SELECT/INSERT/UPDATE true and DELETE false; schema CREATE false for both. These are permission-function results, not captured rejected statements. |
| Security cleanup | [13_security_tests.png](screenshots/13_security_tests.png): current user `postgres`, 12 tariff rows, 0 temporary note changes. |
| Constraint cleanup | [14_constraint_tests.png](screenshots/14_constraint_tests.png): 12 tariff rows, 0 negative tariffs, 0 overlap-test records. This does not prove each expected error occurred. |

## Expected-error tests and evidence gaps

Run each transaction separately as an administrator permitted to use the test roles. Select from `BEGIN` through the operation, capture its Messages output, and then execute the following `ROLLBACK` separately, even after an error. Do not run the entire file as a batch. A failed transaction prevents subsequent work until rolled back.

| Test | Expected SQLSTATE / constraint | Evidence status |
|---|---|---|
| Reader selects base tariff table | `42501` insufficient privilege | Script 13 present; direct error screenshot not supplied. |
| Editor attempts DELETE (with `WHERE FALSE`) | `42501` insufficient privilege | Script 13 present; direct error screenshot not supplied. |
| Negative tariff percentage | `23514` / `chk_tariff_percent` | Script 14 present; direct error screenshot not supplied. |
| Duplicate overlapping tariff period | `23P01` / `ex_tariff_no_overlap` | Script 14 present; direct error screenshot not supplied. |
| Goods category changed to nonexistent `-1` | `23503` / `fk_goods_category` | Added to script 14 during review; not executed. Requires category `-1` to be absent, as in the supplied sample. |
| Agreement end date before start date | `23514` / `chk_trade_agreements_dates` | Added to script 14 during review; not executed. |

Script 13 also includes a successful reader-view SELECT and an editor UPDATE followed by rollback. The cleanup screenshot alone does not establish that those intermediate steps ran successfully. Capture those results separately if execution evidence is required for submission.

All update tests require nonempty sample tables. The overlap insert can consume an identity sequence value even when the row is rejected or rolled back. Sequence gaps are normal and must not be repaired with a reset. See [PostgreSQL sequence behavior](https://www.postgresql.org/docs/18/functions-sequence.html).

## Indexing evidence

The two saved plans both use **Seq Scan on tariff_rates**. Both return 3 rows, remove 9 by filter, report 3 shared buffer hits at the top node, and use `uq_countries_iso` for the Uganda lookup.

| Metric | Before: [11_indexes1.png](screenshots/11_indexes1.png) | After: [11_indexes3.png](screenshots/11_indexes3.png) |
|---|---:|---:|
| Planning time | 5.652 ms | 1.871 ms |
| Execution time | 0.064 ms | 0.053 ms |
| Planning buffers | 96 shared hits | 42 shared hits, 1 read |
| Tariff scan | Sequential | Sequential |

These are single observations on 12 records. They do not establish an index-induced speed improvement: the new tariff index is not used by either displayed plan, and caching and run variation affect timing. The plans and index list establish that the comparison was recorded and the index exists.

Do not drop or recreate an existing index to reproduce a 'before' plan on the working database. The creation section of script 11 is a one-time setup step.

## Static validation

The review checks syntax for SQL files 01–14 without executing them, checks relative Markdown links, compares ERD metadata to the SQL table definitions, and independently calculates sample counts, date statuses, averages, and tariff non-overlap. Details are in [review notes](review_notes.md).

Static checks do not establish runtime permissions, extension availability, transaction behavior, or successful installation. Saved screenshots predate the reviewed file changes and are preserved as original evidence.

## Files

- [SQL scripts](../sql/), [security tests](../tests/13_security_tests.sql), [constraint tests](../tests/14_constraint_tests.sql).
- [Database design](database_design.md), [reviewed diagram](../diagrams/NYALA_00_ERD.svg), [original screenshots](screenshots/).
- Follow the [README](../README.md) for setup order and the distinction between existing-database use and a separately authorized empty-database installation.
