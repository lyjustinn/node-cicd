const express = require('express');
const cors = require('cors');

const double = require('./util/double');
const triple = require('./util/triple');

const app = express();

app.use(cors())

app.get('/api/double/:number', (req, res, next) => {
    res.json(double(req.params.number));
});

app.get('/api/triple/:number', (req, res, next) => {
    res.json(triple(req.params.number));
});

app.get('/api/ping', (req, res, next) => {
    res.json({ping : "pong"});
});

module.exports = app;