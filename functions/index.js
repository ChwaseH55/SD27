const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const express = require("express");
const jwt = require("jsonwebtoken");
require("dotenv").config();

// Import your route files
const authRoutes = require("./server/routes/auth");
const announcementsRoutes = require("./server/routes/announcements");
const eventsRoutes = require("./server/routes/events");
const forumRoutes = require("./server/routes/forum");
const productsRoutes = require("./server/routes/products");
const scoresRoutes = require("./server/routes/scores");
const usersRoutes = require("./server/routes/users");
const { router: stripeRouter, handleWebhook } = require("./server/routes/stripe");

// Initialize Express app
const app = express();
admin.initializeApp();

// Logging middleware (skips webhook route)
app.use((req, res, next) => {
  if (!req.originalUrl.includes("/stripe/webhook")) {
    console.log("Request received:", {
      method: req.method,
      path: req.path,
      headers: req.headers,
      query: req.query,
      body: req.body,
    });
  }
  next();
});

// Auth middleware
const authenticateUser = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({ error: "No token provided" });
    }

    const token = authHeader.split("Bearer ")[1];
    if (!process.env.JWT_SECRET) {
      return res.status(500).json({ error: "JWT secret not set" });
    }

    const decodedToken = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decodedToken;
    next();
  } catch (error) {
    console.error("Auth Error:", error);
    res.status(401).json({ error: "Invalid token" });
  }
};

// Express route setup
app.use(express.json());
app.get("/api/test", (req, res) => res.json({ message: "API is working!" }));
app.use("/api/auth", authRoutes);
app.use("/api/announcements", authenticateUser, announcementsRoutes);
app.use("/api/events", authenticateUser, eventsRoutes);
app.use("/api/forum", authenticateUser, forumRoutes);
app.use("/api/products", authenticateUser, productsRoutes);
app.use("/api/scores", authenticateUser, scoresRoutes);
app.use("/api/stripe", authenticateUser, stripeRouter);
app.use("/api/users", authenticateUser, usersRoutes);

// 404 & error handler
app.use((req, res) => res.status(404).json({ error: "Not Found" }));
app.use((err, req, res, next) => {
  console.error("Error:", err.message);
  res.status(500).json({ error: err.message });
});

// Gen 2 API function
exports.api = onRequest(
  {
    region: "us-central1",
    timeoutSeconds: 60,
  },
  app
);

// Gen 2 Stripe webhook function
const STRIPE_SECRET_KEY = defineSecret("STRIPE_SECRET_KEY");
const STRIPE_WEBHOOK_SECRET = defineSecret("STRIPE_WEBHOOK_SECRET");

exports.stripeWebhook = onRequest(
  {
    secrets: [STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET],
    region: "us-central1",
    cors: true,
    timeoutSeconds: 30,
  },
  async (req, res) => {
    process.env.STRIPE_SECRET_KEY = await STRIPE_SECRET_KEY.value();
    process.env.STRIPE_WEBHOOK_SECRET = await STRIPE_WEBHOOK_SECRET.value();
    return handleWebhook(req, res);
  }
);
