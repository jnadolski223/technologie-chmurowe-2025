const express = require('express');
const { MongoClient } = require('mongodb');

const app = express();
const PORT = 8080;
const MONGO_URL = 'mongodb://admin:secret@my-mongo:27017';

async function initializeDatabase() {
    try {
        const client = new MongoClient(MONGO_URL);
        await client.connect();
        const db = client.db('testdb');
        const collection = db.collection('testdata');

        const initialData = [
            { name: 'Anna', surname: 'Nowak' , age: 30 },
            { name: 'Dariusz', surname: 'Januszewski', age: 55 },
            { name: 'Jan', surname: 'Kowalski', age: 18 },
            { name: 'Monika', surname: 'Wiśniewska', age: 36 },
            { name: 'Marek', surname: 'Zegarek', age: 87 }
        ];

        const existingData = await collection.find({}).toArray();
        if (existingData.length === 0) await collection.insertMany(initialData);
        await client.close();
    } catch (error) {
        console.error('Błąd podczas inicjalizacji bazy:', error);
    };
};

app.get('/', async (req, res) => {
    try {
        const client = new MongoClient(MONGO_URL);
        await client.connect();
        const db = client.db('testdb');
        const collection = db.collection('testdata');
        const data = await collection.find({}).toArray();
        await client.close();
        res.json(data);
    } catch (error) {
        res.status(500).json({ error: error.message })
    };
});

initializeDatabase();

app.listen(PORT, () => console.log(`Serwer działa na porcie ${PORT}`));
