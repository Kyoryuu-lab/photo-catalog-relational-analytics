-- ============================================================================
-- Project:     Photo Catalog Relational Analytics
-- File:        sql/queries.sql
-- Description: Advanced analytical SQL queries demonstrating multi-table JOINs,
--              aggregate filters (HAVING), temporal extraction, and subqueries.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Запрос 1: Диапазон дат (MIN / MAX) для совместных работ (коллабораций)
-- Описание: Находит самую раннюю и самую позднюю дату съемки для фотографий,
--           над которыми работало более одного автора одновременно.
-- ----------------------------------------------------------------------------
SELECT
    MIN(p.date) AS min_collaboration_date,
    MAX(p.date) AS max_collaboration_date
FROM photo p
WHERE p.id_photo IN (
    SELECT pa.id_photo
    FROM photo_author pa
    GROUP BY pa.id_photo
    HAVING COUNT(pa.id_author) > 1
);


-- ----------------------------------------------------------------------------
-- Запрос 2: Полная проекция каталога для современных фотографий (после 2010 года)
-- Описание: Выполняет объединение 5 таблиц для формирования детального каталога
--           с указанием названия фото, автора, жанра и даты съемки.
-- ----------------------------------------------------------------------------
SELECT
    p.name AS photo_name,
    a.name AS author_name,
    g.name AS genre_name,
    p.date AS release_date
FROM photo p
JOIN photo_author pa ON p.id_photo = pa.id_photo
JOIN author a        ON pa.id_author = a.id_author
JOIN photo_genre pg  ON p.id_photo = pg.id_photo
JOIN genre g         ON pg.id_genre = g.id_genre
WHERE p.date > '2010-01-01'
ORDER BY p.date DESC, a.name ASC;


-- ----------------------------------------------------------------------------
-- Запрос 3: Популярные жанры по годам выпуска (Частота жанра в году > 1)
-- Описание: Извлекает год из даты, группирует работы по жанрам и годам,
--           оставляя только жанры, представленные в конкретном году неоднократно.
-- ----------------------------------------------------------------------------
SELECT
    g.name AS genre_name,
    COUNT(EXTRACT(YEAR FROM p.date)) AS cnt_genre,
    EXTRACT(YEAR FROM p.date) AS photo_year
FROM photo p
JOIN photo_genre pg ON p.id_photo = pg.id_photo
JOIN genre g        ON pg.id_genre = g.id_genre
GROUP BY photo_year, g.name
HAVING COUNT(EXTRACT(YEAR FROM p.date)) > 1
ORDER BY photo_year DESC;


-- ----------------------------------------------------------------------------
-- Запрос 4: Фотографии, опубликованные строго до последнего года работы 'author1'
-- Описание: Коррелированный подзапрос. Находит максимальный год активности
--           автора 'author1' и фильтрует фотографии, снятые ранее этого года.
-- ----------------------------------------------------------------------------
SELECT
    p.name AS photo_name,
    p.date AS photo_date,
    a.name AS author_name
FROM photo p
JOIN photo_author pa ON p.id_photo = pa.id_photo
JOIN author a        ON a.id_author = pa.id_author
WHERE EXTRACT(YEAR FROM p.date) < (
    SELECT MAX(EXTRACT(YEAR FROM p2.date))
    FROM photo p2
    JOIN photo_author pa2 ON p2.id_photo = pa2.id_photo
    JOIN author a2        ON a2.id_author = pa2.id_author
    WHERE a2.name = 'author1'
)
GROUP BY p.name, a.name, p.date
ORDER BY p.date DESC;


-- ----------------------------------------------------------------------------
-- Запрос 5: Фотографии, относящиеся к самым редким жанрам каталога
-- Описание: Двойной вложенный подзапрос с динамическим расчетом минимума (MIN).
--           Определяет минимальное число ассоциаций среди всех жанров и выбирает
--           фотографии, которые содержат хотя бы один из этих редких жанров.
-- ----------------------------------------------------------------------------
SELECT
    p.name AS photo_name,
    p.date AS photo_date,
    g.name AS genre_name,
    a.name AS author_name
FROM photo p
JOIN photo_author pa ON pa.id_photo = p.id_photo
JOIN author a        ON a.id_author = pa.id_author
JOIN photo_genre pg  ON pg.id_photo = p.id_photo
JOIN genre g         ON g.id_genre = pg.id_genre
WHERE p.id_photo IN (
    SELECT pg_sub.id_photo
    FROM photo_genre pg_sub
    GROUP BY pg_sub.id_genre, pg_sub.id_photo
    HAVING pg_sub.id_genre IN (
        SELECT stats.id_genre
        FROM (
            SELECT id_genre, COUNT(id_photo) AS cnt
            FROM photo_genre
            GROUP BY id_genre
        ) stats
        WHERE stats.cnt = (
            SELECT MIN(min_calc.cnt)
            FROM (
                SELECT COUNT(id_photo) AS cnt
                FROM photo_genre
                GROUP BY id_genre
            ) min_calc
        )
    )
)
ORDER BY EXTRACT(YEAR FROM p.date) DESC, p.name ASC;
