const express = require('express');
require('dotenv').config();
const router = require('./src/routes.js');

const {PORT} = process.env;
const app = express();


app.get('/', (req, res) => res.send('Express server running'));
//maybe need diff here
app.use('/reviews', router);

app.listen(PORT, () => console.log(`Server is listening at http://localhost:${PORT}`));