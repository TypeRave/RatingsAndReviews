CREATE SCHEMA ratings_reviews;

CREATE TABLE reviews (
  id serial PRIMARY KEY,
  product_id integer NOT NULL,
  rating integer NOT NULL,
  date timestamp NOT NULL DEFAULT now(), --I might want to index this so I can return newest?
  --^check if quotes are needed for existing keywords
  summary varchar(60) NOT NULL,
  recommended boolean,
  response varchar(1000) NOT NULL,
  body varchar(1000) NOT NULL,
  reviewer_name varchar(60) NOT NULL,
  reviewer_email varchar(60) NOT NULL,
  helpfulness integer DEFAULT 0,
  photos boolean DEFAULT FALSE,
  --^added boolean, if photos submitted, switch to true. this might save on checking the review_photos table if no photos exist, but it may also add extra bulk where none is needed. Will experiment!
  fit integer NOT NULL,
  length integer NOT NULL,
  comfort integer NOT NULL,
  quality integer NOT NULL,
  size integer NOT NULL,
  width integer NOT NULL,
  reported boolean DEFAULT FALSE,
);

CREATE TABLE review_photos (
  id serial PRIMARY KEY,
  review_id integer NOT NULL,
  url varchar(255),
  FOREIGN KEY (review_id) REFERENCES reviews (id)
);

-- I am going to map characteristics to a small table of keys 1-6 for each characteristic
CREATE TABLE characteristics (
  id serial PRIMARY KEY,
  -- updated "name" to "characteristic"
  characteristic text NOT NULL UNIQUE
);
-- Then the text values in the "names" column in characteristics.csv can be reduced to a single int 1-6
CREATE TABLE products_characteristics (
  id serial PRIMARY KEY,
  product_id integer NOT NULL,
  characteristic_id integer NOT NULL,
  FOREIGN KEY (characteristic_id) REFERENCES characteristics (id)
);
-- characteristic IDs will need to be converted to their new char_ID (current ID -> text -> new ID)
CREATE TABLE characteristics_reviews (
  id serial PRIMARY KEY,
  review_id integer NOT NULL,
  characteristic_id integer NOT NULL,
  "value" integer NOT NULL,
  FOREIGN KEY (characteristic_id) REFERENCES characteristics (id),
  FOREIGN KEY (review_id) REFERENCES reviews (id)
);

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
