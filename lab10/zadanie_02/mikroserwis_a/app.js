const express = require('express');
const axios = require('axios');
const app = express();
const PORT = 3000;

app.get('/request', async (req, res) => {
    try {
        const response = await axios.get('http://mikroserwis-b:3001/api');
        res.json(response.data);
    } catch (error) {
        res.status(500).json({ error: 'Błąd pobierania danych' });
    };
});

app.listen(PORT, () => console.log(`mikroserwis_a działa na porcie ${PORT}`));
