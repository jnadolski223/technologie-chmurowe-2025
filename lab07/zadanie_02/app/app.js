const express = require('express');
const mongoose = require('mongoose');

const app = express();
const PORT = 3003;
const MONGO_PORT = 27017;

mongoose.connect(`mongodb://db:${MONGO_PORT}/local`)
                .then(() => console.log('Connected to Mongo Database!'))
                .catch(err => console.error('Error connecting to Mongo Database', err));

const User = mongoose.model('User', new mongoose.Schema({
    name: String,
    last_name: String
}));

app.get('/users', async (req, res) => {
    try {
        const users = await User.find();
        res.status(200).json(users);
    } catch (err) {
        res.status(500).send('Server error');
    };
});

app.listen(PORT, () => console.log(`App listening on port ${PORT}`));
