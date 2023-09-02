const express = require('express');
require('dotenv').config();

const app = express();
const {PORT} = process.env;

app.get('/', (req, res) => res.send('Express server running'));

app.listen(PORT, () => console.log(`Server is listening on port ${PORT}`));