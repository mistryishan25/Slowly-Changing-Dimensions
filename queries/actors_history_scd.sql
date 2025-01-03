/*

CONTEXT:
- Creates and populates a Slowly Changing Dimension (SCD) table, `actors_scd`, which tracks the `quality_class` and `is_active` status for each actor across multiple years.
- Implements Type 2 SCD with `start_date` and `end_date` fields to reflect changes in actor data over time.

RESULT EXPECTATION:
- The `actors_scd` table is populated with records for each actor, including changes in quality class and active status, as well as the start and end years for each period where the actor's status remained the same.

ASSUMPTIONS:
- The "actors" table contains the current data for actors, including `quality_class`, `is_active`, and `current_year`.
- The query uses window functions (`LAG`) to track previous year data and identify changes.
- Change indicators are flagged based on differences in `quality_class` or `is_active` values.

APPROACH:
1. `with_prev`: Tracks previous year's `quality_class` and `is_active` for each actor.
2. `with_indicators`: Flags changes in actor data (quality class or active status).
3. `with_streaks`: Aggregates consecutive periods of the same data into streaks.
4. `INSERT INTO actors_scd`: Populates the table by grouping records by actor and streak, setting the start and end years for each change period.

*/

create table actors_scd
(
    actor         text,
    quality_class quality_class,
    is_active     boolean,
    start_year    integer,
    end_year      integer,
    current_year  integer,
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


with with_prev as (select actor,
       quality_class,
       is_active,
       current_year,
       lag(quality_class,1) over (partition by actor order by current_year) as prev_quality_class,
       lag(is_active,1) over (partition by actor order by current_year) as prev_is_active
from actors),

    with_indicators as (
        select *,
               case when is_active<>prev_is_active then 1
                   when quality_class <> prev_quality_class then 1
                   else 0 end
                   as change_indicator
               from with_prev
    ),
    with_streaks as (
        select *,
    sum(change_indicator) over (partition by actor order by current_year) as streak_identifier from with_indicators
    )

INSERT INTO actors_scd
select actor,
       quality_class,
       is_active,
       streak_identifier,
       min(current_year) as start_year,
       max(current_year) as end_year
from with_streaks
group by actor, current_year, quality_class, streak_identifier, is_active


select * from actors_scd

