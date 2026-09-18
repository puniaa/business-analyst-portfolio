-- Users Table
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY,
    username TEXT NOT NULL,
    signup_date DATE
);

-- Movies Table
CREATE TABLE movies (
    movie_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    genre TEXT,
    release_year INTEGER
);

-- Watch History Table
CREATE TABLE watch_history (
    watch_id INTEGER PRIMARY KEY,
    user_id INTEGER,
    movie_id INTEGER,
    watch_time INTEGER, -- in minutes
    watch_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);

-- Ratings Table
CREATE TABLE ratings (
    rating_id INTEGER PRIMARY KEY,
    user_id INTEGER,
    movie_id INTEGER,
    rating INTEGER CHECK(rating BETWEEN 1 AND 5),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);
