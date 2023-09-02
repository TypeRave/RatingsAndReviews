const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.PORT,
  user: proces.env.USERNAME,
  port: process.env.PORT,
  password: process.env.PASSWORD,
  database: process.env.DB,
})

module.exports = pool;