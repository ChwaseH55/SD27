// In /routes/users.js
const express = require('express');
const pool = require('../db'); // Assuming you have a db connection setup
const multer = require('multer');
const { getStorage } = require('firebase-admin/storage');
const router = express.Router();

const storage = multer.memoryStorage();
const upload = multer({ storage });

// Get all users (no ID required)
router.get('/', async (req, res) => {
  try {
    const users = await pool.query('SELECT id, username, firstname, lastname, email, roleid, profilepicture FROM users');
    res.json(users.rows); // Send all users in response
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
});

// Get user info
router.get('/:id', async (req, res) => {
    const { id } = req.params;

    try {
        const user = await pool.query(
            "SELECT id, username, firstname, lastname, email, roleid, profilepicture FROM users WHERE id = $1",
            [id]
        );

        // Check if the user exists
        if (user.rows.length === 0) {
            return res.status(404).json({ error: "User not found" });
        }

        res.json(user.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).send(err.message);
    }
});

// Update profile picture
router.put('/:id/profile-picture', upload.single('profilePicture'), async (req, res) => {
    const { id } = req.params;
    
    if (!req.file) {
        return res.status(400).json({ error: "No file uploaded" });
    }

    try {
        // Upload to Firebase Storage
        const bucket = getStorage().bucket();
        const fileName = `profile_pictures/${id}/${req.file.originalname}`;
        const file = bucket.file(fileName);
        
        await file.save(req.file.buffer, {
            metadata: {
                contentType: req.file.mimetype
            }
        });

        // Get the public URL
        const publicUrl = `https://storage.googleapis.com/${bucket.name}/${fileName}`;

        // Update the user's profile picture URL in the database
        const updateResult = await pool.query(
            "UPDATE users SET profilepicture = $1 WHERE id = $2 RETURNING id, username, firstname, lastname, email, roleid, profilepicture",
            [publicUrl, id]
        );

        if (updateResult.rows.length === 0) {
            return res.status(404).json({ error: "User not found" });
        }

        res.json({
            message: "Profile picture updated successfully",
            user: updateResult.rows[0]
        });
    } catch (err) {
        console.error(err);
        res.status(500).send(err.message);
    }
});

//update user info
router.put('/:id', async (req, res) => {
    const { id } = req.params;
    const { username, firstname, lastname, roleid } = req.body;

    try {
        const updateQuery = `
            UPDATE users
            SET
                username = COALESCE($1, username),
                firstname = COALESCE($2, firstname),
                lastname = COALESCE($3, lastname),
                roleid = COALESCE($4, roleid)
            WHERE id = $5
            RETURNING id, username, firstname, lastname, email, roleid, profilepicture;`;

        const updateResult = await pool.query(updateQuery, [
            username || null,
            firstname || null,
            lastname || null,
            roleid || null,
            id
        ]);

        if (updateResult.rows.length === 0) {
            return res.status(404).json({ error: "User not found" });
        }

        res.json({
            message: "User information updated successfully.",
            user: updateResult.rows[0],
        });
    } catch (err) {
        res.status(500).send(err.message);
    }
})

module.exports = router;
