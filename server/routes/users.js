// In /routes/users.js
const express = require('express');
const pool = require('../db'); // Assuming you have a db connection setup
const router = express.Router();

// Get all users (no ID required)
router.get('/', async (req, res) => {
  try {
    const users = await pool.query('SELECT * FROM users');
    res.json(users.rows); // Send all users in response
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
});

// Get a user by ID (existing endpoint)
router.get('/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const user = await pool.query('SELECT * FROM users WHERE id = $1', [id]);
    if (user.rows.length > 0) {
      res.json(user.rows[0]);
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
});

module.exports = router;
