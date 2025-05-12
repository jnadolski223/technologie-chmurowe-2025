const express = require('express');
const app = express();
const PORT = 3001;

app.get(`/api`, (req, res) => {
    res.json({ message: 'Wiadomość z mikroserwis_b!' });
});

app.listen(PORT, () => console.log(`mikroserwis_b działa na porcie ${PORT}`));
