# 🚀 MY\_DATA\_PIPELINE

A complete end-to-end data engineering project using **Airflow**, **dbt**, **Snowflake**, and **Docker**. This repository automates the ingestion, transformation, testing, and validation of cleaned e-commerce order data.

---

## 📜 Table of Contents

* [Overview](#overview)
* [Project Architecture](#project-architecture)
* [Tech Stack](#tech-stack)
* [Folder Structure](#folder-structure)
* [Setup Instructions](#setup-instructions)
* [Running the Pipeline](#running-the-pipeline)
* [Airflow DAG Details](#airflow-dag-details)
* [dbt Model Structure](#dbt-model-structure)
* [Incremental Load Logic](#incremental-load-logic)
* [dbt Testing Overview](#dbt-testing-overview)
* [CI/CD Planning](#ci-cd-planning)

---
<a name="overview"></a>
## 🔍 Overview

This project loads raw e-commerce data (CSV), cleans it, and ingests it into **Snowflake**. It then runs **dbt models** to transform the data into meaningful **DIM** and **FACT** tables. The entire process is orchestrated using **Apache Airflow**, containerized using **Docker**, and tested via **dbt tests**.

---
<a name="project-architecture"></a>
## 🏗️ Project Architecture

```
+--------------+       +----------------+       +----------------+       +-------------+
| MOCK_DATA.CSV|  -->  | Cleaned CSV    |  -->  | Snowflake Table|  -->  | dbt Models  |
+--------------+       +----------------+       +----------------+       +-------------+
                                                              
                      (Airflow orchestrates the full pipeline)
```

---

## ⚙️ Tech Stack

* **Apache Airflow**: Workflow orchestration
* **dbt (Data Build Tool)**: Data transformation and testing
* **Snowflake**: Cloud data warehouse
* **Docker**: Containerization and environment setup
* **Python**: Data cleaning and transformation

---

## 🗂️ Folder Structure

```bash
MY_DATA_PIPELINE/
│
├── Airflow/
│   ├── dags/
│   │   ├── dbt_orchestration_dag.py
│   ├── tasks/ (modular Python tasks)
│   │   ├── clean_load_tasks.py, quote_tasks.py, welcome_tasks.py
│   ├── docker-compose.yml
│   ├── dockerfile
│   ├── airflow.cfg, .env, airflow.db
│   ├── MOCK_DATA.csv, cleaned_sales_data.csv
│
├── dbt_project/
│   ├── sales_dbt/
│   │   ├── models/
│   │   │   ├── staging/
│   │   │   │   ├── stg_orders.sql, stg_customers.sql, ...
│   │   │   ├── marts/
│   │   │   │   ├── dim/ (dim_customers.sql, dim_employee.sql, ...)
│   │   │   │   ├── fact/ (fact_orders.sql, fact_sales_summary.sql, ...)
│   │   ├── macros/, snapshots/, seeds/, tests/
│   │   ├── dbt_project.yml, packages.yml
│
├── requirements.txt, .gitignore, README.md
```

---

## 🛠️ Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/MY_DATA_PIPELINE.git
cd MY_DATA_PIPELINE
```

### 2. Set Snowflake Credentials

Inside `Airflow/.env`, configure:

```dotenv
SNOWFLAKE_USER=your_user
SNOWFLAKE_PASSWORD=your_password
SNOWFLAKE_ACCOUNT=your_account
SNOWFLAKE_WAREHOUSE=your_warehouse
SNOWFLAKE_DATABASE=your_db
SNOWFLAKE_SCHEMA=RAW
```

### 3. Start the Airflow + dbt Environment

```bash
cd Airflow
docker-compose up --build
```

Open Airflow UI: [http://localhost:8080](http://localhost:8080)

---

## ▶️ Running the Pipeline

Once Airflow is running, enable the DAG `combined_pipeline_dag`:

**Task Flow:**

```
print_welcome → print_date → clean_data → load_to_snowflake
         → dbt_tasks (run_stg → run_marts → test_marts) → print_random_quote
```

---

## 🧐 Airflow DAG Details

**DAG Name:** `combined_pipeline_dag`

**Key Operators:**

* `PythonOperator`: for CSV cleaning, Snowflake loading, quote generation
* `BashOperator`: for dbt execution (`dbt run`, `dbt test`)
* `TaskGroup`: groups dbt run/test together

---

## 📊 dbt Model Structure

* `models/staging/`: Extract columns from raw

  * `stg_orders.sql`, `stg_customers.sql`, `stg_products.sql`, ...
* `models/marts/dim/`: Cleaned dimension tables

  * `dim_product.sql`, `dim_store.sql`, `dim_employee.sql`, ...
* `models/marts/fact/`: Aggregated fact tables

  * `fact_orders.sql`, `fact_sales_summary.sql`, `fact_tickets.sql`

**Schema Configuration:** `dbt_project.yml` handles folder-specific schema overrides.

---

## 📈 Incremental Load Logic (Planned)

Although current models use `materialized='table'`, you can enable **incremental materialization** by:

```sql
{{
  config(
    materialized='incremental',
    unique_key='order_id'
  )
}}
```

And wrap logic using:

```sql
{% if is_incremental() %}
  -- WHERE clause to fetch only new/changed rows
{% endif %}
```

---
## 📈 Incremental Load Logic (In Use)
* Merge logic for Snowflake is handled using:

```python
MERGE INTO target_table USING staging_table ON <condition>
WHEN MATCHED THEN UPDATE SET ...
WHEN NOT MATCHED THEN INSERT ...
```
---
## 🔢 dbt Testing Overview

We are validating dbt models using built-in **dbt tests**:

* **Schema Tests** (in `.yml`):

  * `not_null`, `unique`, `relationships`
* **Custom Tests:** planned in `tests/`

To run all tests:

```bash
dbt test --select marts
```

Test results are visible in Airflow UI > Logs after `dbt_test_marts` step.

<!--
---
## 🚀 CI/CD Planning (Optional Setup)

**To integrate GitHub Actions later:**

* Lint Python files with `flake8`
* Run `dbt build` in container
* Deploy using GitHub Secrets for Snowflake

**Sample GitHub Action YAML:** *(add later)*

```yaml
on: [push]
jobs:
  dbt-pipeline:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: docker-compose -f Airflow/docker-compose.yml up --build
```
-->
---

## 🤝 FAQs

* **Q:** Can I run dbt models outside Airflow?
  **A:** Yes, run them manually using:

  ```bash
  cd dbt_project/sales_dbt
  dbt run --select marts
  ```

* **Q:** How do I check logs?
  **A:** Inside Airflow UI > DAG Runs > Task Logs

* **Q:** What if cleaned data loads duplicate rows?
  **A:** Deduplication is handled via Snowflake `MERGE` command with `ORDER_ID` as key.

---

## 👍 Contributions

Feel free to raise issues, PRs, or suggest improvements.

---

Made with ❤️ by Keshav Kokande
