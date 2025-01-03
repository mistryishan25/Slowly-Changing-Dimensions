/*

CONTEXT:
- Merges actor data from the previous year and current year, aggregating films, votes, ratings, and quality class.

RESULT EXPECTATION:
- Updates the "actors" table with merged data, including films, total votes, average ratings, and quality classification.

ASSUMPTIONS:
- Data for past and current years exists in "actors" and "actor_films" tables respectively.
- NULL handling and aggregation with `COALESCE` for missing data.
- Quality classification based on average ratings.

APPROACH:
- Use CTEs to fetch past and present year data, then merge and update the "actors" table.
- Assign quality class and calculate active status and current season.

*/


WITH
-- Define the years
years AS (
    SELECT COALESCE(MAX(current_year), 1969) AS past,
           COALESCE(MAX(current_year), 1969) + 1 AS present
    FROM actors
),


-- Yesterday's data
yesterday AS (SELECT actor,
                     films,
                     votes,
                     avg_rating,
                     quality_class,
                     current_year
              FROM actors
              WHERE current_year = (select past from years)),

-- Today's data
today AS (SELECT actor,
                 array_agg(ROW (film, votes, rating, filmid)::film_stats) AS films,
                 SUM(votes)                                               AS votes,
                 ROUND(AVG(rating::DECIMAL), 2)                           AS avg_rating,
                 MAX(year)                                                AS current_year
          FROM actor_films
          WHERE year = (select present from years)
          GROUP BY actor)

-- Combine today's and yesterday's data
INSERT
INTO actors
SELECT COALESCE(t.actor, y.actor)                   AS actor,

       -- Combine films based on actor activity
       CASE
           WHEN y.actor IS NULL THEN t.films -- New actor, take only today's films
           WHEN t.current_year IS NOT NULL THEN y.films || t.films -- Active actor, merge films
           ELSE y.films -- Actor inactive today, take yesterday's films
           END                                      AS films,

       -- Sum up votes
       COALESCE(y.votes, 0) + COALESCE(t.votes, 0)  AS votes,
       CASE
           WHEN y.avg_rating IS NULL THEN t.avg_rating
           WHEN t.avg_rating IS NULL THEN y.avg_rating
           ELSE (y.avg_rating + t.avg_rating) / 2
           END                                      AS avg_rating,


       -- Determine quality class based on ratings
       case
           when y.actor is null then case
                                         when t.avg_rating > 8 then 'star'
                                         when t.avg_rating > 7 then 'good'
                                         when t.avg_rating > 6 then 'average'
                                         else 'bad' end::quality_class
           when t.actor is not null then CASE
                                             when (y.avg_rating + t.avg_rating) / 2 > 8 then 'star'
                                             when (y.avg_rating + t.avg_rating) / 2 > 7 then 'good'
                                             when (y.avg_rating + t.avg_rating) / 2 > 6 then 'average'
                                             else 'bad' end::quality_class
           else y.quality_class end                                            as quality_class,

       -- Check if actor is active today
       t.current_year IS NOT NULL                   AS is_active,

       -- Calculate current season
       COALESCE(t.current_year, y.current_year + 1) AS current_season

FROM today t
         FULL OUTER JOIN
     yesterday y
     ON
         t.actor = y.actor;


select *
from actors
where current_year = 2000


select distinct unnest(films)
from actors
where  actor = 'Orlando Jones';

select *
from actor_films where actor = 'Orlando Jones'

select * fr
