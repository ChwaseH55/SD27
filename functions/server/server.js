const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/auth');
const usersRoutes = require('./routes/users');
const eventsRouter = require('./routes/events');
const forumRouter = require('./routes/forum');
const announcementsRouter = require('./routes/announcements');
const productsRouter = require('./routes/products');
const stripeRouter = require('./routes/stripe');
const scoresRouter = require('./routes/scores');

const app = express();
const PORT = 8080;

// Apply CORS first before parsing JSON
const corsOptions = {
  origin: true, // Allows all origins
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
};

// Apply CORS middleware globally with the options
app.use(cors(corsOptions));

app.use(express.json()); // Parses incoming JSON

// Test endpoint
app.get('/api/test', (req, res) => {
  res.json({ message: 'Hello from the server!' });
});

app.use('/api/auth', authRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/events', eventsRouter);
app.use('/api/forum', forumRouter);
app.use('/api/announcements', announcementsRouter);
app.use('/api/products', productsRouter);
app.use('/api/stripe', stripeRouter);
app.use('/api/scores', scoresRouter);

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
