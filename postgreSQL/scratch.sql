CREATE SCHEMA ratings_reviews;

CREATE TABLE reviews (
  id serial PRIMARY KEY,
  product_id integer NOT NULL,
  rating integer NOT NULL,
  date timestamp NOT NULL DEFAULT now(),
  summary text NOT NULL,
  recommended boolean,
  response text NOT  NULL,
  body text NOT NULL,
  reviewer_name text NOT NULL,
  helpfulness integer DEFAULT 0,
  photos boolean DEFAULT FALSE,
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
  review_id integer NOT NOT NULL,
  url text,
  FOREIGN KEY (review_id) REFERENCES reviews (id)
);

-- I think a view might be better here
CREATE TABLE product_metadata (
  id serial PRIMARY KEY,
  product_id integer NOT NULL,
  rating_1 integer NULL,
  rating_2 integer NULL,
  rating_3 integer NULL,
  rating_4 integer NULL,
  rating_5 integer NULL,
  recommended_true integer NULL,
  recommended_false integer NULL,
  fit decimal NULL,
  length decimal NULL,
  width decimal NULL,
  comfort decimal NULL,
  quality decimal NULL,
  size decimal NULL,
  PRIMARY KEY (product_id)
);
