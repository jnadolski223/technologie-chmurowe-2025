const express = require('express');
const mysql = require('mysql');

const db = mysql.createConnection({
    host: 'db',
    user: 'root',
    password: 'admin',
    database: 'users_database'
});

db.connect((err) => {
    if (err) {
        console.error('Failed to connect to database', err.message)
        return;
    };
    console.log('Connected to database!');
});

const app = express();
const PORT = 8080;

app.get('/', (req, res) => {
    const query = 'SELECT * FROM users';
    db.query(query, (err, results) => {
        if (err) {
            console.error('Error downloading data:', err);
            res.status(500).send('Server error');
            return;
        }
        res.send(results);
    });
})

app.listen(PORT, () => console.log(`App listening on port ${PORT}`));
