Select * from shows;
select count(*) as Tv_show from shows;
select count(distinct show_id) Tv_Shows from shows;

-- 1. Count the number of Movies vs TV Shows
select type, count(*)
	from shows
group by 1;


-- 2. Find the most common rating for movies and TV shows

with counting as (
    select 
        type, 
        rating, 
        count(*) as Total_Num
    from 
        shows
    group by 
        type, rating
),
rankRating as (
    select 
        type, 
        rating, 
        Total_Num,
        Rank() over (partition by type order by Total_Num desc) as rankings
    from 
        counting
)
select 
    type, 
    rating, 
    Total_Num
from 
    rankRating
where 
    rankings = 1;

-- 3. List all movies released in a specific year (e.g., 2020)

select title as Movie_Names,release_year from shows
where release_year= 2020 and type ='Movie';

-- -- 4. Find the top 5 countries with the most content on Netflix
/*
With show as
(select UNNEST(STRING_TO_ARRAY(country, ',')) as country, count(*) as total_contents from shows
group by 1
),
rank as (select country,total_contents,
 RANK() over (partition by country order by total_contents desc) as Ranking
from show)
Select country 
from rank
where ranking<=5 and country is not null;
*/

SELECT * 
FROM
(
	SELECT 
		-- country,
		UNNEST(STRING_TO_ARRAY(country, ',')) as country,
		COUNT(*) as total_content
	FROM shows
	GROUP BY 1
)as t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;

-- 5. Identify the longest movie

select type, duration from shows
where type= 'Movie' and duration is not null
order by SPLIT_PART(duration, ' ', 1)::INT DESC
limit 1;


-- 6. Find content added in the last 5 years
Select * from shows
where release_year>=2020;
--or 
SELECT *
FROM shows
WHERE date_added >= CURRENT_DATE - INTERVAL '5 years'

-- -- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
-- Only Rajiv Chilaka
SELECT *
FROM shows 
where director= 'Rajiv Chilaka';

-- or (Rajiv Chakla with others)
SELECT *
FROM
(

SELECT 
	*,
	UNNEST(STRING_TO_ARRAY(director, ',')) as director_name
FROM 
shows
)
WHERE 
	director_name = 'Rajiv Chilaka'

-- 8. List all TV shows with more than 5 seasons

select 
	type, duration 
from shows
where 
	type ='TV Show' and SPLIT_PART(duration,' ',1)::INT > 5 ;

-- 9. Count the number of content items in each genre

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(*) as total_content
FROM shows
GROUP BY 1

-- 10. Find each year and the numbers of content release by India on netflix. 


select release_year, count(*) as Numbers_Of_Contents from shows
where country='India'
group by 1

-- return top 5 year with highest content release !

With CC as
(select release_year, count(*) as Numbers_Of_Contents from shows
where country='India'
group by 1)
Select release_year, Numbers_Of_Contents
from cc 
order by 2 desc
limit 5

-- return top 5 year with highest avg content release
SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/
								(SELECT COUNT(show_id) FROM shows WHERE country = 'India')::numeric * 100 
		,2
		)
		as avg_release
FROM shows
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5

-- 11. List all movies that are documentaries

select * from shows
where listed_in like('Documentaries') and type = 'Movie';

-- 12. Find all content without a director
Select * from shows
where director is null

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT *
FROM shows
WHERE "cast" LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT actor, COUNT(*) AS num_of_movies
FROM (
    SELECT UNNEST(STRING_TO_ARRAY(cast, ',')) AS actor
    FROM shows
    WHERE country = 'India' 
      AND type = 'Movie'
) AS actor_list
GROUP BY actor
ORDER BY num_of_movies DESC;

/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/

  SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM shows
) AS categorized_content
GROUP BY 1,2
ORDER BY 2



