const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/auth');
const usersRoutes = require('./routes/users'); // If exists
const eventsRouter = require('./routes/events');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json()); // Parses incoming JSON

// Test endpoint
app.get('/api/test', (req, res) => {
  res.json({ message: 'Hello from the server!' });
});

app.use('/api/auth', authRoutes);
app.use('/api/users', usersRoutes); 
app.use('/api/events', eventsRouter);

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
