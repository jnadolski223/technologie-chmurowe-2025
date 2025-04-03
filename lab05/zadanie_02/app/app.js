const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
    res.send('Hi! This is basic Express.js app!');
});

app.listen(port, () => {
    console.log(`App listening on port ${port}`);
});
