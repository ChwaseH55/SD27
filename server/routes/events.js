const express = require('express');
const pool = require('../db');
const router = express.Router();

//Create new event (Create)
router.post('/', async(req, res) => {
    const {event_name, event_date, event_location, event_type, requires_registration, created_by_user_id, event_description} = req.body;

    try{
        const newEvent = await pool.query(
            `INSERT INTO events (eventname, eventdate, eventlocation, eventtype, requiresregistration, createdbyuserid, eventdescription) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`, [event_name, event_date, event_location, event_type, requires_registration, created_by_user_id, event_description] 
        );
        res.json(newEvent.rows[0]);
    }catch(err){
        console.error(err.message);
        res.status(500).send("Server error");
    }

});

//Get all events (Read)
router.get('/', async(req, res) => {
    try{
        const allEvents = await pool.query("SELECT * FROM events");
        res.json(allEvents.rows);
    }catch (err){
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

// Get a single event by ID (Read)
router.get('/:id', async (req, res) => {
    const { id } = req.params;

    try {
        const event = await pool.query("SELECT * FROM events WHERE eventid = $1", [id]);
        if (event.rows.length === 0) {
            return res.status(404).json({ message: "Event not found" });
        }
        res.json(event.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

// Update an event (Update)
router.put('/:id', async (req, res) => {
    const { id } = req.params;
    const { event_name, event_description, event_date, event_location } = req.body;

    try {
        const updatedEvent = await pool.query(
            `UPDATE events
             SET eventname = $1, eventdescription = $2, eventdate = $3, eventlocation = $4
             WHERE eventid = $5 RETURNING *`,
            [event_name, event_description, event_date, event_location, id]
        );

        if (updatedEvent.rows.length === 0) {
            return res.status(404).json({ message: "Event not found" });
        }

        res.json(updatedEvent.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

// Delete an event (Delete)
router.delete('/:id', async (req, res) => {
    const { id } = req.params;

    try {
        const deletedEvent = await pool.query("DELETE FROM events WHERE eventid = $1 RETURNING *", [id]);
        if (deletedEvent.rows.length === 0) {
            return res.status(404).json({ message: "Event not found" });
        }
        res.json({ message: "Event deleted successfully" });
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

module.exports = router;