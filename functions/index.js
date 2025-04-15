const admin = require('firebase-admin');
const functions = require('firebase-functions');
const express = require('express');
const jwt = require('jsonwebtoken');
require('dotenv').config();

const stripeSecretKey = process.env.STRIPE_SECRET_KEY;
const stripe = require('stripe')(stripeSecretKey);

const authRoutes = require('./server/routes/auth');
const announcementsRoutes = require('./server/routes/announcements');
const eventsRoutes = require('./server/routes/events');
const forumRoutes = require('./server/routes/forum');
const productsRoutes = require('./server/routes/products');
const scoresRoutes = require('./server/routes/scores');
const stripeRoutes = require('./server/routes/stripe');
const usersRoutes = require('./server/routes/users');

const app = express();
//admin.initializeApp();

app.use(express.json());

// Detailed logging middleware
app.use((req, res, next) => {
  console.log('Request received:', {
    method: req.method,
    path: req.path,
    headers: req.headers,
    query: req.query,
    body: req.body,
    url: req.url,
    originalUrl: req.originalUrl
  });
  next();
});

// JWT Auth middleware
const authenticateUser = async (req, res, next) => {
  try {
    // Get the Authorization header
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'No token provided' });
    }

    // Get the token
    const token = authHeader.split('Bearer ')[1];
    
    if (!process.env.JWT_SECRET) {
      console.error('JWT_SECRET is not set in environment variables');
      return res.status(500).json({ error: 'Server configuration error' });
    }
    
    // Verify the JWT token
    const decodedToken = jwt.verify(token, process.env.JWT_SECRET);
    
    // Add the user to the request object
    req.user = decodedToken;
    next();
  } catch (error) {
    console.error('Auth Error:', error);
    res.status(401).json({ error: 'Invalid token' });
  }
};

// Public routes (no authentication required)
app.get('/api/test', (req, res) => {
  console.log('Test endpoint hit');
  res.json({ 
    message: 'API is working!',
    timestamp: new Date().toISOString(),
    path: req.path
  });
});

// Auth routes (no authentication required for login/register)
app.use('/api/auth', authRoutes);
// Stripe webhook route (public, no auth)
app.post('/api/stripe/webhook', stripeRoutes);

// Protected routes (require authentication)
app.use('/api/announcements', authenticateUser, announcementsRoutes);
app.use('/api/events', authenticateUser, eventsRoutes);
app.use('/api/forum', authenticateUser, forumRoutes);
app.use('/api/products', authenticateUser, productsRoutes);
app.use('/api/scores', authenticateUser, scoresRoutes);
app.use('/api/stripe', authenticateUser, stripeRoutes);
app.use('/api/users', authenticateUser, usersRoutes);

// 404 handler
app.use((req, res) => {
  console.log('404 for path:', req.path);
  res.status(404).json({ error: 'Not Found' });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', {
    message: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method
  });
  res.status(500).json({ 
    error: err.message,
    path: req.path
  });
});

// Export Express app as a Firebase Function
exports.api = functions.https.onRequest(app);