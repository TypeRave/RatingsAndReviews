const pool = require('../postgreSQL/db');

const getReviews = (req, res) => {
  let id = req.query.product_id;
  let count = req.query?.count || 5; //check if ? are needed
  let page = req.query?.page || 1;
  let sort = req.query?.sort || 'relevant';
  if (sort === 'helpful') { sort = 'helpfulness DESC'; }
  if (sort === 'newest') { sort = 'created_at DESC'; }
  if (sort === 'relevant') { sort = 'helpfulness DESC, created_at DESC'; }

  let offset = count * (page - 1);

  let query = `SELECT * FROM reviews WHERE product_id=(${id}) ORDER BY ${sort} LIMIT ${count} OFFSET ${offset};`;

  console.log(req.query);
  pool.query(query, (error, results) => {
    if (error) throw error;
    res.status(200).json(results.rows);
  })
};

module.exports = {
  getReviews,
};