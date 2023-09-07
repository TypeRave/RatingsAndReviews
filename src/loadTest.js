const { Router } = require('express');
const controller = require('./controller');

const loadTest = Router();

loadTest.get('/', controller.verify);


module.exports = loadTest;