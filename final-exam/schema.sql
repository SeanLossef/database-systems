DROP SCHEMA IF EXISTS testing CASCADE;
CREATE SCHEMA testing;

CREATE TABLE Artist
(
    artistId  INTEGER PRIMARY KEY,
    name      VARCHAR(127),
    birthdate Date
);

CREATE TABLE Album
(
    albumId   INTEGER PRIMARY KEY,
    artistId  INTEGER REFERENCES Artist,
    title     VARCHAR(127),
    year      INTEGER,
    publisher VARCHAR(127)
);

CREATE TABLE Song
(
    title       VARCHAR(255),
    trackNumber INTEGER,
    albumId     INTEGER REFERENCES Album,
    length      INTEGER,
    genre       VARCHAR(255),
    composer    VARCHAR(255),
    PRIMARY KEY (title, albumId)
);

CREATE TABLE Inventory
(
    albumId       INTEGER REFERENCES Album,
    numberInStock INTEGER,
    price         FLOAT,
    upc           INT UNIQUE
);

CREATE TABLE sale
(
    albumId       INTEGER REFERENCES Album,
    quantity      INTEGER,
    totalSale     NUMERIC(10, 2),
    saleDate      TIMESTAMP
);

CREATE TABLE wholesale_order
(
    orderId       SERIAL PRIMARY KEY,
    cost          NUMERIC(12, 2),
    orderDate     TIMESTAMP
);

CREATE TABLE Streaming
(
    songTitle VARCHAR(255),
    albumId   INTEGER,
    provider  VARCHAR(255),
    url       VARCHAR(512),
    FOREIGN KEY (songTitle, albumId) REFERENCES Song (title, albumID)
);