/* eslint-disable linebreak-style */
/* eslint-disable camelcase */
/* eslint-disable max-len */
/* eslint-disable new-cap */
const express = require("express");
const cors = require("cors");
const authRoutes = require("./routes/auth");
const usersRoutes = require("./routes/users"); // If exists
const eventsRouter = require("./routes/events");
const forumRouter = require("./routes/forum");
const announcementsRouter = require("./routes/announcements");
const scoresRoute = require("./routes/scores");

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json()); // Parses incoming JSON

// Test endpoint
app.get("/api/test", (req, res) => {
  res.json({message: "Hello from the server!"});
});

app.use("/api/auth", authRoutes);
app.use("/api/users", usersRoutes);
app.use("/api/events", eventsRouter);
app.use("/api/forum", forumRouter);
app.use("/api/announcements", announcementsRouter);
app.use("/api/scores", scoresRoute);

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
