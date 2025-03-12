/* eslint-disable linebreak-style */
/* eslint-disable max-len */
/* eslint-disable linebreak-style */
/* eslint-disable new-cap */
/* eslint-disable linebreak-style */

const express = require("express");
const multer = require("multer");
const pool = require("../db");
const router = express.Router();

const storage = multer.memoryStorage();
const upload = multer({storage});
// create score
/*
    This api allows player to include multiple player in the score
*/
router.post("/scores", upload.single("scoreimage"), async (req, res) =>{
  const {eventid, userids} = req.body; // userids should be an array of user IDS or a string with userids seperated by commas
  const scoreimage = req.file ? req.file.buffer : null; // get the image file as binary data


  if (!eventid || !userids || !scoreimage) {
    return res.status(400).json({message: "Missing required fields: eventid, userids, or scoreimage"});
  }

  try {
    const userIdArray = Array.isArray(userids) ? userids : userids.split(",");

    // Inserting a score for each userid that is submitted
    const insertedScores = [];
    for (const userid of userIdArray) {
      try {
        const newScore = await pool.query(
            "INSERT INTO score_submissions (eventid, userid, scoreimage, approvalstatus) VALUES ($1, $2, $3, $4) RETURNING *",
            [eventid, userid, scoreimage, "Pending"],
        );
        insertedScores.push(newScore.rows[0]);
      } catch (err) {
        console.error(`Error inserting score for userid=${userid}:`, err.message);
      }
    }
    res.json({
      message: "Scores successfully submitted for all users.",
      scores: insertedScores,
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

// update a score (once it has been approved you cannot update the score.)
router.put("/scores/:scoreid", async (req, res) => {
  const {scoreid} = req.params;
  const {eventid, scoreimage} = req.body;

  try {
    const checkResult = await pool.query(
        "SELECT approvalstatus FROM score_submissions WHERE scoreid = $1",
        [scoreid],
    );

    if (checkResult.rows.length === 0) {
      return res.status(404).json({message: "Score not found"});
    }

    const approvalStatus = checkResult.rows[0].approvalstatus;

    // If the score is approved, return a 403 error
    if (approvalStatus === "Approved") {
      return res.status(403).json({message: "Cannot update an approved score."});
    }


    const updateQuery = `
            UPDATE score_submissions
            SET 
                eventid = COALESCE($1, eventid),
                scoreimage = COALESCE($2, scoreimage)
            WHERE scoreid = $3
            RETURNING *;
        `;

    const updateResult = await pool.query(updateQuery, [
      eventid || null,
      scoreimage || null,
      scoreid,
    ]);

    res.json({
      message: "Score updated successfully.",
      score: updateResult.rows[0],
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

// approve score :)
router.put("/scores/approve", async (req, res) => {
  const {scoreid} = req.body;
  try {
    const updatedScore = await pool.query(`UPDATE score_submissions SET approvalstatus = 'Approved' WHERE scoreid = $1 RETURNING *`, [scoreid]);

    if ( updatedScore.rows.length === 0) {
      return res.status(404).json({message: "Score not found"});
    }

    res.json(updatedScore.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

// not approve score :)
router.put("/scores/not-approve", async (req, res) => {
  const {scoreid} = req.body;
  try {
    const updatedScore = await pool.query(`UPDATE score_submissions SET approvalstatus = 'Not Approved' WHERE scoreid = $1 RETURNING *`, [scoreid]);

    if ( updatedScore.rows.length === 0) {
      return res.status(404).json({message: "Score not found"});
    }

    res.json(updatedScore.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

// Get all scores (approved, pending and non-approved)
router.get("/scores", async (req, res) => {
  try {
    const scores = await pool.query("SELECT scoreid, eventid, userid, approvalstatus, approvedbyuser FROM score_submissions");
    res.json(scores.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

// Get all approved scores
router.get("/scores/approved", async (req, res) => {
  try {
    const scores = await pool.query("SELECT scoreid, eventid, userid, approvalstatus, approvedbyuser FROM score_submissions WHERE approvalstatus = 'Approved'");
    res.json(scores.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

// Get all not approved scores
router.get("/scores/not-approved", async (req, res) => {
  try {
    const scores = await pool.query("SELECT scoreid, eventid, userid, approvalstatus, approvedbyuser FROM score_submissions WHERE approvalstatus = 'Not Approved'");
    res.json(scores.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

// get all pending scores
router.get("/scores/pending", async (req, res) => {
  try {
    const scores = await pool.query("SELECT scoreid, eventid, userid, approvalstatus, approvedbyuser FROM score_submissions WHERE approvalstatus = 'Pending'");
    res.json(scores.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

// Get all scores from a specific player
router.get("/scores/player/:id", async (req, res) => {
  const {userid} = req.params;
  try {
    const scores = await pool.query("SELECT scoreid, eventid, userid, approvalstatus, approvedbyuser FROM score_submissions WHERE userid = $1", [userid]);
    res.json(scores.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

// Get all scores a specific e-board/coach has approved
router.get("/scores/approved-by/:id", async (req, res) => {
  const {approvedbyuser} = req.params;
  try {
    const scores = await pool.query("SELECT scoreid, eventid, userid, approvalstatus, approvedbyuser FROM score_submissions WHERE approvedbyuser = $1", [approvedbyuser]);
    res.json(scores.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

// Get a specific score
router.get("/scores/:scoreid", async (req, res) => {
  const {scoreid} = req.params;

  try {
    const result = await pool.query("SELECT * FROM score_submissions WHERE scoreid = $1", [scoreid]);

    if (result.rows.length === 0) {
      return res.status(404).json({message: "Score not found"});
    }

    const score = result.rows[0];

    // Convert the binary data to base64 so we could send it through json
    const scoreImageBase64 = score.scoreimage ?
            score.scoreimage.toString("base64") : null;

    score.scoreimage = scoreImageBase64;

    res.json(score);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

// Delete score
router.delete("/scores/:scoreid", async (req, res) => {
  const {scoreid} = req.params;
  try {
    const deletedScore = await pool.query("DELETE FROM score_submissions WHERE scoreid = $1 RETURNING *", [scoreid]);

    if (deletedScore.rows.length === 0) {
      return res.status(404).send("Score not found.");
    }
    res.json({message: "Score deleted successfully", score: deletedScore.rows[0]});
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

module.exports = router;
