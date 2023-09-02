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
  response varchar(1000) NOT NULL,
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
  response varchar(1000) NOT NULL,
  helpfulness integer DEFAULT 0
);

CREATE TABLE review_photos (
  id bigserial PRIMARY KEY,
  review_id integer NOT NULL,
  photo_url varchar(255),
  FOREIGN KEY (review_id) REFERENCES reviews (id)
);

-- updated "name" to "characteristic"
CREATE TABLE characteristics (
  id bigserial PRIMARY KEY,
  product_id integer NOT NULL,
  characteristic varchar(7) NOT NULL
);

CREATE TABLE characteristics_reviews (
  id bigserial PRIMARY KEY,
  characteristic_id integer NOT NULL,
  review_id integer NOT NULL,
  characteristic_value integer NOT NULL,
  FOREIGN KEY (characteristic_id) REFERENCES characteristics (id),
  FOREIGN KEY (review_id) REFERENCES reviews (id)
);

--temp table:
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
