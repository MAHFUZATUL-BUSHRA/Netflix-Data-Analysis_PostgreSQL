# Netflix Content Analysis

This project analyzes Netflix content using SQL queries. The goal is to extract insights about movies and TV shows, including trends, popular genres, top actors, and other interesting patterns. Below is a summary of the tasks performed and their SQL implementations.

## Features

### 1. **Count the Total Number of Movies and TV Shows**
```sql
SELECT type, COUNT(*)
FROM shows
GROUP BY 1;
```

### 2. **Find the Most Common Ratings for Movies and TV Shows**
```sql
WITH counting AS (
    SELECT
        type,
        rating,
        COUNT(*) AS Total_Num
    FROM shows
    GROUP BY type, rating
),
rankRating AS (
    SELECT
        type,
        rating,
        Total_Num,
        RANK() OVER (PARTITION BY type ORDER BY Total_Num DESC) AS rankings
    FROM counting
)
SELECT
    type,
    rating,
    Total_Num
FROM rankRating
WHERE rankings = 1;
```

### 3. **List All Movies Released in a Specific Year**
```sql
SELECT title AS Movie_Names, release_year
FROM shows
WHERE release_year = 2020 AND type = 'Movie';
```

### 4. **Find the Top 5 Countries with the Most Content on Netflix**
```sql
SELECT *
FROM (
    SELECT
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM shows
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;
```

### 5. **Identify the Longest Movie**
```sql
SELECT type, duration
FROM shows
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC
LIMIT 1;
```

### 6. **Find Content Added in the Last 5 Years**
```sql
SELECT *
FROM shows
WHERE release_year >= 2020;
```

### 7. **Find All Movies/TV Shows Directed by 'Rajiv Chilaka'**
```sql
SELECT *
FROM shows
WHERE director = 'Rajiv Chilaka';
```

### 8. **List All TV Shows with More Than 5 Seasons**
```sql
SELECT
    type, duration
FROM shows
WHERE
    type = 'TV Show' AND SPLIT_PART(duration, ' ', 1)::INT > 5;
```

### 9. **Count the Number of Content Items in Each Genre**
```sql
SELECT
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM shows
GROUP BY 1;
```

### 10. **Find Each Year and the Number of Content Released by India on Netflix**
```sql
WITH CC AS (
    SELECT release_year, COUNT(*) AS Numbers_Of_Contents
    FROM shows
    WHERE country = 'India'
    GROUP BY 1
)
SELECT release_year, Numbers_Of_Contents
FROM CC
ORDER BY Numbers_Of_Contents DESC
LIMIT 5;
```

### 11. **List All Movies That Are Documentaries**
```sql
SELECT *
FROM shows
WHERE listed_in LIKE ('Documentaries') AND type = 'Movie';
```

### 12. **Find All Content Without a Director**
```sql
SELECT *
FROM shows
WHERE director IS NULL;
```

### 13. **Find How Many Movies Actor 'Salman Khan' Appeared In Over the Last 10 Years**
```sql
SELECT *
FROM shows
WHERE "cast" LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

### 14. **Find the Top 10 Actors Who Appeared in the Most Movies Produced in India**
```sql
SELECT actor, COUNT(*) AS num_of_movies
FROM (
    SELECT UNNEST(STRING_TO_ARRAY("cast", ',')) AS actor
    FROM shows
    WHERE country = 'India'
      AND type = 'Movie'
) AS actor_list
GROUP BY actor
ORDER BY num_of_movies DESC;
```

### 15. **Categorize Content Based on Keywords in Descriptions**
```sql
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
GROUP BY 1, 2
ORDER BY 2;
```


## Tools Used
- SQL (PostgreSQL syntax, adaptable to MySQL, Snowflake, or other databases).



