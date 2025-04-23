const express = require('express');
const { createClient } = require('redis');
const { Pool } = require('pg');

const redisClient = createClient({ url: 'redis://redis:6379' });
redisClient.connect().catch(error => console.log("Error connecting to Redis:", error));

const pool = new Pool({
    user: 'user',
    host: 'postgres',
    database: 'mydb',
    password: 'password',
    port: 5432
});

const app = express();
app.use(express.json());
const PORT = 3000;

app.post('/messages', async (req, res) => {
    const { message } = req.body;
    if (!message) return res.status(400).json({ error: 'Message is required' });
    await redisClient.rPush("messages", message);
    res.status(201).json({ success: 'Message added to database' });
});

app.get('/messages', async (req, res) => {
    const messages = await redisClient.lRange("messages", 0, -1);
    res.status(200).json({ messages });
});

app.post('/users', async (req, res) => {
    const { name } = req.body;
    if (!name) return res.status(400).json({ error: 'Name is required' });
    const result = await pool.query('INSERT INTO users (name) VALUES ($1) RETURNING *', [name]);
    res.status(201).send(result.rows[0]);
});

app.listen(PORT, () => console.log(`Server is running on port ${PORT}`));

app.on('close', async () => {
    await pool.end();
    await redisClient.quit();
});
