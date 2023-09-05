const pool = require('../postgreSQL/db');

const getReviews = (req, res) => {
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
  };

  pool.query(query, (error, results) => {
    if (error) throw error;
    returnObj.results = results.rows;
    returnObj.results.forEach((result) => {
      let photoQuery = `SELECT url FROM reviews_photos WHERE product_id=${id}`
    })
    res.status(200).json(returnObj);
  })
};

const getMetadata = (req, res) => {
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

  pool.query(ratingsQuery)
    .then((result) => returnObj.ratings = result.rows[0])
    .then(() => pool.query(recommendedQuery))
    .then((result) => returnObj.recommended = result.rows[0])
    .then(() => pool.query(characteristicsQuery))
    .then((result) => {
      let charArray = result.rows;
      for (let i = 0; i < charArray.length; i++) {
        let characteristic = charArray[i].characteristic;
        returnObj.characteristics[characteristic] = {
          id: charArray[i].id,
          value: charArray[i].value,
        }
      }
    })
    .then(() => {
      delete returnObj.ratings.product_id;
      delete returnObj.recommended.product_id;
    })
    .then(() => res.status(200).json(returnObj))
    .catch((err) => console.log('Error getting metadata: ', err));
};

const postReview = () => {};

module.exports = {
  getReviews,
  getMetadata,
  postReview,
};