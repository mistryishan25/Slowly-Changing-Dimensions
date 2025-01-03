/*
CONTEXT:
- Manages SCD data for actors, merging last year's data with this year's data, identifying unchanged, changed, and new records.

RESULT EXPECTATION:
- Returns a union of historical, unchanged, changed, and new actor records, reflecting updates across seasons.

ASSUMPTIONS:
- The "actors_scd" table tracks actor data with attributes for quality class, active status, and seasons.
- Uses `scd_type` to manage changes in actor attributes.

APPROACH:
- CTEs:
  1. `last_year_scd`: Data from previous years, for example 2020.
  2. `historical_scd`: Historical data, for example data changes before 2020.
  3. `this_year_data`: The new generated data, for example in our case data for 2021.
  4. `unchanged_records`: Identifies unchanged records.
  5. `changed_records`: Identifies changes in data.
  6. `unnested_changed_records`: Processes changed records.
  7. `new_records`: Adds new data for 2021.
- Final result combines all data using `UNION ALL`.

*/


    create table actors_scd(
        actor text,
        quality_class quality_class,
        is_active boolean,
        start_year integer,
        end_year integer,
        current_year integer,
        primary key (actor, current_year)
    );

-- the data for the last YEAR, that could potentially change
-- drop type scd_type
create type scd_type as
(
    quality_class quality_class,
    is_active     boolean,
    start_date    integer,
    end_date      integer
);

with last_year_scd as (select *
                         from actors_scd
                         where current_year = 2020 and end_year = 2020),

--     select * from last_year_scd;

     historical_scd as (select actor,
                               quality_class,
                               is_active,
                               start_year,
                               end_year
                        from actors_scd
                        where current_year = 2020
                          and end_year < 2020),

--     new incoming data
     this_year_data as (select *
                          from actors_scd
                          where current_year = 2021),

     unchanged_records as (select ts.actor,
                                  ts.quality_class,
                                  ts.is_active,
                                  ls.start_year,
                                  ts.current_year as end_season
                           from this_year_data ts
                                    join last_year_scd ls
                                         on ts.actor = ls.actor
                           where ts.quality_class = ls.quality_class
                             and ts.is_active = ls.is_active
--
     ),
     changed_records as (select ts.actor,
                                unnest(array [
                                    row (
                                        ls.quality_class,
                                        ls.is_active,
                                        ls.start_year,
                                        ls.current_year
                                        )::scd_type,
                                    row (
                                        ts.quality_class,
                                        ts.is_active,
                                        ts.start_year,
                                        ts.current_year
                                        )::scd_type
                                    ]) as records

                         from this_year_data ts
                                  left join last_year_scd ls
                                            on ts.actor = ls.actor
                         where ts.quality_class <> ls.quality_class
                            or ts.is_active <> ls.is_active),
     unnested_changed_records as (select actor,
                                         (records::scd_type).quality_class,
                                         (records::scd_type).is_active,
                                         (records::scd_type).start_date,
                                         (records::scd_type).end_date
                                  from changed_records),
     new_records as (select ts.actor,
                            ts.quality_class,
                            ts.is_active,
                            ts.current_year as start_season,
                            ts.current_year as end_season
                     from this_year_data ts
                              left join last_year_scd ls on
                         ts.actor = ls.actor)

select *
from historical_scd
union all
select*
from unnested_changed_records
union all
select *
from unchanged_records
union all
select *
from new_records;




