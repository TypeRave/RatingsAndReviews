const pool = require('../postgreSQL/db');

const getReviews = (req, res) => {
  pool.query('SELECT * FROM reviews WHERE id BETWEEN 5000000 AND 5000005', (error, results) => {
    if (error) throw error;
    res.status(200).json(results.rows);
  })
};

module.exports = {
  getReviews,
};