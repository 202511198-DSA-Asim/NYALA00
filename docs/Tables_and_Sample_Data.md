# Tables and Sample Data (Scripts 01–07)

**Assigned member:** Maysara Dafaallh
**Scope:** Review `sql/01_initial_tables.sql` through `sql/07_sample_tariffs.sql`; explain table creation, sample inserts and record counts; prepare demonstration examples without rebuilding the working database.
**Database:** `eac_trade_tariffs` (PostgreSQL), schema `eac`

> **Status of this section:** Prepared from static review of the SQL files. No database connection was used and no script was executed. Demonstration queries in Section 5 are read-only `SELECT` statements and are written to be run in the existing database from pgAdmin's Query Tool. Do not rerun scripts 01–07 on the working database.

---

## 1. Overview

Scripts 01–04 define the structure (six tables). Scripts 05–07 populate it with a small, fictional educational dataset.

| Script | Type | What it does |
|---|---|---|
| `01_initial_tables.sql` | Structure | Creates schema `eac`, tables `countries` and `goods_categories` |
| `02_goods.sql` | Structure | Creates `goods` (references `goods_categories`) |
| `03_trade_agreements.sql` | Structure | Creates `trade_agreements` and the junction table `agreement_countries` |
| `04_tariff_rates.sql` | Structure | Enables `btree_gist`, creates `tariff_rates` with the no-overlap exclusion constraint |
| `05_sample_goods_and_countries.sql` | Data | Inserts countries, goods categories, goods |
| `06_sample_agreements.sql` | Data | Inserts fictional agreements and their country memberships |
| `07_sample_tariffs.sql` | Data | Inserts fictional tariff rates |

The order matters: a table that holds a foreign key can only be created after the table it references, and sample rows must be inserted parent-first (countries and categories → goods → agreements → memberships → tariffs).

---

## 2. Table Creation (Scripts 01–04)

### 2.1 `countries` and `goods_categories` (01)

- Everything is created inside a transaction (`BEGIN … COMMIT`), so the script either fully succeeds or leaves nothing behind.
- Primary keys use `INTEGER GENERATED ALWAYS AS IDENTITY`: PostgreSQL generates the ID, and manual ID values are rejected unless explicitly overridden.
- **`countries`**: `country_name` (unique, not blank) and `iso_code` (unique, must match `^[A-Z]{2}$`, i.e. exactly two uppercase letters). The check validates the format only, not membership in an official country-code list.
- **`goods_categories`**: `category_name` (unique, not blank) and an optional `description`.
- Constraints are named (`pk_…`, `uq_…`, `chk_…`) so that error messages identify exactly which rule was broken.
- The final `SELECT` against `information_schema.tables` confirms the tables exist.

### 2.2 `goods` (02)

- Columns: `goods_id` (identity PK), `goods_name`, `goods_code`, `category_id`, `description`.
- `goods_code` is unique (internal project identifier, not an official customs code). `goods_name` is **not** unique; the code is what distinguishes goods.
- `fk_goods_category` links each good to a category with `ON DELETE RESTRICT`, so a category that still has goods cannot be deleted.

### 2.3 `trade_agreements` and `agreement_countries` (03)

- **`trade_agreements`**: unique, non-blank `agreement_name`; `start_date` required; `end_date` optional (NULL means no end date specified). `chk_trade_agreements_dates` requires `end_date` to be NULL or on/after `start_date`.
- **`agreement_countries`** is the junction table for the many-to-many relationship between agreements and countries. Its primary key is the **composite** `(agreement_id, country_id)`, which prevents recording the same country twice in the same agreement while allowing a country to join many agreements. Both foreign keys use `ON DELETE RESTRICT`.

### 2.4 `tariff_rates` (04)

- `CREATE EXTENSION IF NOT EXISTS btree_gist` is required for the exclusion constraint (it allows `=` comparisons on integer columns to be combined with range overlap checks).
- Columns: `goods_id`, `origin_country_id`, `destination_country_id`, `tariff_percent NUMERIC(7,3)`, `effective_from`, `effective_to`, `notes`.
- Three foreign keys (goods, origin country, destination country), all `ON DELETE RESTRICT`.
- Check constraints:
  - `chk_tariff_percent`: tariff must be `>= 0` and not `NaN`.
  - `chk_tariff_different_countries`: origin and destination must differ.
  - `chk_tariff_dates`: dates must be finite, and `effective_to` (if present) must not precede `effective_from`.
- **`ex_tariff_no_overlap`** (exclusion constraint): for the same goods, origin and destination, two tariff periods cannot overlap. Periods use inclusive boundaries (`daterange(effective_from, effective_to, '[]')`), and a NULL `effective_to` is treated as open-ended. This is what preserves tariff *history* safely: a new rate must start after the previous one ends.

### Summary of integrity rules in these four scripts

| Rule type | Examples |
|---|---|
| Primary keys | One identity PK per table; composite PK on `agreement_countries` |
| Foreign keys | 6 in total, all `ON DELETE RESTRICT` |
| Unique | country name, ISO code, category name, goods code, agreement name |
| Check | non-blank names, ISO format, agreement dates, tariff ≥ 0, different countries, tariff dates |
| Exclusion | no overlapping tariff periods per goods and route |

---

## 3. Sample Data (Scripts 05–07)

All data is **fictional and for education only**. Agreements are prefixed `DEMO`; every tariff row carries the note *"DEMO ONLY: fictional tariff, not an official rate."*

### 3.1 Script 05 — countries, categories, goods

- **4 countries:** Kenya (KE), Uganda (UG), Tanzania (TZ), Rwanda (RW). This is a sample, not the full list of East African Community members.
- **4 categories:** Agricultural Products, Processed Foods, Textiles, Construction Materials.
- **8 goods** (two per category), e.g. Coffee Beans `AGR-001`, Tea Leaves `AGR-002`, Wheat Flour `FOOD-001`, Cooking Oil `FOOD-002`, Cotton Fabric `TEX-001`, Cotton Shirts `TEX-002`, Cement `CON-001`, Steel Bars `CON-002`.
- **Technique worth explaining:** goods are inserted from a `VALUES` list, and each `category_id` is looked up by **category name** with a subquery rather than hard-coding ID numbers. Because IDs are generated automatically, this avoids assuming which number each category received.
- The script ends with a `UNION ALL` count query for the three tables.

### 3.2 Script 06 — agreements and memberships

| Agreement | Period | Members |
|---|---|---|
| DEMO Regional Trade Agreement | 2025-01-01 → no end date | KE, UG, TZ, RW (4) |
| DEMO Agricultural Cooperation | 2026-01-01 → 2028-12-31 | KE, UG (2) |
| DEMO Textile Trade Agreement | 2024-01-01 → 2025-12-31 (expired) | TZ, RW (2) |

- Memberships are inserted by looking up the agreement ID by name and the country ID by ISO code, again avoiding hard-coded IDs.
- The verification query uses `LEFT JOIN`, `COUNT`, `STRING_AGG` and `GROUP BY` to show each agreement with its member count and country list.

### 3.3 Script 07 — tariffs

12 fictional tariff rows, with IDs resolved by goods code and ISO codes. The data deliberately demonstrates:

- **Tariff history without overlap:** Coffee UG→KE is 10% for all of 2025, then 5% from 2026-01-01 (open-ended). Steel Bars KE→UG is 25% for 2026, then 22% from 2027-01-01.
- **Same goods on different routes:** Coffee has both UG→KE and RW→TZ rows; Wheat Flour has TZ→UG and UG→KE rows.
- **Zero tariffs:** Tea KE→RW and Wheat Flour UG→KE are 0%, which is a recorded rate, not a missing one.
- A closing query joins tariffs to goods and both countries and labels each row **Active / Expired / Future** against the fixed reference date `2026-11-05`, which keeps the demonstration reproducible.

---

## 4. Record Counts

| Table | Records | Source script |
|---|---:|---|
| `countries` | 4 | 05 |
| `goods_categories` | 4 | 05 |
| `goods` | 8 | 05 |
| `trade_agreements` | 3 | 06 |
| `agreement_countries` | 8 | 06 |
| `tariff_rates` | 12 | 07 |
| **Total** | **39** | |

Tariff status on the reference date `2026-11-05`: **10 active, 1 expired** (Coffee UG→KE, 2025 rate), **1 future** (Steel Bars KE→UG, 2027 rate).

These counts come from counting the rows in the scripts and match the counts already recorded in `README.md` (Section 8) and `docs/test_results.md`. They have not been re-confirmed against a live connection by this reviewer; Section 5 includes a query to do that in pgAdmin.

---

## 5. Demonstration Examples (read-only)

Run these in the Query Tool connected to `eac_trade_tariffs`. They only read data.

**5.1 Confirm record counts in all six tables**

```sql
SELECT 'countries' AS table_name, COUNT(*) AS total_records FROM eac.countries
UNION ALL SELECT 'goods_categories', COUNT(*) FROM eac.goods_categories
UNION ALL SELECT 'goods',            COUNT(*) FROM eac.goods
UNION ALL SELECT 'trade_agreements', COUNT(*) FROM eac.trade_agreements
UNION ALL SELECT 'agreement_countries', COUNT(*) FROM eac.agreement_countries
UNION ALL SELECT 'tariff_rates',     COUNT(*) FROM eac.tariff_rates;
```

Expected: 4, 4, 8, 3, 8, 12.

**5.2 Goods with their category names**

```sql
SELECT g.goods_code, g.goods_name, c.category_name
FROM eac.goods AS g
JOIN eac.goods_categories AS c ON c.category_id = g.category_id
ORDER BY g.goods_code;
```

**5.3 Agreements with members**

```sql
SELECT a.agreement_name, a.start_date, a.end_date,
       COUNT(ac.country_id) AS member_count,
       STRING_AGG(c.country_name, ', ' ORDER BY c.country_name) AS participating_countries
FROM eac.trade_agreements AS a
LEFT JOIN eac.agreement_countries AS ac ON ac.agreement_id = a.agreement_id
LEFT JOIN eac.countries AS c ON c.country_id = ac.country_id
GROUP BY a.agreement_id, a.agreement_name, a.start_date, a.end_date
ORDER BY a.agreement_name;
```

**5.4 Tariff history for one good (shows non-overlapping periods)**

```sql
SELECT g.goods_name,
       o.country_name AS origin, d.country_name AS destination,
       t.tariff_percent, t.effective_from, t.effective_to
FROM eac.tariff_rates AS t
JOIN eac.goods AS g ON g.goods_id = t.goods_id
JOIN eac.countries AS o ON o.country_id = t.origin_country_id
JOIN eac.countries AS d ON d.country_id = t.destination_country_id
WHERE g.goods_code = 'AGR-001'
ORDER BY o.country_name, d.country_name, t.effective_from;
```

**5.5 Tariff status on the fixed reference date**

```sql
SELECT
    COUNT(*) FILTER (WHERE effective_from <= DATE '2026-11-05'
                       AND (effective_to IS NULL OR effective_to >= DATE '2026-11-05')) AS active,
    COUNT(*) FILTER (WHERE effective_to < DATE '2026-11-05')  AS expired,
    COUNT(*) FILTER (WHERE effective_from > DATE '2026-11-05') AS future
FROM eac.tariff_rates;
```

Expected: 10, 1, 1.

**5.6 Constraint listing (for the slide on integrity rules)**

```sql
SELECT conrelid::regclass AS table_name, conname AS constraint_name,
       CASE contype WHEN 'p' THEN 'PRIMARY KEY' WHEN 'f' THEN 'FOREIGN KEY'
                    WHEN 'u' THEN 'UNIQUE' WHEN 'c' THEN 'CHECK' WHEN 'x' THEN 'EXCLUDE' END AS type
FROM pg_constraint
WHERE connamespace = 'eac'::regnamespace
ORDER BY conrelid::regclass::text, contype, conname;
```

> Avoid running the `INSERT` scripts again: tables use `GENERATED ALWAYS` identity IDs and unique constraints, so a rerun would fail or create duplicate-looking data. If a live demonstration of rejection is wanted, use the rollback-based tests in `tests/14_constraint_tests.sql` (Asim Mohamed adam's section).

---

## 6. Talking Points for the Presentation

1. **Why six tables?** Each fact is stored once (a country's name lives only in `countries`), and other tables point to it by ID. This avoids inconsistent names and invalid references.
2. **Why a junction table?** Agreements and countries are many-to-many; `agreement_countries` with a composite key models that and blocks duplicates.
3. **Why look up IDs by name/code in the inserts?** Identity IDs are generated by the database, so scripts should not guess them.
4. **Why `ON DELETE RESTRICT`?** To stop deletion of a parent record that still has dependants.
5. **Why the exclusion constraint?** It lets the database keep historical tariff rates while guaranteeing only one rate applies to a goods item and route on any date.
6. **Honest scope:** the data is fictional, countries are a sample, and goods codes are internal, not official customs codes.

### Suggested slides (one or two)

- **Slide 1 – Structure:** the six tables with their keys (reuse the reviewed ERD in `diagrams/`) and the integrity-rule summary table from Section 2.
- **Slide 2 – Sample data:** the record-count table (Section 4) and one screenshot, such as `docs/screenshots/07_sample_tariffs.png`, with the tariff-history example.

Existing screenshots relevant to this section: `01_initial_tables.png`, `02_goods.png`, `03_trade_agreements.png`, `04_tariff_rates.png`, `06_sample_agreements.png`, `07_sample_tariffs.png`.

---

## 7. Notes for the Coordinator

- This section is **assigned review work**, not a claim of original authorship (consistent with README Section 16). Maysara should confirm completion before it is recorded as a contribution.
- Items to coordinate:
  - With **Mohamed Ali MohamedTahir Ali**: keep the description of keys and relationships consistent with `docs/database_design.md`.
  - With **Moaz Mohammed yacoub**: the queries in scripts 08–10 use the same sample data and the same reference date, `2026-11-05`.
- Review conclusion: no errors or inconsistencies were found in scripts 01–07 during this static review. Sample row counts match the README. This was a read-through of the SQL, not a live execution.
