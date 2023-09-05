\c postgres

DROP DATABASE ratingsreviews;

CREATE DATABASE ratingsreviews;

\c ratingsreviews

CREATE TABLE temp_reviews (
  id bigserial PRIMARY KEY,
  product_id integer NOT NULL,
  rating integer NOT NULL,
  unix_date bigint NOT NULL,
  summary varchar(200) NOT NULL,
  body varchar(1000) NOT NULL,
  recommend boolean,
  reported boolean DEFAULT false,
  reviewer_name varchar(60) NOT NULL,
  reviewer_email varchar(60) NOT NULL,
  response varchar(1000),
  helpfulness integer DEFAULT 0
);

CREATE TABLE reviews (
  id bigserial PRIMARY KEY,
  product_id integer NOT NULL,
  rating integer NOT NULL,
  created_at varchar(28) NOT NULL,
  summary varchar(200) NOT NULL,
  body varchar(1000) NOT NULL,
  recommend boolean,
  reported boolean DEFAULT false,
  reviewer_name varchar(60) NOT NULL,
  reviewer_email varchar(60) NOT NULL,
  response varchar(1000),
  helpfulness integer DEFAULT 0
);
CREATE INDEX ON reviews (product_id);
--CREATE INDEX ON reviews (rating);

CREATE TABLE review_photos (
  id bigserial PRIMARY KEY,
  review_id integer NOT NULL,
  photo_url varchar(255),
  FOREIGN KEY (review_id) REFERENCES reviews (id)
);
CREATE INDEX on review_photos (review_id);

-- updated "name" to "characteristic"
CREATE TABLE characteristics (
  id bigserial PRIMARY KEY,
  product_id integer NOT NULL,
  characteristic varchar(7) NOT NULL
);
CREATE INDEX ON characteristics (product_id);

CREATE TABLE characteristics_reviews (
  id bigserial PRIMARY KEY,
  characteristic_id integer NOT NULL,
  review_id integer NOT NULL,
  characteristic_value integer NOT NULL,
  FOREIGN KEY (characteristic_id) REFERENCES characteristics (id),
  FOREIGN KEY (review_id) REFERENCES reviews (id)
);
CREATE INDEX on characteristics_reviews (characteristic_id);

--temp table to convert unix date to iso8691
COPY temp_reviews
FROM '/Users/Lauren/Hack_Reactor/SDC/RatingsAndReviews/raw_data/reviews.csv'
DELIMITER ','
CSV HEADER;

--add new column converting date
ALTER TABLE temp_reviews
ADD COLUMN iso_date text;
UPDATE temp_reviews
SET iso_date = TO_CHAR(TO_TIMESTAMP(unix_date/1000)::timestamp with time zone AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"');

--copy table over with correct timestamp dates
INSERT INTO reviews (id, product_id, rating, created_at, summary, body, recommend, reported, reviewer_name, reviewer_email, response, helpfulness)
SELECT id, product_id, rating, iso_date, summary, body, recommend, reported, reviewer_name, reviewer_email, response, helpfulness
FROM temp_reviews;

--copy remaining table data
COPY review_photos
FROM '/Users/Lauren/Hack_Reactor/SDC/RatingsAndReviews/raw_data/reviews_photos.csv'
DELIMITER ','
CSV HEADER;

COPY characteristics
FROM '/Users/Lauren/Hack_Reactor/SDC/RatingsAndReviews/raw_data/characteristics.csv'
DELIMITER ','
CSV HEADER;

COPY characteristics_reviews
FROM '/Users/Lauren/Hack_Reactor/SDC/RatingsAndReviews/raw_data/characteristic_reviews.csv'
DELIMITER ','
CSV HEADER;

DROP TABLE temp_reviews;

--create views for metadata
CREATE OR REPLACE VIEW total_ratings AS
  SELECT
    product_id,
    SUM(
      CASE WHEN rating = 1 THEN 1 ELSE 0 END
    ) AS "1",
    SUM(
      CASE WHEN rating = 2 THEN 1 ELSE 0 END
    ) AS "2",
    SUM(
      CASE WHEN rating = 3 THEN 1 ELSE 0 END
    ) AS "3",
    SUM(
      CASE WHEN rating = 4 THEN 1 ELSE 0 END
    ) AS "4",
    SUM(
      CASE WHEN rating = 5 THEN 1 ELSE 0 END
    ) AS "5"
  FROM
    reviews
  GROUP BY product_id;

CREATE OR REPLACE VIEW total_recommended AS
  SELECT
    product_id,
    SUM(
      CASE WHEN recommend THEN 1 ELSE 0 END
    ) AS "true",
    SUM(
      CASE WHEN recommend THEN 0 ELSE 1 END
    ) AS "false"
  FROM
    reviews
  GROUP BY product_id;

CREATE OR REPLACE VIEW avg_characteristics AS
  SELECT
    product_id,
    characteristic,
    characteristic_id AS id,
    AVG(characteristic_value) AS "value"
  FROM
    characteristics_reviews cr
  JOIN
    characteristics c ON c.id = cr.characteristic_id
  GROUP BY product_id, characteristic_id, characteristic;

SELECT pg_catalog.setval(pg_get_serial_sequence('reviews', 'id'), (SELECT MAX(id) FROM reviews) + 1);
SELECT pg_catalog.setval(pg_get_serial_sequence('review_photos', 'id'), (SELECT MAX(id) FROM review_photos) + 1);
SELECT pg_catalog.setval(pg_get_serial_sequence('characteristics', 'id'), (SELECT MAX(id) FROM characteristics) + 1);
SELECT pg_catalog.setval(pg_get_serial_sequence('characteristics_reviews', 'id'), (SELECT MAX(id) FROM characteristics_reviews) + 1);

