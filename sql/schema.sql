-- ============================================================================
-- Project:     Photo Catalog Relational Analytics
-- File:        sql/schema.sql
-- Description: DDL schema definition and DML seed data population.
--              Implements 3NF design with M:N relationships.
-- ============================================================================

-- 1. Очистка таблиц (в обратном порядке зависимостей внешних ключей)
DROP TABLE IF EXISTS photo_author;
DROP TABLE IF EXISTS photo_genre;
DROP TABLE IF EXISTS photo;
DROP TABLE IF EXISTS author;
DROP TABLE IF EXISTS genre;

-- ============================================================================
-- 2. Создание структуры таблиц (DDL)
-- ============================================================================

-- Справочник жанров
CREATE TABLE genre (
    id_genre INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(45) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Справочник авторов / фотографов
CREATE TABLE author (
    id_author INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(45) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Сущность фотографии
CREATE TABLE photo (
    id_photo INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(45) NOT NULL,
    date DATE NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Связующая таблица M:N: Фотографии <-> Жанры
CREATE TABLE photo_genre (
    id_photo INT NOT NULL,
    id_genre INT NOT NULL,
    PRIMARY KEY (id_photo, id_genre),
    CONSTRAINT fk_photo_genre_photo FOREIGN KEY (id_photo)
        REFERENCES photo(id_photo) ON DELETE CASCADE,
    CONSTRAINT fk_photo_genre_genre FOREIGN KEY (id_genre)
        REFERENCES genre(id_genre) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Связующая таблица M:N: Фотографии <-> Авторы
CREATE TABLE photo_author (
    id_photo INT NOT NULL,
    id_author INT NOT NULL,
    PRIMARY KEY (id_photo, id_author),
    CONSTRAINT fk_photo_author_photo FOREIGN KEY (id_photo)
        REFERENCES photo(id_photo) ON DELETE CASCADE,
    CONSTRAINT fk_photo_author_author FOREIGN KEY (id_author)
        REFERENCES author(id_author) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- 3. Наполнение тестовыми данными (DML Seed Data)
-- ============================================================================

INSERT INTO genre (id_genre, name) VALUES
(1, 'genre1'), (2, 'genre2'), (3, 'genre3'), (4, 'genre4'), (5, 'genre5'),
(6, 'genre6'), (7, 'genre7'), (8, 'genre8'), (9, 'genre9'), (10, 'genre10');

INSERT INTO author (id_author, name) VALUES
(1, 'author1'), (2, 'author2'), (3, 'author3'), (4, 'author4'), (5, 'author5'),
(6, 'author6'), (7, 'author7'), (8, 'author8'), (9, 'author9'), (10, 'author10');

INSERT INTO photo (id_photo, name, date) VALUES
(1,  'photo1',  '2020-10-09'),
(2,  'photo2',  '2020-10-20'),
(3,  'photo3',  '2015-10-30'),
(4,  'photo4',  '2016-07-03'),
(5,  'photo5',  '2015-03-07'),
(6,  'photo6',  '2001-01-15'),
(7,  'photo7',  '2022-05-05'),
(8,  'photo8',  '2017-10-29'),
(9,  'photo9',  '2020-11-02'),
(10, 'photo10', '2009-09-09'),
(11, 'photo11', '2009-10-10');

-- Ассоциации фотографий с жанрами
INSERT INTO photo_genre (id_photo, id_genre) VALUES
(1, 1), (6, 1), (10, 1), (11, 1),
(1, 2), (2, 2),
(1, 3), (7, 3),
(4, 4),
(4, 5), (9, 5),
(3, 6),
(10, 7),
(5, 8), (6, 8),
(5, 9),
(3, 10), (5, 10), (6, 10), (8, 10);

-- Ассоциации фотографий с авторами (коллаборации)
INSERT INTO photo_author (id_photo, id_author) VALUES
(1, 1), (5, 1), (11, 1),
(1, 2), (11, 2),
(2, 3), (3, 3),
(3, 4),
(4, 5),
(6, 6),
(5, 7), (7, 7),
(7, 8), (9, 8),
(4, 9), (8, 9),
(5, 10), (8, 10), (10, 10);
