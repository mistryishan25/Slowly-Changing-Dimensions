# Dimensional Data Modeling Project

## 1. Project Overview
This project focuses on **dimensional data modeling** using the `actor_films` dataset. It involves creating SQL queries and table definitions to facilitate efficient data analysis and track changes over time using **Slowly Changing Dimensions (SCD)** techniques.

The project demonstrates:
- **Data Normalization**: Organizing data into structured tables.
- **Historical Tracking**: Implementing Type 2 SCD(interval based) for tracking actor performance metrics.
- **Incremental Updates**: Managing updates without overwriting historical data.

## 2. Dataset Description
The `actor_films` dataset contains:
- **actor**: Actor's name.
- **actorid**: Unique identifier for each actor.
- **film**: Film name.
- **year**: Release year.
- **votes**: Number of votes received.
- **rating**: Film rating.
- **filmid**: Unique identifier for each film.

Primary key: (`actorid`, `filmid`).

## 3. Key Tasks and Implementation

### Task 1: Create `actors` Table
- **Goal:** Normalize actor data by creating a structured table.
- **Steps:**
  1. Define the schema with fields for actor details and performance metrics.
  2. Include a nested structure for storing film-specific data (name, votes, rating, etc.).
  3. Add computed fields for categorizing actors based on film ratings.
- **Output:** Schema for the `actors` table to store normalized data.
- **Script:** [actors_ddl.sql](scripts/actors_ddl.sql)

### Task 2: Populate `actors` Table
- **Goal:** Populate the `actors` table incrementally, one year at a time.
- **Steps:**
  1. Write a query to extract and group data by actor and year.
  2. Compute cumulative statistics for each actor's films.
  3. Insert records into the `actors` table based on these aggregations.
- **Output:** Populated `actors` table for analysis.
- **Script:** [populate_actors.sql](scripts/populate_actors.sql)

### Task 3: Create Historical Table for SCD
- **Goal:** Track performance metrics and activity status using Type 2 SCD.
- **Steps:**
  1. Define schema for `actors_history_scd` table with start and end dates.
  2. Include fields to track historical changes in quality classification and activity status.
  3. Ensure support for multiple historical records per actor.
- **Output:** Schema for `actors_history_scd` table to manage historical data.
- **Script:** [actors_history_scd_ddl.sql](scripts/actors_history_scd_ddl.sql)

### Task 4: Backfill Historical Data
- **Goal:** Populate historical records using initial data.
- **Steps:**
  1. Write a query to extract actor metrics for all available years.
  2. Insert historical records into the `actors_history_scd` table with appropriate start and end dates.
  3. Handle gaps or overlaps in historical data.
- **Output:** Fully populated historical table with backdated records.
- **Script:** [backfill_scd.sql](scripts/backfill_scd.sql)

### Task 5: Incremental Updates
- **Goal:** Incrementally update the SCD table as new data arrives.
- **Steps:**
  1. Compare new data against existing records to detect changes.
  2. Close old records and insert new ones when changes are detected.
  3. Maintain consistency by preserving historical snapshots.
- **Output:** Updated historical table reflecting recent changes.
- **Script:** [incremental_scd.sql](scripts/incremental_scd.sql)

## 4. Applications
### Industry Use Cases
- **Media Analytics**: Track actor performance trends for casting decisions.
- **Marketing Campaigns**: Measure film popularity over time.
- **Subscription Services**: Recommend content based on user preferences.
- **Retail and E-commerce**: Monitor product demand and lifecycle.

### Broader Applications
- **Healthcare**: Patient records and treatment histories.
- **Finance**: Historical stock performance tracking.
- **Human Resources**: Employee performance over time.



