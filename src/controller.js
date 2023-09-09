const pool = require('../postgreSQL/db');
const fs = require('fs');
require('dotenv').config();
const { addToReviewCache, getFromReviewCache, addToMetaCache, getFromMetaCache } = require('../cache.js');

const getReviews = async (req, res) => {
  const request = JSON.stringify(req.query);
  const cachedData = getFromReviewCache(request);
  if (cachedData) {
    res.status(200).json(cachedData);
  } else {
    let id = req.query.product_id;
    let count = req.query?.count || 5;
    let page = req.query?.page || 1;
    let sort = req.query?.sort || 'relevant';

    if (sort === 'helpful') { sort = 'helpfulness DESC'; }
    if (sort === 'newest') { sort = 'created_at DESC'; }
    if (sort === 'relevant') { sort = 'helpfulness DESC, created_at DESC'; }
    let offset = count * (page - 1);

    let query = `SELECT * FROM reviews WHERE product_id=(${id}) AND reported=false ORDER BY ${sort} LIMIT ${count} OFFSET ${offset};`;
    let returnObj = {
      product: id,
      page: parseInt(page),
      count: parseInt(count),
      results: [],
    };

    const reviewResults = await pool.query(query);
    for (const review of reviewResults.rows) {
      let photoQuery = `SELECT * FROM review_photos WHERE review_id=${review.id};`;
      const photoResults = await pool.query(photoQuery);
      const photos = photoResults.rows.map(photo => photo.photo_url);
      returnObj.results.push({
        ...review,
        photos,
      })
    }
    addToReviewCache(request, returnObj);
    res.status(200).json(returnObj);
  }
};

const getMetadata = async (req, res) => {
  const request = JSON.stringify(req.query);
  const cachedData = getFromMetaCache(request);

  if (cachedData) {
    res.status(200).json(cachedData);
  } else {
    let id = req.query.product_id;
    let returnObj = {
      product_id: id,
      ratings: {},
      recommended: {},
      characteristics: {},
    };

    let ratingsQuery = `SELECT "1", "2", "3", "4", "5" FROM total_ratings WHERE product_id=${id};`;
    let recommendedQuery = `SELECT "true", "false" FROM total_recommended WHERE product_id=${id};`;
    let characteristicsQuery = `SELECT * FROM avg_characteristics WHERE product_id=${id};`;

    const ratingsResults = await pool.query(ratingsQuery);
    returnObj.ratings = ratingsResults.rows[0];

    const recommendResults = await pool.query(recommendedQuery);
    returnObj.recommended = recommendResults.rows[0];

    const characteristicResults = await pool.query(characteristicsQuery);
    characteristicResults.rows.forEach((char) => {
      returnObj.characteristics[char.characteristic] = {
        id: char.id,
        value: char.value
      }
    })
    addToMetaCache(request, returnObj);
    res.status(200).json(returnObj);
  }
};

const postReview = async (req, res) => {
  const post = req.body;
  const date = new Date().toISOString();

  const values = [
    post.product_id,
    post.rating,
    date,
    post.summary,
    post.body,
    post.recommend,
    post.name,
    post.email
  ];

  const  insertPost = `INSERT INTO reviews (product_id, rating, created_at, summary, body, recommend, reviewer_name, reviewer_email)
  VALUES($1, $2, $3, $4, $5, $6, $7, $8) RETURNING id;`
  const reviewPostResults = await pool.query(insertPost, values);
  const reviewID = reviewPostResults.rows[0].id;

  for (let i = 0; i < post.photos.length; i++) {
    const photoVals = [
      reviewID,
      post.photos[i]
    ];
    const insertPhotos = `INSERT INTO review_photos (review_id, photo_url) VALUES ($1, $2);`;
    await pool.query(insertPhotos, photoVals);
  }

  for (let key in post.characteristics) {
    const chars = [
      key,
      reviewID,
      post.characteristics[key]
    ];
    const insertChars = `INSERT INTO characteristics_reviews (characteristic_id, review_id, characteristic_value) VALUES ($1, $2, $3);`;
    await pool.query(insertChars, chars);
  }
  res.sendStatus(201);
};

const verify = (req, res) => {
  const body = fs.readFileSync(process.env.LOADERFILE);
          res.send(body);
  };

// const markHelpful = () => {};
// const report = () => {};

module.exports = {
  getReviews,
  getMetadata,
  postReview,
  // markHelpful,
  // report,
  verify
};