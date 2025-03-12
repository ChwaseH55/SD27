/* eslint-disable linebreak-style */
/* eslint-disable camelcase */
/* eslint-disable max-len */
/* eslint-disable new-cap */
const express = require("express");
const pool = require("../db");
const router = express.Router();

// Create new event (Create)
router.post("/", async (req, res) => {
  const {event_name, event_date, event_location, event_type, requires_registration, created_by_user_id, event_description} = req.body;

  try {
    const newEvent = await pool.query(
        `INSERT INTO events (eventname, eventdate, eventlocation, eventtype, requiresregistration, createdbyuserid, eventdescription) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`, [event_name, event_date, event_location, event_type, requires_registration, created_by_user_id, event_description],
    );
    res.json(newEvent.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

// Get all events (Read)
router.get("/", async (req, res) => {
  try {
    const allEvents = await pool.query("SELECT * FROM events");
    res.json(allEvents.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

// Get a single event by ID (Read)
router.get("/:id", async (req, res) => {
  const {id} = req.params;

  try {
    const event = await pool.query("SELECT * FROM events WHERE eventid = $1", [id]);
    if (event.rows.length === 0) {
      return res.status(404).json({message: "Event not found"});
    }
    res.json(event.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

// Update an event (Update)
router.put("/:id", async (req, res) => {
  const {id} = req.params;
  const {event_name, event_description, event_date, event_location} = req.body;

  try {
    const updatedEvent = await pool.query(
        `UPDATE events
             SET eventname = $1, eventdescription = $2, eventdate = $3, eventlocation = $4
             WHERE eventid = $5 RETURNING *`,
        [event_name, event_description, event_date, event_location, id],
    );

    if (updatedEvent.rows.length === 0) {
      return res.status(404).json({message: "Event not found"});
    }

    res.json(updatedEvent.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

// Delete an event (Delete)
router.delete("/:id", async (req, res) => {
  const {id} = req.params;

  try {
    const deletedEvent = await pool.query("DELETE FROM events WHERE eventid = $1 RETURNING *", [id]);
    if (deletedEvent.rows.length === 0) {
      return res.status(404).json({message: "Event not found"});
    }
    res.json({message: "Event deleted successfully"});
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

// register for an event
router.post("/register", async (req, res) => {
  const {eventid, userid} = req.body;

  try {
    const exisitingRegistration = await pool.query(" SELECT * FROM event_registration WHERE eventid = $1 AND userid = $2", [eventid, userid]);

    if (exisitingRegistration.rows.length > 0) {
      return res.status(400).json({message: "User already registered"});
    }

    await pool.query("INSERT INTO event_registration (eventid, userid) VALUES ($1, $2)", [eventid, userid]);

    res.json({message: "registration successful"});
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

// unregister from an event
router.delete("/unregister/:eventid/:userid", async (req, res) => {
  const {eventid, userid} = req.params;
  console.log(eventid, userid);

  try {
    const result = await pool.query("DELETE FROM event_registration WHERE eventid = $1 AND userid = $2 RETURNING *", [eventid, userid]);

    if (result.rows.length === 0) {
      return res.status(404).json({message: "Registration not found"});
    }

    res.json({message: "Unregistered successfully"});
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

// Get all events a user is registered for
router.get("/my-events/:userid", async (req, res) => {
  const {userid} = req.params;

  try {
    const registeredEvents = await pool.query(
        `SELECT e.* FROM events e 
           JOIN event_registration er ON e.eventid = er.eventid 
           WHERE er.userid = $1`,
        [userid],
    );

    res.json(registeredEvents.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

// Check if user is registered for an event
router.get("/is-registered/:eventid/:userid", async (req, res) => {
  const {eventid, userid} = req.params;

  try {
    const result = await pool.query(
        "SELECT * FROM event_registration WHERE eventid = $1 AND userid = $2",
        [eventid, userid],
    );

    res.json({registered: result.rows.length > 0});
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

module.exports = router;
