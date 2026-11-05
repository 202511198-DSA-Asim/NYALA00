# Review Notes — 2026-11-05

## Changes

- Added the missing semicolon after Q1 in `sql/08_queries.sql`. The original file fails PostgreSQL parsing at the next SELECT; all four corrected queries parse.
- Renamed `docs/test_results.md.txt` to `docs/test_results.md`, repairing the README link.
- Added the two documented but missing integrity tests to `tests/14_constraint_tests.sql`: nonexistent goods category and agreement end before start. Both use temporary updates and separate rollbacks. They were subsequently executed by the user; the follow-up screenshots show both expected constraint rejections.
- Added reviewed SVG and PNG ERDs with six visible foreign-key connections. Preserved the original pgAdmin source and original screenshot. The source metadata matches the SQL table definitions.
- Rewrote evidence documentation to distinguish static calculations, supplied screenshots, and unverified expected-error tests. Recorded both EXPLAIN plans without claiming an index-caused speed improvement.
- Clarified existing-database use, one-time setup, manual expected-error testing, and identity sequence behavior.
- In the approved follow-up, organized the README into the 16 requested sections and added the eight names from the leader-supplied roster. The approved task allocation records assigned responsibilities; completion and original authorship are not inferred. The presentation link remains pending; security and integrity execution evidence was supplied in the subsequent follow-up.
- Removed the empty `KOSOOM.MD` placeholder from the reviewed repository tree at the user's request. The original Git commit remains available in history.

## Validation performed

Validation used `libpg-query` with PostgreSQL parser version `180004` (syntax parsing only; this is not the database server version).

| Check | Result |
|---|---|
| SQL syntax | All 14 SQL files parsed successfully: 96 statements. |
| Regression check | Original `08_queries.sql` rejected; corrected version accepted. |
| ERD metadata | Six tables, 26 columns, data types and modifiers, nullability, identity settings, primary/unique keys and six foreign keys match the SQL. |
| Sample table counts | Countries 4; categories 4; goods 8; agreements 3; memberships 8; tariffs 12. |
| Tariff date calculation | On 2026-11-05: 10 active, 1 expired, 1 future. |
| Active mean | 10.30%; Uganda 19.17%; Tanzania 11.25%. |
| Sample tariff integrity | Nonnegative values, different origin/destination, valid date order, and no overlapping periods on the same goods/route. |
| Documentation | Relative Markdown links checked; no `.md.txt` files in the final tree. |
| Original evidence | Supplied screenshots and `.pgerd` preserved unchanged. |

The original `NYALA00.rar` is retained unchanged. The reviewer did not connect to or modify the existing `eac_trade_tariffs` database. No new database was created. In the subsequent follow-up, the user manually ran tests 13–14 and supplied ten original screenshots proving the eight tested authorization/integrity behaviors and two cleanup results. These images are copied unchanged under descriptive names. This does not establish a fresh full installation or cover every constraint; Q1/HAVING runtime evidence remains outstanding. Results and evidence links are recorded in [test_results.md](test_results.md).

## Publication target

Target: [YEAR-2-DATA-SCIENCE-SQL-COURSE/NYALA00](https://github.com/YEAR-2-DATA-SCIENCE-SQL-COURSE/NYALA00), branch `main`.

The remote was inspected at commit `8f1e1e2c2e48ea6da4d5286b9bacbc32c93e5b99`; it contained only the empty `KOSOOM.MD` placeholder. No existing project implementation was overwritten.

The reviewed project and placeholder deletion are packaged as one repository update. Publication history is available from the target repository's commits. Validation limits above apply regardless of publication status.
