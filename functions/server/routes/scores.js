const express = require('express');
const multer = require('multer');
const pool = require("../db");
const router = express.Router();

const storage = multer.memoryStorage();
const upload = multer({ storage });
//create score
/*
    This api allows player to include multiple player in the score
*/
router.post('/', async(req, res) =>{
    const { eventid, userids, scoreimage, scores, status, submissiondate } = req.body;

    if (!eventid || !userids || !scoreimage) {
        return res.status(400).json({ message: "Missing required fields: eventid, userids, or scoreimage" });
    }
    
    try{
        const userIdArray = Array.isArray(userids) ? userids : userids.split(',');
        const scoreArray = scores ? (Array.isArray(scores) ? scores : scores.split(',')) : null;
        
        //Inserting a score for each userid that is submitted
        const insertedScores = [];
        const errors = [];
        
        for(let i = 0; i < userIdArray.length; i++){
            try {
                const newScore = await pool.query(
                    'INSERT INTO score_submissions (eventid, userid, scoreimage, approvalstatus, score, submissiondate) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
                    [
                        eventid, 
                        userIdArray[i], 
                        scoreimage,
                        status || 'pending',
                        scoreArray ? (Array.isArray(scoreArray) ? scoreArray[i] : scoreArray) : null,
                        submissiondate || new Date().toISOString()
                    ]
                );
                insertedScores.push(newScore.rows[0]);
            } catch (err) {
                console.error(`Error inserting score for userid=${userIdArray[i]}:`, err.message);
                errors.push(`Failed to insert score for user ${userIdArray[i]}: ${err.message}`);
            }
        }

        // If there were any errors during insertion
        if (errors.length > 0) {
            return res.status(500).json({
                message: "Some scores failed to submit",
                errors: errors,
                successfulScores: insertedScores
            });
        }

        res.json({
            message: "Scores successfully submitted for all users.",
            scores: insertedScores,
        });
    } catch (err) {
        console.error("Error in score submission:", err.message);
        res.status(500).json({
            message: "Server error during score submission",
            error: err.message
        });
    }
});

//update a score (once it has been approved you cannot update the score.)
router.put('/scores/:scoreid', async (req, res) => {
    const { scoreid } = req.params;
    const { eventid, scoreimage } = req.body; 

    try {
        const checkResult = await pool.query(
            'SELECT approvalstatus FROM score_submissions WHERE scoreid = $1',
            [scoreid]
        );

        if (checkResult.rows.length === 0) {
            return res.status(404).json({ message: "Score not found" });
        }

        const approvalStatus = checkResult.rows[0].approvalstatus;

        // If the score is approved, return a 403 error
        if (approvalStatus === 'Approved') {
            return res.status(403).json({ message: "Cannot update an approved score." });
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


//approve score :)
router.put('/approve', async (req, res) => {
    const {scoreid} = req.body;
    try{
        const updatedScore = await pool.query(`UPDATE score_submissions SET approvalstatus = 'approved' WHERE scoreid = $1 RETURNING *`, [scoreid]);

        if( updatedScore.rows.length === 0) {
            return res.status(404).json({ message : "Score not found"});
        }

        res.json(updatedScore.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

// not approve score :)
router.put('/not-approve', async (req, res) => {
    const {scoreid} = req.body;
    try{
        console.log("Attempting to reject score:", scoreid);
        const updatedScore = await pool.query(`UPDATE score_submissions SET approvalstatus = 'not_approved' WHERE scoreid = $1 RETURNING *`, [scoreid]);
        console.log("Update result:", updatedScore.rows);

        if( updatedScore.rows.length === 0) {
            console.log("No score found with ID:", scoreid);
            return res.status(404).json({ message : "Score not found"});
        }

        res.json(updatedScore.rows[0]);
    } catch (err) {
        console.error("Error in not-approve route:", err);
        console.error("Error details:", {
            message: err.message,
            stack: err.stack,
            code: err.code
        });
        res.status(500).json({
            message: "Server error",
            error: err.message
        });
    }
});

//Get all scores (approved, pending and non-approved) 
router.get('/scores', async(req, res) => {
    try{
        const scores = await pool.query("SELECT scoreid, eventid, userid, approvalstatus, approvedbyuser, score, scoreimage, submissiondate FROM score_submissions");
        res.json(scores.rows);
    }catch (err){
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

//Get all approved scores
router.get('/scores/approved', async(req, res) => {
    try{
        const scores = await pool.query("SELECT scoreid, eventid, userid, approvalstatus, approvedbyuser, score, scoreimage, submissiondate FROM score_submissions WHERE approvalstatus = 'approved'");
        res.json(scores.rows);
    }catch (err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

//Get all not approved scores
router.get('/scores/not-approved', async(req, res) => {
    try{
        const scores = await pool.query("SELECT scoreid, eventid, userid, approvalstatus, approvedbyuser, score, scoreimage, submissiondate FROM score_submissions WHERE approvalstatus = 'not_approved'");
        res.json(scores.rows);
    }catch (err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

//get all pending scores
router.get('/pending', async(req, res) => {
    try{
        console.log("Fetching pending scores...");
        const scores = await pool.query("SELECT scoreid, eventid, userid, approvalstatus, approvedbyuser, score, scoreimage, submissiondate FROM score_submissions WHERE LOWER(approvalstatus) = 'pending'");
        console.log("Found pending scores:", scores.rows);
        res.json(scores.rows);
    }catch (err) {
        console.error("Error fetching pending scores:", err.message);
        res.status(500).send("Server error");
    }
});

//Get all scores from a specific player
router.get('/scores/player/:id', async (req, res) => {
    const { userid } = req.params;
    try {
        const scores = await pool.query("SELECT scoreid, eventid, userid, approvalstatus, approvedbyuser, score, scoreimage, submissiondate FROM score_submissions WHERE userid = $1", [userid]);
        res.json(scores.rows);
    }catch (err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

//Get all scores a specific e-board/coach has approved
router.get('/scores/approved-by/:id', async (req, res) => {
    const { approvedbyuser } = req.params;
    try {
        const scores = await pool.query("SELECT scoreid, eventid, userid, approvalstatus, approvedbyuser FROM score_submissions WHERE approvedbyuser = $1", [approvedbyuser]);
        res.json(scores.rows);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

//Get a specific score
router.get('/scores/:scoreid', async (req, res) => {
    const { scoreid } = req.params;

    try {
        const result = await pool.query('SELECT * FROM score_submissions WHERE scoreid = $1', [scoreid]);

        if(result.rows.length === 0){
            return res.status(404).json({message: "Score not found"});
        }

        const score = result.rows[0];

        // Convert the binary data to base64 so we could send it through json
        const scoreImageBase64 = score.scoreimage
            ? score.scoreimage.toString('base64') : null;

            score.scoreimage = scoreImageBase64;

            res.json(score);
    } catch(err){
        console.error (err.message);
        res.status(500).send("Server error");
    }
});

//Delete score
router.delete('/scores/:scoreid', async(req, res) => {
    const { scoreid } = req.params;
    try {
        const deletedScore = await pool.query("DELETE FROM score_submissions WHERE scoreid = $1 RETURNING *", [scoreid]);
        
        if(deletedScore.rows.length === 0){
            return res.status(404).send("Score not found.");
        }
        res.json({message:"Score deleted successfully", score: deletedScore.rows[0]});
    }catch (err){
        console.error (err.message);
        res.status(500).send("Server error");
    }
});

module.exports = router;