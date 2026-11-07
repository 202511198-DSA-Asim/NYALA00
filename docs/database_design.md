# Database Design and Data Dictionary

## 1. Design Overview

The NYALA 00 project uses six related tables in the PostgreSQL schema `eac`.

The design separates countries, goods, categories, agreements, membership records, and tariffs to reduce duplication and maintain referential integrity.

## 2. Data Dictionary

### 2.1 countries

Stores the countries used in the project.

| Column | Data type | Required | Description |
|---|---|---|---|
| country_id | INTEGER, identity | Yes | Automatically generated primary key |
| country_name | VARCHAR(100) | Yes | Unique, nonblank country name |
| iso_code | VARCHAR(2) | Yes | Unique code consisting of two uppercase letters |

The code-format constraint checks the format only. It does not verify codes against an official country-code registry.

### 2.2 goods_categories

Stores educational goods categories.

| Column | Data type | Required | Description |
|---|---|---|---|
| category_id | INTEGER, identity | Yes | Automatically generated primary key |
| category_name | VARCHAR(100) | Yes | Unique, nonblank category name |
| description | TEXT | No | Optional category description |

### 2.3 goods

Stores goods and their category assignments.

| Column | Data type | Required | Description |
|---|---|---|---|
| goods_id | INTEGER, identity | Yes | Automatically generated primary key |
| goods_name | VARCHAR(150) | Yes | Nonblank goods name |
| goods_code | VARCHAR(30) | Yes | Unique, nonblank internal identifier |
| category_id | INTEGER | Yes | Foreign key referencing goods_categories |
| description | TEXT | No | Optional goods description |

Goods names are not required to be unique. The internal goods code distinguishes records.

### 2.4 trade_agreements

Stores agreement descriptions and validity dates.

| Column | Data type | Required | Description |
|---|---|---|---|
| agreement_id | INTEGER, identity | Yes | Automatically generated primary key |
| agreement_name | VARCHAR(200) | Yes | Unique, nonblank agreement name |
| start_date | DATE | Yes | Agreement start date |
| end_date | DATE | No | Agreement end date; null means unspecified |
| description | TEXT | No | Optional agreement description |

When supplied, the end date must be on or after the start date.

The sample agreements are fictional and identified by the prefix `DEMO`.

### 2.5 agreement_countries

Associates agreements with participating countries.

| Column | Data type | Required | Description |
|---|---|---|---|
| agreement_id | INTEGER | Yes | Foreign key referencing trade_agreements |
| country_id | INTEGER | Yes | Foreign key referencing countries |

The primary key is the pair `(agreement_id, country_id)`.

This prevents duplicate membership for the same country and agreement while allowing each country to participate in multiple agreements.

Individual membership start and end dates are outside the current model.

### 2.6 tariff_rates

Stores percentage tariffs for goods moving between countries.

| Column | Data type | Required | Description |
|---|---|---|---|
| tariff_id | INTEGER, identity | Yes | Automatically generated primary key |
| goods_id | INTEGER | Yes | Foreign key referencing goods |
| origin_country_id | INTEGER | Yes | Foreign key referencing countries |
| destination_country_id | INTEGER | Yes | Foreign key referencing countries |
| tariff_percent | NUMERIC(7,3) | Yes | Nonnegative tariff percentage; NaN is rejected |
| effective_from | DATE | Yes | First day of validity; must be finite |
| effective_to | DATE | No | Last day of validity; finite when supplied |
| notes | TEXT | No | Optional context and educational-data notice |

A value of `15.000` means 15%.

The origin and destination countries must differ. An end date, when provided, must not precede the start date.

Both date boundaries are inclusive. A null end date represents an open-ended period.

An exclusion constraint prevents two tariff records from having overlapping validity periods when all three of the following match:

- Goods item.
- Origin country.
- Destination country.

A reversed trade direction is a different combination.

## 3. Relational Schema

Notation: PK = primary key; FK = foreign key; UQ = unique.

```text
countries(
    country_id PK,
    country_name UQ,
    iso_code UQ
)

goods_categories(
    category_id PK,
    category_name UQ,
    description
)

goods(
    goods_id PK,
    goods_name,
    goods_code UQ,
    category_id FK -> goods_categories.category_id,
    description
)

trade_agreements(
    agreement_id PK,
    agreement_name UQ,
    start_date,
    end_date,
    description
)

agreement_countries(
    agreement_id PK/FK -> trade_agreements.agreement_id,
    country_id PK/FK -> countries.country_id
)

tariff_rates(
    tariff_id PK,
    goods_id FK -> goods.goods_id,
    origin_country_id FK -> countries.country_id,
    destination_country_id FK -> countries.country_id,
    tariff_percent,
    effective_from,
    effective_to,
    notes
)
```

## 4. Relationship Cardinalities

| Parent | Child | Relationship |
|---|---|---|
| goods_categories | goods | One category to zero or more goods |
| goods | tariff_rates | One goods item to zero or more tariff records |
| countries | tariff_rates | One origin country to zero or more tariff records |
| countries | tariff_rates | One destination country to zero or more tariff records |
| trade_agreements | agreement_countries | One agreement to zero or more membership records |
| countries | agreement_countries | One country to zero or more membership records |

Every child record references exactly one parent for each listed foreign key because the foreign-key columns are required.

Countries and agreements have a many-to-many relationship implemented through `agreement_countries`.

## 5. Normalization Rationale

### First Normal Form

Each column stores a single value, and each row has a primary key. Agreement participants are stored as separate membership rows rather than as a comma-separated list.

### Second Normal Form

The membership table has a composite primary key and no non-key attributes. The remaining tables use single-column primary keys and keep attributes associated with the represented entity.

### Third Normal Form

Country names, category names, and agreement details are stored in their own tables instead of being repeated in related records.

For example:

- Goods store a category identifier, not a repeated category description.
- Tariffs store country identifiers, not repeated country names.
- Agreement membership does not duplicate agreement details.

Under the stated project assumptions, this structure supports a third-normal-form design.

## 6. Referential Integrity and Deletion

All six foreign-key relationships use `ON DELETE RESTRICT`.

A parent record cannot be deleted while child records still reference it. For example, a category cannot be deleted while goods are assigned to it.

The restricted reader and editor roles do not have deletion privileges. Foreign-key restrictions provide an additional integrity rule for users who do have permission to delete.

## 7. Historical Tariffs

Tariff changes are represented by separate records with non-overlapping validity periods.

Example:

- Previous rate: 2025-01-01 through 2025-12-31.
- Replacement rate: 2026-01-01 onward.

The design retains the previous rate for historical queries. Changes to existing records remain subject to the overlap constraint.

## 8. Views and Derived Values

`v_tariff_details` joins tariff records with readable goods, category, and country names.

`v_active_tariffs` filters those records using `CURRENT_DATE`.

Active status is calculated rather than stored, avoiding a stored status becoming outdated as time passes.

The views are ordinary views: they store query definitions, not separate copies of the result data.

## 9. Scope Boundaries

- Agreement membership does not calculate preferential tariffs.
- The database does not validate real-world tariff legislation.
- Tariff rates and agreement records in the sample dataset are fictional.
- The project does not model shipments, trade quantities, tax payments, or customs revenue.
- The schema does not enforce a minimum number of participating countries per agreement.
- Unique text fields use the database's normal text-comparison behavior; additional case and whitespace normalization is not implemented.

## 10. Diagram

The [reviewed ERD](../diagrams/NYALA_00_ERD.svg) and [PNG export](../diagrams/NYALA_00_ERD.png) show all six foreign-key relationships, including the two separate country references in `tariff_rates`. Each child has exactly one referenced parent; a parent can have zero or more children.

The original [pgAdmin source](../diagrams/NYALA_00_ERD.pgerd) is preserved. Its six tables, 26 columns, primary keys, unique keys, identity settings, nullability, and foreign keys agree with the saved SQL. The original [screenshot](screenshots/NYALA_00_ERD.png) has missing visible connectors, so it should not be used alone to explain relationships. Check and exclusion rules remain defined by SQL files 01–04; the diagram is not a database migration or a complete constraint export.
<!-- Documentation reviewed by: Moaz Mohammed Yacoub -->

