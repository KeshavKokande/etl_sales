# 🚀 MY\_DATA\_PIPELINE

A complete end-to-end data engineering project using **Airflow**, **dbt**, **Snowflake**, and **Docker**. This repository automates the ingestion, transformation, and testing of cleaned e-commerce order data.

---

## 🧾 Table of Contents

* [Overview](#overview)
* [Project Architecture](#project-architecture)
* [Tech Stack](#tech-stack)
* [Folder Structure](#folder-structure)
* [Setup Instructions](#setup-instructions)
* [Running the Pipeline](#running-the-pipeline)
* [Airflow DAG Details](#airflow-dag-details)
* [dbt Model Structure](#dbt-model-structure)
* [Incremental Load Logic](#incremental-load-logic)
* [CI/CD Planning](#ci-cd-planning)

---

## 🔍 Overview

This project loads raw e-commerce data (CSV), cleans it, and ingests it into **Snowflake**. It then runs **dbt models** to transform the data into meaningful **DIM** and **FACT** tables. The entire process is orchestrated using **Apache Airflow**, containerized using **Docker**.

---

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
* **dbt (Data Build Tool)**: Data transformation
* **Snowflake**: Cloud data warehouse
* **Docker**: Containerization and environment setup
* **Python**: Data cleaning and transformation

---

## 🗂️ Folder Structure

```bash
MY_DATA_PIPELINE/
|├── Airflow/
|   |
|   ├── dags/               # Airflow DAGs
|   ├── airflow.cfg         # Airflow config
|   ├── .env                # Snowflake credentials
|   ├── docker-compose.yml   # Compose file to run Airflow + dbt
|   ├── dockerfile          # Dockerfile for Airflow image
|
├── dbt_project/
|   ├── mockkaro_dbt/
|       ├── models/         # dbt models (staging, marts)
|       ├── snapshots/      # dbt snapshots (optional)
|       ├── seeds/          # Seed data if needed
|       ├── tests/          # Custom tests
|       ├── dbt_project.yml  # dbt config file
|
└── MOCK_DATA.csv           # Input dataset
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

## 🧠 Airflow DAG Details

**DAG Name:** `combined_pipeline_dag`

**Key Operators:**

* `PythonOperator`: for CSV cleaning, Snowflake loading, quote generation
* `BashOperator`: for dbt execution (`dbt run`, `dbt test`)
* `TaskGroup`: groups dbt run/test together

---

## 📊 dbt Model Structure

* `staging/`: Extract columns from raw

  * `stg_orders.sql`, `stg_customers.sql` etc.
* `marts/dim/`: Cleaned dimension tables

  * `dim_product.sql`, `dim_store.sql` etc.
* `marts/fact/`: Aggregated fact tables

  * `fact_orders.sql`, `fact_sales_summary.sql`

**Schema Configuration:** `dbt_project.yml` handles folder-specific schema overrides.

---

## 📈 Incremental Load Logic (Planned or In Use)

* For staging tables: `materialized='incremental'`
* Add `unique_key` in `config` block
* Add logic like:

```sql
WHERE {{ this._is_incremental() }} AND updated_at > (SELECT MAX(updated_at) FROM {{ this }})
```

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

---

## 🙋 FAQs

* **Q:** Can I run dbt models outside Airflow?
  **A:** Yes, run them manually using:

  ```bash
  cd dbt_project/mockkaro_dbt
  dbt run --select marts
  ```

* **Q:** How do I check logs?
  **A:** Inside Airflow UI > DAG Runs > Task Logs

* **Q:** What if cleaned data loads duplicate rows?
  **A:** Add deduplication logic or switch to incremental loading strategy.

---

## 🤝 Contributions

Feel free to raise issues, PRs, or suggest improvements.

---

Made with ❤️ by Keshav Kokande
