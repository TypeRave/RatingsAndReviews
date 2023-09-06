const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.HOST,
  user: process.env.USERNAME,
  port: process.env.DBPORT,
  password: process.env.PASSWORD,
  database: process.env.DB,
})

module.exports = pool;