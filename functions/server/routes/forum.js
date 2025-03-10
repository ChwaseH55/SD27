const express = require('express');
const pool = require("../db");
const router = express.Router();

//create post
router.post('/posts', async(req, res) => {
    const {title, content, userid } = req.body;
    
    // Validate required fields
    if (!title || !content || !userid) {
        return res.status(400).json({
            error: "Missing required fields",
            details: "Title, content, and userid are required"
        });
    }

    // Validate user matches authenticated user
    if (userid !== req.user.id) {
        return res.status(403).json({
            error: "Unauthorized",
            details: "User ID does not match authenticated user"
        });
    }

    try {
        const newPost = await pool.query(
            `INSERT INTO posts (title, content, userid, createddate) VALUES ($1, $2, $3, NOW()) RETURNING *`, 
            [title, content, userid]
        );
        res.json(newPost.rows[0]);
    } catch (err) {
        console.error('Error creating post:', err);
        res.status(500).json({
            error: "Server error",
            details: err.message
        });
    }
});

//get all posts
router.get('/posts', async(req, res) => {
    try {
        console.log('GET /posts - Auth Debug:', {
            user: req.user,
            headers: req.headers,
            token: req.headers.authorization
        });
        
        // Test database connection first
        const testConnection = await pool.query('SELECT 1');
        if (!testConnection) {
            throw new Error('Database connection failed');
        }

        const posts = await pool.query("SELECT * FROM posts ORDER BY createddate DESC");
        res.json(posts.rows);
    } catch (err) {
        console.error('Error in GET /posts:', err);
        res.status(500).json({
            error: "Server error",
            details: err.message
        });
    }
});

//get a single post with replies
router.get('/posts/:id', async (req, res) => {
    const { id } = req.params;
    
    // Validate ID
    if (!id || isNaN(id)) {
        return res.status(400).json({
            error: "Invalid ID",
            details: "Post ID must be a valid number"
        });
    }

    try {
        const post = await pool.query("SELECT * FROM posts WHERE postid = $1", [id]);
        
        // Check if post exists
        if (post.rows.length === 0) {
            return res.status(404).json({
                error: "Not found",
                details: "Post not found"
            });
        }

        const replies = await pool.query(
            "SELECT * FROM replies WHERE postid = $1 ORDER BY createddate ASC", 
            [id]
        );
        
        res.json({
            post: post.rows[0], 
            replies: replies.rows 
        });
    } catch (err) {
        console.error('Error fetching post:', err);
        res.status(500).json({
            error: "Server error",
            details: err.message
        });
    }
});

// update a post
router.put('/posts/:id', async(req, res) => {
    const { id } = req.params;
    const { title, content } = req.body;

    try {
        const updatedPost = await pool.query( `UPDATE posts SET title = $1, content = $2 WHERE postid = $3 RETURNING *`, [title, content, id]);

        if(updatedPost.rows.length === 0) {
            return res.status(404).json({ message : "Post not found"});
        }

        res.json(updatedPost.rows[0]);
    }catch (err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

router.delete('/posts/:id', async (req, res) => {
    const { id } = req.params;
    try {
        await pool.query(
            "DELETE FROM likes WHERE postid = $1 OR replyid IN (SELECT replyid FROM replies WHERE postid = $1)", 
            [id]
        );

        await pool.query("DELETE FROM replies WHERE postid = $1", [id]);

        const deletedPost = await pool.query(
            "DELETE FROM posts WHERE postid = $1 RETURNING *", 
            [id]
        );

        if (deletedPost.rows.length === 0) {
            return res.status(404).json({ message: "Post not found" });
        }

        res.json({ message: "Post deleted successfully" });
    } catch (err) {
        console.error("Error deleting post:", err); // Log the full error
        res.status(500).json({ message: "Server error", error: err.message });
    }
});


//add a reply to a post
router.post('/posts/:id/replies', async (req, res) => {
    const { id } = req.params;
    const { content, userid } = req.body;
    try {
        const newReply = await pool.query( `INSERT INTO replies (postid, content, userid, createddate) VALUES ($1, $2, $3, NOW()) RETURNING *`, [id, content, userid]);
        res.json(newReply.rows[0]);
    } catch (err) {
        console.error( err.message );
        res.status(500).send("Server error");
    }

});

//update a reply
router.put('/replies/:id', async ( req, res) => {
    const { id } = req.params;
    const { content } = req.body;

    try {
        const updatedReply = await pool.query( `UPDATE replies SET content = $1 WHERE replyid = $2 RETURNING *`, [content, id]);

        if(updatedReply.rows.length === 0) {
            return res.status(404).json({ message : "Reply not found"});
        }

        res.json(updatedReply.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

//delete reply 
router.delete('/replies/:id', async (req, res) => {
    const { id } = req.params;

    try {
        await pool.query("DELETE FROM likes WHERE replyid = $1", [id]);

        const deletedReply = await pool.query("DELETE FROM replies WHERE replyid = $1 RETURNING *", [id]);

        if(deletedReply.rows.length === 0){
            return res.status(404).json({ message: "Reply not found"});
        }

        res.json({ message: "Reply deleted successfully"});
    } catch(err) {
        console.error (err.message);
        res.status(500).send("Server error");
    }

});

//like a post or reply
router.post('/likes', async (req, res) => {
    const { postid, replyid, userid } = req.body;
    try {
        const newLike = await pool.query( `INSERT INTO likes (postid, replyid, userid) VALUES ($1, $2, $3) RETURNING *`, [postid || null, replyid || null, userid]);
        res.json(newLike.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

//get likes for a post or a reply
router.get('/likes', async (req, res) => {

    const { postid, replyid } = req.query;

    try { 
        
        if(!postid && !replyid){
            return res.status(404).json({message: "Please provide either postid or replyid."});
        }
        
        let likes;

        if(postid){
            likes = await pool.query(
                `SELECT likeid, userid FROM likes WHERE postid = $1`, [postid]
            );
        }else if (replyid) {
            likes = await pool.query( `SELECT likeid, userid FROM likes WHERE replyid = $1`, [replyid]);
        }

        res.json(likes.rows);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

// delete a like by ID
router.delete('/likes/:id', async (req, res) => {
    const { id } = req.params;

    try {
        const deletedLike = await pool.query(`DELETE FROM likes WHERE likeid = $1 RETURNING *`, [id]);

        if (deletedLike.rows.length === 0) {
            return res.status(404).json({message : 'Like not found'});
        }

        res.json({message : "Like deleted successfully"});
    } catch(err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

module.exports = router;

