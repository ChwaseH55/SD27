/* eslint-disable linebreak-style */
/* eslint-disable new-cap */
/* eslint-disable linebreak-style */
// server/routes/users.js
const express = require("express");
const pool = require("../db");
const router = express.Router();

// Example user endpoint
router.get("/:id", async (req, res) => {
  const {id} = req.params;

  try {
    const user = await pool.query("SELECT * FROM users WHERE id = $1", [id]);
    res.json(user.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).send("Server error");
  }
});

module.exports = router;
