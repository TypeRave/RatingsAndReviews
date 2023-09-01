const csv = require('csv-parser');
const fs = require('fs');
const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.PORT,
  user: proces.env.USERNAME,
  port: process.env.PORT,
  password: process.env.PASSWORD,
  database: process.env.TESTDB,
})

const results = [];

// incomplete, working thru docs:
// https://www.npmjs.com/package/csv-parser
// https://node-postgres.com/apis/pool
// https://node-postgres.com/features/pooling
fs.createReadStream('data.csv')
  .pipe(csv())
  .on('data', (data) => results.push(data))
  .on('end', () => {
    console.log(results);
    // [
    //   { NAME: 'Daffy Duck', AGE: '24' },
    //   { NAME: 'Bugs Bunny', AGE: '22' }
    // ]
  });