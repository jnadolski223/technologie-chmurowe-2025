const express = require('express');
const { createClient } = require('redis');

const redisClient = createClient({ url: 'redis://redis:6379' });
redisClient.connect().catch(error => console.log("Error connecting to Redis:", error));

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

app.listen(PORT, () => console.log(`App is running on port ${PORT}`));

app.on('close', async () => await redisClient.quit());
