# Netflix Analytics – SQL Project

A beginner-friendly SQL project to simulate a movie streaming platform and analyze user viewing habits. This project is part of a larger collection of SQL and data analytics projects.

---

## What’s Inside?

We simulate a Netflix-like service using four relational tables:

- `users` – who signed up
- `movies` – available content
- `watch_history` – what each user watched and for how long
- `ratings` – what users thought of the movies

---

## Skills Demonstrated

- SQL schema design
- Writing and running queries using `JOIN`, `GROUP BY`, `HAVING`, `ORDER BY`
- Aggregate functions (`COUNT`, `AVG`, `SUM`)
- Subqueries to filter complex data (e.g., users who rated everything they watched)

---

## How to Run

### Option A: Use SQLite (local)
1. Install SQLite
2. In terminal:
    ```bash
    sqlite3 netflix.db
    .read schema.sql
    .read seed_data.sql
    .read queries.sql
    ```

### Option B: Use an online SQL playground
Try:  
- [https://sqliteonline.com](https://sqliteonline.com)  
- [https://www.db-fiddle.com](https://www.db-fiddle.com)

Just copy/paste the contents of:
- `schema.sql`
- `seed_data.sql`
- Then run queries from `queries.sql`

---

## File Structure

netflix-analytics/ 
├── schema.sql -- CREATE TABLE statements 
├── seed_data.sql -- Sample data (INSERT INTO) 
├── queries.sql -- 7 analytic queries 
└── README.md -- Project overview and instructions

## Future Additions

- Write queries for retention analysis
- Track peak watching hours
- Add support for TV series with episodes
- Create visualizations using Python or Tableau