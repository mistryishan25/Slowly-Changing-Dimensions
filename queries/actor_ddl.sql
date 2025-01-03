/*

CONTEXT:
- Creates a new `actors` table with a custom `film_stats` type to track film-related data.

RESULT EXPECTATION:
- The `actors` table will hold actor data for each year, including a list of films, votes, ratings, and the actor's quality class and active status for the given year.

ASSUMPTIONS:
- The `film_stats` type includes film details like name, vote count, rating, and film ID.
- The `actors` table tracks multiple films for each actor using the `film_stats[]` array type, and associates the actor's activity and quality class with the respective year.

APPROACH:
1. `CREATE TYPE film_stats; CREATE TABLE actors;`: Defines the new `film_stats` type and the `actors` table, linking each actor to their films, votes, average rating, quality class, and active status by year.
2. The query retrieves data from the `actor_films` table

*/


drop table actors;
drop type film_stats;

create type film_stats as
(
    films   text,
    votes   integer,
    rating  real,
    film_id text
);

create table actors
(
    actor         text,
    films         film_stats[],
    votes         integer,
    avg_rating    real,
    quality_class quality_class,
    is_active     boolean,
    current_year  integer,
    primary key (actor, current_year)
);


select *
from actor_films
where year = 1972
order by actor;
