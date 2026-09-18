-- Users
INSERT INTO users VALUES
(1, 'alex99', '2022-01-10'),
(2, 'jess_xo', '2022-02-05'),
(3, 'dev123', '2022-03-18');

-- Movies
INSERT INTO movies VALUES
(1, 'The Matrix', 'Sci-Fi', 1999),
(2, 'Inception', 'Sci-Fi', 2010),
(3, 'The Notebook', 'Romance', 2004),
(4, 'Interstellar', 'Sci-Fi', 2014),
(5, 'Mean Girls', 'Comedy', 2004);

-- Watch History
INSERT INTO watch_history VALUES
(1, 1, 1, 120, '2023-01-01'),
(2, 1, 2, 148, '2023-01-05'),
(3, 2, 3, 124, '2023-01-08'),
(4, 2, 1, 120, '2023-01-09'),
(5, 3, 4, 169, '2023-01-10'),
(6, 3, 1, 120, '2023-01-12');

-- Ratings
INSERT INTO ratings VALUES
(1, 1, 1, 5),
(2, 1, 2, 4),
(3, 2, 3, 3),
(4, 2, 1, 4),
(5, 3, 4, 5),
(6, 3, 1, 5);
