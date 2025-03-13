const express = require('express');
const app = express();
const PORT = 8080;

app.get('/', (req, res) => {
    const now = new Date();
    const currentDate = now.toLocaleDateString();
    const currentTime = now.toLocaleTimeString();
    res.json({ currentDate, currentTime });
});

app.listen(PORT, () => console.log(`Serwer działa na porcie ${PORT}`));
