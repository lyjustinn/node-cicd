const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors())

app.get('/api/double/:number', (req, res, next) => {
    res.json({double: req.params.number*2});
});

app.listen(PORT, () => {
    console.log('Server running');
});