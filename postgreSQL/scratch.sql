
-- postgres commands: https://www.postgresqltutorial.com/postgresql-cheat-sheet/

\c postgres

DROP DATABASE test_ratingsreviews;


CREATE DATABASE test_ratingsreviews;

\c test_ratingsreviews

CREATE TABLE temp_reviews (
  id bigserial PRIMARY KEY,
  product_id integer NOT NULL,
  rating integer NOT NULL,
  unix_date bigint NOT NULL,
  summary varchar(100) NOT NULL,
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
  summary varchar(100) NOT NULL,
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

--TEST UPLOAD:
COPY temp_reviews
FROM '/Users/Lauren/Hack_Reactor/SDC/RatingsAndReviews/raw_data/test_revs.csv'
DELIMITER ','
CSV HEADER;

--add new column converting date
ALTER TABLE temp_reviews
ADD COLUMN iso_date text;
UPDATE temp_reviews
SET iso_date = TO_CHAR(TO_TIMESTAMP(unix_date/1000)::timestamp with time zone AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"');
--SET iso_date = TO_CHAR(DATE(unix_date), 'YYYY-MM-DD');

--copy table over with correct timestamp dates
INSERT INTO reviews (id, product_id, rating, created_at, summary, body, recommend, reported, reviewer_name, reviewer_email, response, helpfulness)
SELECT id, product_id, rating, iso_date, summary, body, recommend, reported, reviewer_name, reviewer_email, response, helpfulness
FROM temp_reviews;

COPY review_photos
FROM '/Users/Lauren/Hack_Reactor/SDC/RatingsAndReviews/raw_data/test_revs_photos.csv'
DELIMITER ','
CSV HEADER;

COPY characteristics
FROM '/Users/Lauren/Hack_Reactor/SDC/RatingsAndReviews/raw_data/test_chars.csv'
DELIMITER ','
CSV HEADER;

COPY characteristics_reviews
FROM '/Users/Lauren/Hack_Reactor/SDC/RatingsAndReviews/raw_data/test_chars_revs.csv'
DELIMITER ','
CSV HEADER;






--QUERIES

EXPLAIN ANALYZE SELECT * FROM reviews WHERE product_id=900000;
EXPLAIN ANALYZE SELECT * FROM total_ratings WHERE product_id=900000;
EXPLAIN ANALYZE SELECT * FROM total_recommended WHERE product_id=900000;
EXPLAIN ANALYZE SELECT * FROM avg_characteristics WHERE product_id=900000;






----LATER OPTIMIZATION----
-- I am going to map characteristics to a small table of keys 1-6 for each characteristic
-- CREATE TABLE characteristics (
--   id serial PRIMARY KEY,
--   -- updated "name" to "characteristic"
--   characteristic text NOT NULL UNIQUE
-- );
-- -- Then the text values in the "names" column in characteristics.csv can be reduced to a single int 1-6
-- CREATE TABLE products_characteristics (
--   id serial PRIMARY KEY,
--   product_id integer NOT NULL,
--   characteristic_id integer NOT NULL,
--   FOREIGN KEY (characteristic_id) REFERENCES characteristics (id)
-- );
-- -- characteristic IDs will need to be converted to their new char_ID (current ID -> text -> new ID)
-- CREATE TABLE characteristics_reviews (
--   id serial PRIMARY KEY,
--   review_id integer NOT NULL,
--   characteristic_id integer NOT NULL,
--   "value" integer NOT NULL,
--   FOREIGN KEY (characteristic_id) REFERENCES characteristics (id),
--   FOREIGN KEY (review_id) REFERENCES reviews (id)
-- );

-- my original reviews table
--I might want to index date so I can return newest?
  --check if quotes are needed for existing keywords date and length
    --added boolean to photos, if photos submitted, switch to true. this might save on checking the review_photos table if no photos exist, but it may also add extra bulk where none is needed. Will experiment!

--CREATE TABLE reviews (
--   id serial PRIMARY KEY,
--   product_id integer NOT NULL,
--   rating integer NOT NULL,
--   date timestamp NOT NULL DEFAULT now(),
--   summary varchar(60) NOT NULL,
--   recommended boolean,
--   response varchar(1000) NOT NULL,
--   body varchar(1000) NOT NULL,
--   reviewer_name varchar(60) NOT NULL,
--   reviewer_email varchar(60) NOT NULL,
--   helpfulness integer DEFAULT 0,
--   photos boolean DEFAULT FALSE,
--   fit integer NULL,
--   length integer NULL,
--   comfort integer NULL,
--   quality integer NULL,
--   size integer NULL,
--   width integer NULL,
--   reported boolean DEFAULT FALSE
-- );


------------------------------------
------------QUERIES-----------------
------------------------------------
--These are the queries I'll need if I'm getting metadata on demand:
-- A standalone query for ratings, since this is used in multiple places by the related products
-------Ratings-----------
--count all reviews by product ID, by rating. return in the following shape:
--ratings: {"1": int, "2": int, "3": int...}
-- Queries for all other metadata, only used by the ratings & reviews section:
------Recommended---------
--count all reviews by recommended true/false. return in the following shape:
--recommended: {"true": int, "false": int}]
----Characteristics------
--get all characteristic names by product
--average all reviews by each characteristic, then convert to a string (IDK why the Atelier API did this). return in the following shape:
--characteristics: {"Fit": {"value": text}, "Comfort": {"value": text}...}
--*note: I removed "id" from the value object since IDs have been updated to an int 1-6. I could add it back if the frontend needs it ({value: text, id: int}). Ideally I'd like to just remove the value object altogether, but the frontend needs "value" and I'm not going to change it for now.
-----------------------------

--------------------------------------
-- Another route I could take would be to calculate the totals up front, load them into a table, and increment them each time a new review is added. This would work as long as this was ALWAYS done concurrently, but may throw the totals off-sync if there was ever an interruption between posting the review and adding to the counter. A similar option would be to calculate new totals every regular time period (eg. once a day, hourly, etc)

-- Here's how an aggregated metadata/view *could* look, consolidating characteristics into their text values and a true/false whether they have the characteristic- this would require some heavy lifting up front to fit data, but would eliminate the need for an entire separate characteristics_reviews.
-- Again, reviews are split out because it is used in multiple places in the related products section. However, it might make sense to just include it in metadata if it's being incrememnted in the same batch as the other data when a review is posted
---------------------------------------
--
-- CREATE TABLE product_metadata (
--   id serial PRIMARY KEY,
--   product_id integer NOT NULL UNIQUE,
--   recommended_true integer NULL,      --sum total of all true ratings for prod_id recommended
--   recommended_false integer NULL,     --sum total of all false ""  ""
--   fit_exists boolean NULL,            --check if fit id exists in the products characteristics table exists
--   fit_avg text NULL, --if yes,        --if true, avg (sum/count) of all fit ratings, cut off at X decimals, converted to string
--   length_exists boolean NULL,         --same as above for all characteristics
--   length_avg text NULL,
--   width_exists boolean NULL,
--   width_avg text NULL,
--   comfort_exists boolean NULL,
--   comfort_avg text NULL,
--   quality_exists boolean NULL,
--   quality_avg text NULL,
--   size_exists boolean NULL,
--   size_avg text NULL,
--   PRIMARY KEY (product_id)
-- );

-- CREATE TABLE ratings (
--   id serial PRIMARY KEY,
--   product_id integer NOT NULL UNIQUE,
--   1 integer NULL,                     --sum total of all 1* ratings for prod_id
--   2 integer NULL,
--   3 integer NULL,
--   4 integer NULL,
--   5 integer NULL,
-- );
