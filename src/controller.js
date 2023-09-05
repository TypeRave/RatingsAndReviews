const pool = require('../postgreSQL/db');

const getReviews = async (req, res) => {
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
  res.status(200).json(returnObj);
};

const getMetadata = async (req, res) => {
  let id = req.query.product_id;
  let returnObj = {
    product_id: id,
    ratings: {},
    recommended: {},
    characteristics: {},
  };

  let ratingsQuery = `SELECT * FROM total_ratings WHERE product_id=${id}`;
  let recommendedQuery = `SELECT * FROM total_recommended WHERE product_id=${id}`;
  let characteristicsQuery = `SELECT * FROM avg_characteristics WHERE product_id=${id}`;

  const ratingsResults = await pool.query(ratingsQuery);
  returnObj.ratings = ratingsResults.rows[0];
  delete returnObj.ratings.product_id;

  const recommendResults = await pool.query(recommendedQuery);
  returnObj.recommended = recommendResults.rows[0];
  delete returnObj.recommended.product_id;

  ///ADD BACK IN KEYS
  const characteristicResults = await pool.query(characteristicsQuery);
  characteristicResults.rows.forEach((char) => {
    returnObj.characteristics[char.characteristic] = {
      id: char.id,
      value: char.value
    }
  })

  res.status(200).json(returnObj);
};

const postReview = (req, res) => {
  let post = req.body;
  let date = new Date().toISOString();

  let insertPost = `INSERT INTO reviews (product_id, rating, created_at, summary, body, recommend, reviewer_name, reviewer_email)
  VALUES(${post.product_id}, ${post.rating}, ${date}, ${post.summary}, ${post.body}, ${post.recommend}, ${post.name}, ${post.email}) RETURNING id;`

  let reviewID = 0;
  pool.query(insertPost)
  .then((result) => {
    reviewID = result;
    post.photos.forEach((photo) => {
      pool.query(`INSERT INTO reviews_photos (review_id, photo_url) VALUES (${reviewID}, ${photo})`)
    })
  })
  .then(() => {
    for (let key in post.characteristics) {
      pool.query(`INSERT INTO characteristics_reviews (characteristic_id, review_id, characteristic_value) VALUES (${key}, ${reviewID}, ${post.characteristics[key]})`)
    }
  })
  .then(() => res.sendStatus(201))
  .catch(() => res.send('Error posting review'));
};

const markHelpful = () => {};
const report = () => {};

module.exports = {
  getReviews,
  getMetadata,
  postReview,
  markHelpful,
  report,
};