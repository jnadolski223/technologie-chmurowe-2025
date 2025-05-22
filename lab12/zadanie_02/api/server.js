const express = require('express');
const app = express();
const PORT = 3000;

app.get('/', (req, res) => res.send(`API server works on ${process.arch} architecture.`));

app.listen(PORT, () => console.log(`Server listening on port ${PORT}`));
