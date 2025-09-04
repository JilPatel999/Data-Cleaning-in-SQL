select * from netflix_clean.netflix_titles;

-- 1) Handling foreign characters for the director column
	-- Was handled by updating the director column data type from varchar to nvarchar

-- 2) Removing duplicates
select show_id, count(*)
from netflix_clean.netflix_titles
group by show_id
having count(*) > 1;
	-- No duplicates in show_id. Can be updated to PK now

	-- Checking duplicates in title
select title, count(*)
from netflix_clean.netflix_titles
group by title
having count(*) > 1;
	-- There are multiple duplicates for title.
    -- expanding the query results to see if in fact those are true duplicates
select * from netflix_clean.netflix_titles
where concat(upper(title), type) in (
select concat(upper(title), type)
from netflix_clean.netflix_titles
group by upper(title)
having count(*) > 1
)
order by title;

	-- removing the true duplicates
with cte as (
select *
, row_number() over (partition by title, type order by show_id) as r
from netflix_clean.netflix_titles
)
select *
from cte
where r=1;

-- 3) Creating new table for listed in, director, country, cast
	
    -- Making director table
select show_id, trim(value) as director
into netflix_directors
from netflix_clean.netflix_titles
cross apply string_split(director, ',');

	-- Making country table
select show_id, trim(value) as country
into netflix_country
from netflix_clean.netflix_titles
cross apply string_split(country, ',');

	-- Making cast table
select show_id, trim(value) as cast
into netflix_cast
from netflix_clean.netflix_titles
cross apply string_split(cast, ',');
	
    -- Making genre (listed_in) table
select show_id, trim(value) as genre
into netflix_genre
from netflix_clean.netflix_titles
cross apply string_split(listed_in, ',');


-- 4) Data type conversion for date added
alter table netflix_clean.netflix_titles
add column date_added_clean date;

update netflix_clean.netflix_titles
set date_added_clean = case
    when date_added is null or trim(date_added) = '' then null
    else str_to_date(date_added, '%M %e, %Y')
end;
select date_added, date_added_clean
from netflix_clean.netflix_titles
limit 20;


-- 5) Populate missing values in the country, duration columns
select *
from netflix_clean.netflix_titles
where country is null;

insert into netflix_country
select  show_id,m.country 
from netflix_raw nr
inner join (
select director,country
from  netflix_country nc
inner join netflix_directors nd on nc.show_id=nd.show_id
group by director,country
) m on nr.director=m.director
where nr.country is null;

select director.country
from netflix_country nc
inner join netflix_directors nd on nc.show_id=nd.show_id
group by director, country
