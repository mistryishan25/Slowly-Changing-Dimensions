# Dimensional Data Modeling Project

## 1. Project Overview  
This project focuses on **dimensional data modeling** using the `actor_films` dataset. It involves creating SQL queries and table definitions to facilitate efficient data analysis and track changes over time using **Slowly Changing Dimensions (SCD)** techniques.

Key features include:
- **Data Normalization**: Structuring data into organized tables for efficient querying.
- **Historical Tracking**: Implementing Type 2 SCD (interval-based tracking) for actor performance metrics.
- **Incremental Updates**: Managing updates without overwriting historical data.

---

## 2. Dataset Description  
The `actor_films` dataset contains the following columns:
- **actor**: Actor's name.
- **actorid**: Unique identifier for each actor.
- **film**: Film name.
- **year**: Film release year.
- **votes**: Number of votes received for the film.
- **rating**: Film rating.
- **filmid**: Unique identifier for each film.

Primary key: (`actorid`, `filmid`).

---

## 3. Key Tasks and Implementation

### Task 1: **Design the Actors Data Model**
- **Objective**: Create a structured schema to store actor performance metrics and filmography.
- **Approach**:  
  - Define the `actors` table with nested fields for film-specific details.  
  - Incorporate computed attributes for categorizing actors based on film performance.

---

### Task 2: **Build and Populate Actor Profiles**
- **Objective**: Populate the `actors` table with aggregated statistics grouped by actor and year.
- **Approach**:  
  - Extract data from the `actor_films` table and group by actor and year.  
  - Compute cumulative statistics like votes and ratings for each actor.
  - Insert the processed data into the `actors` table.

---

### Task 3: **Set Up Historical Tracking with SCD**
- **Objective**: Implement Type 2 Slowly Changing Dimensions (SCD) to preserve historical data without overwriting past records.
- **Approach**:  
  - Create the `actors_history_scd` table with start and end dates for each record.
  - Track changes in quality classification and activity status over time.

---

### Task 4: **Backfill Historical Data for SCD**
- **Objective**: Populate historical records in the SCD table using initial data.
- **Approach**:  
  - Use recursive queries and Common Table Expressions (CTEs) to generate initial intervals.
  - Ensure accurate representation of historical data for each actor.

---

### Task 5: **Enable Incremental Updates for SCD**
- **Objective**: Keep the historical table up to date by processing changes as new data arrives.
- **Approach**:  
  - Compare incoming data with existing records to detect changes.  
  - Close outdated records and insert new records for updated data.

---

## 4. Scripts and Queries  
- **[actors_ddl.sql](scripts/actors_ddl.sql)**: Defines the schema for the `actors` table.
- **[populate_actors.sql](scripts/populate_actors.sql)**: Populates the `actors` table with aggregated data.
- **[actors_history_scd_ddl.sql](scripts/actors_history_scd_ddl.sql)**: Defines the schema for the historical tracking table (`actors_history_scd`).
- **[backfill_scd.sql](scripts/backfill_scd.sql)**: Backfills historical data for the SCD table.
- **[incremental_scd.sql](scripts/incremental_scd.sql)**: Handles incremental updates to the SCD table.

---

## 5. Applications  
### Industry Use Cases:
- **Media Analytics**: Track actor performance over time for casting and content recommendations.
- **Marketing Campaigns**: Analyze trends in film popularity for targeted promotions.
- **Subscription Services**: Recommend films based on actors' past performances.
- **Retail and E-commerce**: Monitor product demand trends over time.

### Broader Applications:
- **Healthcare**: Track patient histories and treatment trends.
- **Finance**: Analyze stock performance over different periods.
- **Human Resources**: Monitor employee performance and career progression.

---

## 6. Conclusion  
This project showcases the use of dimensional data modeling and SCD techniques to organize and analyze data over time. By implementing incremental updates and historical tracking, it supports efficient querying and analysis of actor performance and trends.
