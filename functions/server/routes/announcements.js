const express = require('express');
const pool = require('../db'); // Ensure your PostgreSQL pool connection is set up
const router = express.Router();

// Create an announcement
router.post('/', async (req, res) => {
    const { title, content, userid } = req.body;
    try {
        const newAnnouncement = await pool.query(
            `INSERT INTO announcements (title, content, userid, createddate) VALUES ($1, $2, $3, NOW()) RETURNING *`,
            [title, content, userid]
        );
        res.status(201).json(newAnnouncement.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

// Get all announcements
router.get('/', async (req, res) => {
    try {
        const announcements = await pool.query("SELECT * FROM announcements ORDER BY createddate DESC");
        res.json(announcements.rows);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

// Get a single announcement
router.get('/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const announcement = await pool.query(
            `SELECT * FROM announcements WHERE announcementid = $1`,
            [id]
        );
        if (announcement.rows.length === 0) {
            return res.status(404).json({ message: "Announcement not found" });
        }
        res.json(announcement.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

// Update an announcement
router.put('/:id', async (req, res) => {
    const { id } = req.params;
    const { title, content } = req.body;
    try {
        const updatedAnnouncement = await pool.query(
            `UPDATE announcements SET title = $1, content = $2 WHERE announcementid = $3 RETURNING *`,
            [title, content, id]
        );
        if (updatedAnnouncement.rows.length === 0) {
            return res.status(404).json({ message: "Announcement not found" });
        }
        res.json(updatedAnnouncement.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

// Delete an announcement
router.delete('/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const deletedAnnouncement = await pool.query(
            `DELETE FROM announcements WHERE announcementid = $1 RETURNING *`,
            [id]
        );
        if (deletedAnnouncement.rows.length === 0) {
            return res.status(404).json({ message: "Announcement not found" });
        }
        res.json({ message: "Announcement deleted successfully" });
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

module.exports = router;