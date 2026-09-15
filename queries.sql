-- 1. Top 5 Most Watched Movies
SELECT m.title, COUNT(w.movie_id) AS view_count
FROM watch_history w
JOIN movies m ON w.movie_id = m.movie_id
GROUP BY w.movie_id
ORDER BY view_count DESC
LIMIT 5;

-- 2. Average Watch Time per User
SELECT u.username, ROUND(AVG(w.watch_time), 2) AS avg_watch_time
FROM watch_history w
JOIN users u ON w.user_id = u.user_id
GROUP BY u.user_id;

-- 3. Users Who Watched More Than 200 Minutes Total
SELECT u.username, SUM(w.watch_time) AS total_watch_time
FROM watch_history w
JOIN users u ON w.user_id = u.user_id
GROUP BY u.user_id
HAVING total_watch_time > 200;

-- 4. Most Watched Genres
SELECT m.genre, COUNT(w.movie_id) AS views
FROM watch_history w
JOIN movies m ON w.movie_id = m.movie_id
GROUP BY m.genre
ORDER BY views DESC;

-- 5. Average Rating Per Movie
SELECT m.title, ROUND(AVG(r.rating), 2) AS avg_rating
FROM ratings r
JOIN movies m ON r.movie_id = m.movie_id
GROUP BY r.movie_id
ORDER BY avg_rating DESC;

-- 6. Users Who Rated All Movies They Watched
SELECT u.username
FROM users u
WHERE NOT EXISTS (
    SELECT 1
    FROM watch_history w
    WHERE w.user_id = u.user_id
    AND NOT EXISTS (
        SELECT 1
        FROM ratings r
        WHERE r.user_id = w.user_id AND r.movie_id = w.movie_id
    )
);

-- 7. Watch Counts By Release Year
SELECT m.release_year, COUNT(w.movie_id) AS watch_count
FROM watch_history w
JOIN movies m ON w.movie_id = m.movie_id
GROUP BY m.release_year
ORDER BY m.release_year;
