const functions = require('firebase-functions');
const express = require('express');
const authRoutes = require('../server/routes/auth'); // Import your auth routes here
const announcementsRoutes = require('../server/routes/announcements');
const eventsRoutes = require('../server/routes/events');
const forumRoutes = require('../server/routes/forum');
const productsRoutes = require('../server/routes/products');
const scoresRoutes = require('../server/routes/scores');
const stripeRoutes = require('../server/routes/stripe');
const usersRoutes = require('../server/routes/users');

const app = express();

// Middleware to parse JSON request bodies
app.use(express.json());

// Use the route modules
app.use('/api/auth', authRoutes);  // All auth routes are now prefixed with /api/auth
app.use('/api/announcements', announcementsRoutes); // Corrected path
app.use('/api/events', eventsRoutes); // Corrected path
app.use('/api/forum', forumRoutes); // Corrected path
app.use('/api/products', productsRoutes); // Corrected path
app.use('/api/scores', scoresRoutes); // Corrected path
app.use('/api/stripe', stripeRoutes); // Corrected path
app.use('/api/users', usersRoutes); // Corrected path

// Export the Express app as a Firebase function
exports.api = functions.https.onRequest(app);
