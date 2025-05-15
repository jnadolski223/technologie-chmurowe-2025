const express = require('express');
const mongoose = require('mongoose');
const app = express();
const PORT = 3001;

const mongoHost = process.env.MONGO_HOST;
const mongoPort = process.env.MONGO_PORT;
const mongoUsername = process.env.MONGO_USERNAME;
const mongoPassword = process.env.MONGO_PASSWORD;

mongoose.connect(`mongodb://${mongoUsername}:${mongoPassword}@${mongoHost}:${mongoPort}/local?authSource=admin`)
                .then(async () => {
                    console.log('Połaczono z bazą danych Mongo!');

                    const count = await User.countDocuments();
                    if (count === 0) {
                        await User.create([
                            { name: "Jan", last_name: "Kowalski" },
                            { name: "Anna", last_name: "Nowak" },
                            { name: "Dariusz", last_name: "Januszewski" }
                        ]);
                        console.log('Dodano przykładowe dane do bazy danych');
                    };
                })
                .catch(err => console.error('Błąd połączenia z bazą danych Mongo', err));

const User = mongoose.model('User', new mongoose.Schema({
    name: String,
    last_name: String
}));

app.get('/api', async (req, res) => {
    try {
        const users = await User.find();
        res.status(200).json(users);
    } catch (err) {
        res.status(500).json({ error: 'Błąd pobierania danych' });
    };
});

app.listen(PORT, () => console.log(`mikroserwis_b działa na porcie ${PORT}`));
