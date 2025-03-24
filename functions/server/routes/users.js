// In /routes/users.js
const express = require('express');
const pool = require('../db'); // Assuming you have a db connection setup
const router = express.Router();
const multer = require('multer');
const path = require('path');
const admin = require('../../firebaseAdmin'); 

// Set up Multer to store file in memory
const storage = multer.memoryStorage();
const upload = multer({ storage });


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

// Get user info
router.get('/:id', async (req, res) => {
    const { id } = req.params;

    try {
        const user = await pool.query("SELECT * FROM users WHERE id = $1", [id]);

        // Check if the user exists
        if (result.rows.length === 0) {
            return res.status(404).json({ error: "User not found" });
        }

        res.json(user.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).send(err.message);
    }
});

//update user info
router.put('/:id', upload.single('profilepicture'), async (req, res) => {
    const { id } = req.params;
    const { username, firstname, lastname } = req.body;
    const file = req.file;

    console.log("Uploaded file:", req.file);

    try {
        let profilePictureUrl = null;

        if (file) {
            const bucket = admin.storage().bucket();
            const fileExtension = path.extname(file.originalname);
            const fileName = `profile_pictures/${id}/${Date.now()}${fileExtension}`;
            const firebaseFile = bucket.file(fileName);

            await firebaseFile.save(file.buffer, {
                metadata: {
                    contentType: file.mimetype,
                },
                public: true, 
            });

            profilePictureUrl = `https://storage.googleapis.com/${bucket.name}/${firebaseFile.name}`;
        }

        const updateQuery = `
          UPDATE users
          SET
            username = COALESCE($1, username),
            firstname = COALESCE($2, firstname),
            lastname = COALESCE($3, lastname),
            profilepicture = COALESCE($4, profilepicture)
          WHERE id = $5
          RETURNING *;
        `;

        const updateResult = await pool.query(updateQuery, [
            username || null,
            firstname || null,
            lastname || null,
            profilePictureUrl || null,
            id
        ]);

        res.json({
            message: "User information updated successfully.",
            user: updateResult.rows[0],
        });

    } catch (err) {
        console.error(err);
        res.status(500).send(err.message);
    }
});

module.exports = router;
