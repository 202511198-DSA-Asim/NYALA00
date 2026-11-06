# NYALA 00 — East African Community Trade Tariffs

## 1. Project Title

**East African Community Trade Tariffs — NYALA 00**

- **Course:** SQL Database Systems
- **Group:** NYALA 00
- **Category:** Trade
- **Database system:** PostgreSQL
- **Development interface:** pgAdmin 4
- **Database name:** `eac_trade_tariffs`
- **Schema:** `eac`
- **GitHub username:** `mbarkdlwd-blip`
- **Repository:** [YEAR-2-DATA-SCIENCE-SQL-COURSE/NYALA00](https://github.com/YEAR-2-DATA-SCIENCE-SQL-COURSE/NYALA00)

## 2. Group Members

Names are transcribed from the group roster supplied by the group leader. The approved responsibilities are recorded in Section 16.

| Member name | Role |
|---|---|
| Mubarak Dawood | Leader |
| Nabeel Suliman Ahmed Idris | Member |
| Mohamed Ali MohamedTahir Ali | Member |
| Maysara Dafaallh | Member |
| Moaz Mohammed yacoub | Member |
| Almonzer Abdullah | Member |
| Asim Mohamed adam | Member |
| Mustafa Omer Mustafa | Member |

## 3. Introduction

This academic project implements a PostgreSQL database for managing countries, goods, trade agreements, and percentage-based trade tariffs.

The database supports historical tariff records, reporting queries, views, indexing, and role-based access control.

### Scope and Data Limitations

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

The prototype permits at most one tariff for a goods item, origin, destination, and date; it does not require a record for every possible route. Absence of a record does not mean a zero tariff.

## 4. Problem Statement

The project addresses a data-management problem: how can tariff records be organized so that a user can identify the recorded rate for a goods item, origin, destination, and date while retaining previous rates?

A flat list with repeated goods and country details can contain inconsistent names, invalid references, duplicate agreement memberships, and overlapping tariff periods. This relational design separates the entities and uses database constraints to maintain consistent relationships. It is an educational model, not an official customs service.

## 5. Objectives

- Model countries, categories, goods, agreements, memberships, and tariffs in six related tables.
- Enforce valid references, required fields, unique identifiers, and meaningful tariff dates and percentages.
- Preserve historical rates and prevent overlapping periods for the same goods and route.
- Demonstrate filtering, joins, aggregation, HAVING, CTEs, and reporting views.
- Inspect query plans before and after adding a supporting index without assuming a performance benefit.
- Demonstrate restricted reader/editor permissions and rollback-based integrity tests.
- Document the design, evidence, limitations, and group responsibilities for presentation.

## 6. Research and Key Concepts

The design rationale uses PostgreSQL's documented relational, range, transaction, and privilege features. Technical references are listed in Section 14.

| Concept | Application in this project |
|---|---|
| Relational design and normalization | Separate entities reduce repeated descriptive data; the normalization rationale is explained in the data dictionary. |
| Primary and foreign keys | Identify records and link tables; the membership table uses a composite primary key. |
| Integrity constraints | NOT NULL, UNIQUE, CHECK, and foreign keys constrain allowed data. |
| Historical validity | Inclusive date boundaries describe tariff periods; a null end date is open-ended. |
| Exclusion constraints | btree_gist supports equality checks alongside date-range overlap checks. |
| Analytical SQL | Joins provide readable names; aggregation, HAVING, and CTEs compare active tariffs. |
| Views and privileges | Reporting views and explicit grants separate reporting from editing. |
| Transactions | Rollback reverses temporary row changes; consumed identity sequence values are not restored. |

No real-world tariff legislation or preferential eligibility has been verified for this fictional dataset.

## 7. Technical Approach

The implementation proceeds from table definitions and integrity rules to sample data, analytical queries, views, an index comparison, and role-based security. The existing database is accessed through pgAdmin; this documentation update does not require a rebuild.

### Queries and CTEs

The examples demonstrate:

- Filtering and ordering.
- Joining related tables.
- Grouping and aggregate functions.
- Filtering groups with `HAVING`.
- Common Table Expressions using `WITH`.

The CTE example calculates the average active tariff on `2026-11-05` and returns tariff records above that average.

For the sample data, the average is **10.30%**.

This is an unweighted average of tariff records, not a trade-weighted economic indicator.

### Reporting Views

#### `eac.v_tariff_details`

Combines tariff records with goods, category, and country names.

#### `eac.v_active_tariffs`

Returns tariffs active on PostgreSQL's `CURRENT_DATE`.

Its results can change as the date changes, even when the stored records remain unchanged.

### Indexing

The index `idx_tariff_destination_start` covers:

- `destination_country_id`
- `effective_from`

It supports queries filtering by importing country and start date.

The project includes `EXPLAIN (ANALYZE, BUFFERS)` statements for inspecting execution plans before and after index creation.

With only 12 tariff records, PostgreSQL may choose a sequential scan. Index creation alone does not demonstrate a performance improvement.

### Database Security

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

## 8. Database Design and Diagrams

### Tables

| Table | Purpose |
|---|---|
| `countries` | Country names and two-letter codes |
| `goods_categories` | Educational goods classifications |
| `goods` | Goods, internal codes, and category references |
| `trade_agreements` | Agreement names, dates, and descriptions |
| `agreement_countries` | Links agreements to participating countries |
| `tariff_rates` | Tariff percentages, trade directions, and validity periods |

### Relationships

- One category can contain many goods.
- One goods item can have many tariff records.
- Each tariff references an origin country and a destination country.
- Countries and agreements have a many-to-many relationship through `agreement_countries`.
- The composite primary key in `agreement_countries` prevents duplicate membership records.

The [reviewed ERD](diagrams/NYALA_00_ERD.svg), its [PNG export](diagrams/NYALA_00_ERD.png), and the original pgAdmin source are provided in the `diagrams` folder. The original screenshot is preserved in `docs/screenshots/`; its relationship lines are not visible. The reviewed diagram shows all six foreign-key relationships.

### Integrity Rules

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

### Sample Dataset

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

See the [data dictionary and normalization rationale](docs/database_design.md) for column definitions, nullability, keys, and relationship cardinalities.

## 9. SQL Implementation

Implementation scripts: [sql/](sql/). Security and integrity tests: [tests/](tests/).

The existing project database is `eac_trade_tariffs`. Connect to it through the pgAdmin Query Tool. This review does not require creating or rebuilding a database.

The setup order below documents the original implementation for a separately authorized installation into an empty database. Do not rerun setup or sample-data scripts on the working database. The corrected [08_queries.sql](sql/08_queries.sql) and [09_ctes.sql](sql/09_ctes.sql) contain read-only analytical queries.

Run the setup and sample-data files in this order:

1. [01_initial_tables.sql](sql/01_initial_tables.sql)
2. [02_goods.sql](sql/02_goods.sql)
3. [03_trade_agreements.sql](sql/03_trade_agreements.sql)
4. [04_tariff_rates.sql](sql/04_tariff_rates.sql)
5. [05_sample_goods_and_countries.sql](sample-data/05_sample_goods_and_countries.sql)
6. [06_sample_agreements.sql](sample-data/06_sample_agreements.sql)
7. [07_sample_tariffs.sql](sample-data/07_sample_tariffs.sql)

Then run the reporting and security files:

8. [08_queries.sql](sql/08_queries.sql)
9. [09_ctes.sql](sql/09_ctes.sql)
10. [10_views.sql](sql/10_views.sql)
11. [11_indexes.sql](sql/11_indexes.sql)
12. [12_security.sql](sql/12_security.sql)

Finally, execute the tests section by section:

13. [13_security_tests.sql](tests/13_security_tests.sql)
14. [14_constraint_tests.sql](tests/14_constraint_tests.sql)

### Execution Notes

- The creation and insertion scripts are intended for an initially empty project database. They are not designed for repeated execution against an already populated database.
- Run the indexing comparison sections individually to capture the before and after execution plans.
- Security setup requires an administrator with permission to create roles and grant privileges.
- PostgreSQL roles are shared across databases on the same server. When rebuilding on the same server, the existing `nyala00_reader` and `nyala00_editor` roles must be accounted for before rerunning role creation.
- Some tests intentionally produce errors. Run each test separately and execute its `ROLLBACK` afterward.
- Expected-error test scripts should not be executed as one uninterrupted batch.
- Tests require the sample data and an administrator able to `SET ROLE`. In test 14, category `-1` must not exist. Capture each expected error before running its `ROLLBACK`; see [test instructions and evidence](docs/test_results.md).
- The overlap test attempts an identity-generating insert. PostgreSQL sequence values consumed by an attempted insert are not restored by rollback, even though its row changes are rolled back.

Do not drop or recreate the existing index merely to obtain another 'before' plan. Use the saved plan evidence for the current project.

## 10. Practical Demonstration and Results

| Demonstration | Result and evidence basis |
|---|---|
| Data model | Six tables; counts shown in Section 8 and checked against saved SQL and ERD metadata |
| Tariff status on 2026-11-05 | 10 active, 1 expired, 1 future; saved data and tariff screenshot |
| Overall active average | 10.30%, also shown in the CTE screenshot |
| Above-average tariffs | Steel Bars 25%, Cotton Shirts 20%, Cooking Oil 15%, Wheat Flour 12.5%; CTE screenshot |
| HAVING query | Uganda 19.17%, Tanzania 11.25%; derived from saved data, with a dedicated query screenshot still needed |
| Active-tariff view | 10 rows in the screenshot dated 2026-11-05; later CURRENT_DATE results may differ |
| Permissions | Supplied screenshot shows the intended privilege-function results for both roles |
| Cleanup | Supplied screenshots show 12 tariff rows and no remaining temporary test changes/records |

### Validation and Evidence Limits

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

Screenshots, observed results, static checks, and evidence gaps are recorded in [test results](docs/test_results.md). The user subsequently executed all security and integrity test cases on 2026-11-05; ten original screenshots document the results and final cleanup.

The review parsed 14 SQL files (96 statements), checked relative documentation links, compared ERD metadata to the schema, and independently calculated sample counts, date statuses, averages, and non-overlap. No database connection, modification, or fresh rebuild was performed during the review.

Direct screenshots now show both permission denials, the reader-view result, the editor update, and all four constraint rejections. Cleanup shows 12 tariffs and no temporary test records or notes. The corrected Q1 parses, but a fresh runtime result was not captured in this review.

See [test results](docs/test_results.md), [screenshots](docs/screenshots/), and [review notes](docs/review_notes.md) for the evidence and its limits.

## 11. Real-World Applications

With verified official data, source provenance, and additional controls, a system based on this model could support date-specific tariff lookups, comparisons of recorded rates between routes, and historical reports. Reporting views could also feed an educational dashboard for exploring goods categories and importing countries.

These are potential applications, not deployed capabilities. The prototype does not calculate shipment duties or revenue, determine preferential eligibility, or model fixed charges and other customs procedures. Its fictional data must not be used for commercial or legal decisions.

## 12. Challenges and Recommendations

| Challenge identified | Response or recommendation |
|---|---|
| Missing delimiter in saved Q1 | Corrected the semicolon; retain syntax checks when editing SQL. |
| Overlapping historical tariffs | Use the existing exclusion constraint and review inclusive date boundaries when preparing new data. |
| Broken documentation link and unclear ERD | Corrected the .md.txt extension and added a diagram with visible relationships. |
| Small dataset limits performance conclusions | Report actual plans and timings; defer scalability claims until an authorized representative benchmark. |
| Cleanup screenshots do not prove individual rejections | Capture each expected error and relevant successful result separately, followed by rollback. |
| Setup conflicts with an existing database | Follow the existing-database guidance; review changes before applying them. |
| Fictional data limits practical use | Keep DEMO notices visible; use verified sources and provenance for any future expansion. |
| Group presentation requires coordination | Each member reviews the assigned area and prepares a summary and one or two slides. |

## 13. Future Improvements

Possible extensions, not implemented features, include:

- Source references, retrieval dates, and controlled imports for verified official tariff data.
- A formally specified model for agreement eligibility and preferential rates.
- Country-specific agreement membership dates and richer customs classifications.
- A parameterized historical lookup interface and reporting dashboard.
- Auditing, reviewed migrations, and a repeatable automated test suite in an authorized test environment.
- Representative performance benchmarks before choosing further indexes.
- Shipment quantities and values if duty or revenue calculations become part of the agreed scope.

## 14. References

- [PostgreSQL range types and exclusion constraints](https://www.postgresql.org/docs/18/rangetypes.html#RANGETYPES-CONSTRAINT)
- [PostgreSQL btree_gist extension](https://www.postgresql.org/docs/18/btree-gist.html)
- [pgAdmin ERD Tool](https://www.pgadmin.org/docs/pgadmin4/latest/erd_tool.html)
- [PostgreSQL 18 — Privileges](https://www.postgresql.org/docs/18/ddl-priv.html)
- [PostgreSQL 18 — Sequence behavior and rollback limitations](https://www.postgresql.org/docs/18/functions-sequence.html)

These are technical implementation references. No official tariff dataset is claimed as a source for the fictional sample agreements or rates.

## 15. Presentation Link (Google Drive)

[NYALA 00 Database Security presentation on Google Drive](https://docs.google.com/presentation/d/1BV4w4s0tWRzjOzBfvoJqfjAZtMj_zNYh/edit?usp=drivesdk&ouid=105777660682550958624&rtpof=true&sd=true)

The project lead will confirm that the lecturer has viewing access before submission.

## 16. Group Contributions

### Approved Allocation of Responsibilities

The group leader approved this allocation on `2026-11-05`. It assigns review, completion, and presentation responsibilities for the existing project. **It is not a record of completed work or a claim that any member originally authored an existing file.** Completion confirmations and supporting evidence are still pending.

| Member | Assigned responsibility | Expected deliverable |
|---|---|---|
| Mubarak Dawood | Coordination and final submission | Integrate README sections and confirmed contributions; verify teammate repository access, links, and submission readiness; submit the required form. |
| Nabeel Suliman Ahmed Idris | Introduction and research | Review and finalize the introduction, problem statement, objectives, concepts, and references; explain the fictional-data scope. |
| Mohamed Ali MohamedTahir Ali | Database design | Review the six tables, ERD, keys, relationships, normalization rationale, and data dictionary; prepare the design explanation. |
| Maysara Dafaallh | Tables and sample data | Review scripts 01–07; explain table creation, sample inserts and counts; prepare examples without rebuilding the working database. |
| Moaz Mohammed yacoub | Queries and reporting | Review scripts 08–10; explain joins, grouping, HAVING, CTEs, and views; capture analytical query outputs. |
| Almonzer Abdullah | Indexes and authorization | Review scripts 11–13; explain saved plans and role permissions; document authorization tests without unsupported performance claims. |
| Asim Mohamed adam | Data-integrity testing | Review script 14; document constraint-rejection results and cleanup; finalize challenges and recommendations. |
| Mustafa Omer Mustafa | Presentation and future scope | Finalize real-world applications and future improvements; collect, format, and upload the PowerPoint; provide its Google Drive link to the leader. |

Every member should prepare a summary and one or two slides, explain their assigned area, and understand the overall project. Coordinate database tests in one controlled session, with each test followed by its rollback.

After each member completes and confirms their work, record the actual contribution and a relevant file, screenshot, commit, or slide reference here. Assignment alone is not completion.

### Final Submission Checklist

- [x] Project uploaded to the correct group repository.
- [x] SQL scripts, sample data, diagrams, and review documentation included.
- [x] README organized into the 16 requested sections; names and approved responsibilities recorded.
- [x] Technical references documented.
- [ ] Member review of the documentation and SQL explanations completed.
- [x] Security and integrity tests 13–14 evidenced with screenshots and test results updated.
- [ ] Fresh Q1/HAVING execution evidence captured.
- [ ] Individual completed contributions confirmed and documented.
- [ ] Google Drive presentation link added and lecturer access checked.
- [ ] Teammate repository invitations/access checked.
- [ ] Required submission form sent.
- [ ] Every member prepared to explain the project.

### Repository Files

```text
NYALA00/
├── README.md
├── sql/
│   └── SQL scripts 01–04 and 08–12
├── sample-data/
│   └── Sample data scripts 05–07
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

The execution order listed above remains unchanged. Scripts 01–04 and 08–12 are in `sql/`, sample data scripts 05–07 are in `sample-data/`, and scripts 13–14 are in `tests/`.

### Supporting Documentation
- [Implementation and test results](docs/test_results.md)
- [Database design and data dictionary](docs/database_design.md)
- [Implementation screenshots](docs/screenshots/)
- [Database diagrams](diagrams/)
- [Security and constraint test scripts](tests/)
- [Review changes and validation limits](docs/review_notes.md)
