/* eslint-disable linebreak-style */
/* eslint-disable camelcase */
/* eslint-disable max-len */
/* eslint-disable new-cap */
// server/routes/auth.js
const express = require("express");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const pool = require("../db"); // Adjust the path as needed
const router = express.Router();


router.post("/register", async (req, res) => {
  console.log("Received registration request with:", req.body);

  // Check if the pool is connected
  try {
    await pool.query("SELECT NOW()"); // Test the database connection
    console.log("Database connection is successful.");
  } catch (err) {
    console.error("Database connection error:", err.message);
    return res.status(500).send("Database connection error");
  }

  const {username, email, password, firstName, lastName} = req.body;

  // Validation
  if (!username || !email || !password || !firstName || !lastName) {
    return res.status(400).json({message: "All fields (username, email, password, firstName, lastName) are required"});
  }

  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    console.log("Password hashed successfully");

    const newUser = await pool.query(
        `INSERT INTO users (username, email, password, FirstName, LastName, RoleID, PaymentStatus)
             VALUES ($1, $2, $3, $4, $5, (SELECT RoleID FROM roles WHERE RoleName = 'member'), FALSE)
             RETURNING *`,
        [username, email, hashedPassword, firstName, lastName],
    );

    console.log("User inserted into the database:", newUser.rows[0]);
    res.json(newUser.rows[0]);
  } catch (err) {
    console.error("Error during registration:", err.message); // More specific logging
    res.status(500).send("Server error");
  }
});


// Login
router.post("/login", async (req, res) => {
  const {username, password} = req.body;

  try {
    const user = await pool.query("SELECT * FROM users WHERE username = $1", [username]);

    if (user.rows.length > 0) {
      const isMatch = await bcrypt.compare(password, user.rows[0].password);
      if (isMatch) {
        const token = jwt.sign(
            {id: user.rows[0].id, role: user.rows[0].roleid, paymentStatus: user.rows[0].paymentstatus},
            "your_jwt_secret",
            {expiresIn: "1h"},
        );
        res.json({
          token,
          user: {
            id: user.rows[0].id,
            username: user.rows[0].username,
            email: user.rows[0].email,
            firstName: user.rows[0].firstname,
            lastName: user.rows[0].lastname,
            role: user.rows[0].roleid,
            paymentStatus: user.rows[0].paymentstatus,
          },
        });
      } else {
        res.status(400).send("Invalid credentials");
      }
    } else {
      res.status(400).send("User not found");
    }
  } catch (err) {
    console.error(err);
    res.status(500).send("Server error");
  }
});

module.exports = router;
