"""
==============================================================================
Project:     Photo Catalog Relational Analytics
File:        main.py
Author:      Yevhen Biezhyn
Description: Automated CLI runner and query demonstrator. Initializes an
             in-memory relational database (SQLite/MySQL compatible),
             seeds entities with M:N relationships, and executes complex
             analytical queries with formatted console output.
==============================================================================
"""

import sqlite3
from typing import List, Tuple, Any


SCHEMA_SQL = """
-- 1. Tables Creation
CREATE TABLE genre (
    id_genre INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE author (
    id_author INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE photo (
    id_photo INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    date TEXT NOT NULL
);

CREATE TABLE photo_genre (
    id_photo INTEGER NOT NULL,
    id_genre INTEGER NOT NULL,
    PRIMARY KEY (id_photo, id_genre),
    FOREIGN KEY (id_photo) REFERENCES photo(id_photo),
    FOREIGN KEY (id_genre) REFERENCES genre(id_genre)
);

CREATE TABLE photo_author (
    id_photo INTEGER NOT NULL,
    id_author INTEGER NOT NULL,
    PRIMARY KEY (id_photo, id_author),
    FOREIGN KEY (id_photo) REFERENCES photo(id_photo),
    FOREIGN KEY (id_author) REFERENCES author(id_author)
);

-- 2. Seed Data
INSERT INTO genre (id_genre, name) VALUES 
(1, 'genre1'), (2, 'genre2'), (3, 'genre3'), (4, 'genre4'), (5, 'genre5'),
(6, 'genre6'), (7, 'genre7'), (8, 'genre8'), (9, 'genre9'), (10, 'genre10');

INSERT INTO author (id_author, name) VALUES 
(1, 'author1'), (2, 'author2'), (3, 'author3'), (4, 'author4'), (5, 'author5'),
(6, 'author6'), (7, 'author7'), (8, 'author8'), (9, 'author9'), (10, 'author10');

INSERT INTO photo (id_photo, name, date) VALUES 
(1, 'photo1', '2020-10-09'), (2, 'photo2', '2020-10-20'), (3, 'photo3', '2015-10-30'),
(4, 'photo4', '2016-07-03'), (5, 'photo5', '2015-03-07'), (6, 'photo6', '2001-01-15'),
(7, 'photo7', '2022-05-05'), (8, 'photo8', '2017-10-29'), (9, 'photo9', '2020-11-02'),
(10, 'photo10', '2009-09-09'), (11, 'photo11', '2009-10-10');

INSERT INTO photo_genre (id_photo, id_genre) VALUES 
(1,1), (6,1), (10,1), (11,1), (1,2), (2,2), (1,3), (7,3), (4,4), (4,5),
(9,5), (3,6), (10,7), (5,8), (6,8), (5,9), (3,10), (5,10), (6,10), (8,10);

INSERT INTO photo_author (id_photo, id_author) VALUES 
(1,1), (5,1), (11,1), (1,2), (11,2), (2,3), (3,3), (3,4), (4,5),
(6,6), (5,7), (7,7), (7,8), (9,8), (4,9), (8,9), (5,10), (8,10), (10,10);
"""

QUERIES = [
    (
        "Query 1: Earliest & Latest Date for Multi-Author Collaborations",
        """
        SELECT MIN(p.date) AS min_date, MAX(p.date) AS max_date
        FROM photo p
        WHERE p.id_photo IN (
            SELECT pa.id_photo
            FROM photo_author pa
            GROUP BY pa.id_photo
            HAVING COUNT(pa.id_author) > 1
        );
        """
    ),
    (
        "Query 2: Popular Genres per Release Year (Genre frequency > 1)",
        """
        SELECT g.name AS genre_name, 
               COUNT(strftime('%Y', p.date)) AS cnt_genre, 
               strftime('%Y', p.date) AS photo_year
        FROM photo p
        JOIN photo_genre pg ON p.id_photo = pg.id_photo
        JOIN genre g ON pg.id_genre = g.id_genre
        GROUP BY photo_year, g.name
        HAVING COUNT(strftime('%Y', p.date)) > 1
        ORDER BY photo_year DESC;
        """
    ),
    (
        "Query 3: Comprehensive Modern Catalog Projection (Photos after 2010)",
        """
        SELECT p.name AS photo_name, a.name AS author_name, g.name AS genre_name, p.date
        FROM photo p
        JOIN photo_author pa ON p.id_photo = pa.id_photo
        JOIN author a ON pa.id_author = a.id_author
        JOIN photo_genre pg ON pg.id_photo = p.id_photo
        JOIN genre g ON g.id_genre = pg.id_genre
        WHERE p.date > '2010-01-01'
        ORDER BY p.date DESC, a.name ASC;
        """
    ),
    (
        "Query 4: Photos Associated with the Rarest Genres (Minimum Frequency)",
        """
        SELECT DISTINCT p.name AS photo_name, p.date, g.name AS genre_name
        FROM photo p
        JOIN photo_genre pg ON pg.id_photo = p.id_photo
        JOIN genre g ON g.id_genre = pg.id_genre
        WHERE pg.id_genre IN (
            SELECT id_genre
            FROM photo_genre
            GROUP BY id_genre
            HAVING COUNT(id_photo) = (
                SELECT MIN(genre_count)
                FROM (
                    SELECT COUNT(id_photo) AS genre_count
                    FROM photo_genre
                    GROUP BY id_genre
                )
            )
        )
        ORDER BY p.date DESC;
        """
    ),
    (
        "Query 5: Photos Released Prior to author1's Latest Work Year",
        """
        SELECT DISTINCT p.name AS photo_name, p.date
        FROM photo p
        WHERE strftime('%Y', p.date) < (
            SELECT MAX(strftime('%Y', p2.date))
            FROM photo p2
            JOIN photo_author pa ON p2.id_photo = pa.id_photo
            JOIN author a ON pa.id_author = a.id_author
            WHERE a.name = 'author1'
        )
        ORDER BY p.date DESC;
        """
    )
]


def print_table(headers: List[str], rows: List[Tuple[Any, ...]]) -> None:
    """Formats and prints query results as an ASCII table."""
    col_widths = [len(h) for h in headers]
    for row in rows:
        for idx, val in enumerate(row):
            col_widths[idx] = max(col_widths[idx], len(str(val)))

    sep = "+-" + "-+-".join("-" * w for w in col_widths) + "-+"
    print(sep)
    header_str = "| " + " | ".join(f"{h:<{w}}" for h, w in zip(headers, col_widths)) + " |"
    print(header_str)
    print(sep)
    for row in rows:
        row_str = "| " + " | ".join(f"{str(val):<{w}}" for val, w in zip(row, col_widths)) + " |"
        print(row_str)
    print(sep)


def main():
    print("=" * 75)
    print("  PHOTO CATALOG RELATIONAL ANALYTICS ENGINE")
    print("===========================================================================")
    print("[*] Initializing in-memory relational SQLite engine...")
    conn = sqlite3.connect(":memory:")
    cursor = conn.cursor()

    print("[*] Creating 3NF schema and populating Seed Data...")
    cursor.executescript(SCHEMA_SQL)
    print("[+] Database initialized successfully.")

    for title, query in QUERIES:
        print("\n" + "=" * 75)
        print(f"  {title.upper()}")
        print("=" * 75)
        cursor.execute(query)
        rows = cursor.fetchall()
        headers = [desc[0] for desc in cursor.description]
        print_table(headers, rows)

    conn.close()
    print("\n" + "=" * 75)
    print("  ALL ANALYTICAL QUERIES EXECUTED SUCCESSFULLY.")
    print("=" * 75)


if __name__ == "__main__":
    main()
