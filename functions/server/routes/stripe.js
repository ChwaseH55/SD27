require('dotenv').config();
const functions = require("firebase-functions");
const { defineSecret } = require("firebase-functions/params");

// Define secrets securely
const STRIPE_SECRET_KEY = defineSecret("STRIPE_SECRET_KEY");
const STRIPE_WEBHOOK_SECRET = defineSecret("STRIPE_WEBHOOK_SECRET");

const stripe = require('stripe')(STRIPE_SECRET_KEY.value());
const express = require('express');
const router = express.Router();
const pool = require("../db");
//require('dotenv').config({ path: `${__dirname}/../.env` });
//console.log('Loaded Environment Variables:', process.env);
//console.log('Stripe Secret Key:', process.env.STRIPE_SECRET_KEY);

const YOUR_DOMAIN = 'https://sd27-87d55.web.app';

// Test Route
router.get('/test', (req, res) => {
    res.json({ message: "Stripe API is working!", secretKey: STRIPE_SECRET_KEY.value() });
});

router.get('/productlist', async (req, res) => {
    try {
        const { userId } = req.query; // Get userId from query params
        console.log(`Fetching products for user: ${userId}`);

        if (!userId) {
            return res.status(400).json({ error: "User ID is required." });
        }

        // Fetch user payment status from the database
        const userResult = await pool.query("SELECT paymentstatus FROM users WHERE id = $1", [userId]);

        if (userResult.rows.length === 0) {
            return res.status(404).json({ error: "User not found" });
        }

        const userPaymentStatus = userResult.rows[0].paymentstatus;
        console.log("User payment status:", userPaymentStatus);

        // Fetch products and prices from Stripe
        const products = await stripe.products.list({ active: true });
        const prices = await stripe.prices.list({ active: true });

        // Filter out membership dues if the user has already paid
        const productsWithPrices = products.data
            .map((product) => {
                const price = prices.data.find((price) => price.product === product.id);

                return {
                    id: product.id,
                    name: product.name,
                    description: product.description,
                    images: product.images,
                    price: price ? price.unit_amount / 100 : null,
                    currency: price ? price.currency : null,
                    priceId: price ? price.id : null
                };
            })
            .filter(product => !(userPaymentStatus && product.name.toLowerCase().includes("membership")));

        console.log("Filtered Products:", productsWithPrices);

        res.status(200).json(productsWithPrices);
    } catch (err) {
        console.error("Error fetching product list:", err);
        res.status(500).json({ error: err.message });
    }
});



router.post('/create-checkout-session', async (req, res) => {
    try {
        const { cartItems, userId } = req.body;

        console.log("Received request with cartItems:", cartItems, "for userId:", userId);

        const userResult = await pool.query("SELECT paymentstatus FROM users WHERE id = $1", [userId]);

        if (userResult.rows.length === 0) {
            return res.status(404).json({ error: "User not found" });
        }

        const userPaymentStatus = userResult.rows[0].paymentstatus;
        const hasMembership = cartItems.some(item => item.name.toLowerCase().includes("membership"));

        console.log("User payment status:", userPaymentStatus, "Membership in cart:", hasMembership);

        // Prevent users from paying membership again if they already paid
        if (userPaymentStatus && hasMembership) {
            return res.status(400).json({ error: "You have already paid your dues for this year." });
        }

        const lineItems = cartItems.map((item) => ({
            price: item.price,
            quantity: item.quantity,
        }));

        // Create metadata ONLY if membership is in the cart
        let metadata = {};
        if (hasMembership) {
            metadata = {
                userId: String(userId), 
                type: "membership_dues"
            };
        }

        console.log(metadata);

        // Create Checkout Session
        const session = await stripe.checkout.sessions.create({
            line_items: lineItems,
            mode: 'payment',
            success_url: `${YOUR_DOMAIN}/success.html`,
            cancel_url: `${YOUR_DOMAIN}/cancel.html`,
            metadata: metadata
        });

        console.log("✅ Stripe Checkout Session Created:", session);
        res.status(200).json({ url: session.url });
    } catch (err) {
        console.error("Error creating checkout session:", err);
        res.status(500).json({ error: err.message });
    }
});

router.post('/webhook', express.raw({ type: 'application/json' }), async (req, res) => {
    const sig = req.headers['stripe-signature'];
    let event;

    console.log("✅ webhook received");

    try {
        event = stripe.webhooks.constructEvent(req.body, sig, STRIPE_WEBHOOK_SECRET.value());
    } catch (err) {
        console.error("❌ Webhook signature verification failed:", err.message);
        return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    console.log("✅ Webhook verified successfully:", event.type);

    if (event.type === 'checkout.session.completed') {
        const session = event.data.object;

        console.log("✅ Webhook received for checkout.session.completed:", session);
        console.log("✅ Extracted Metadata:", session.metadata); 

        if (session.metadata && session.metadata.type === "membership_dues") {
            const userId = session.metadata.userId;

            console.log(`🔹 Received membership payment for User ID: ${userId}`);

            try {
                await pool.query("UPDATE users SET paymentstatus = true WHERE id = $1", [userId]);
                console.log(`✅ Membership updated for user ID ${userId}`);
            } catch (error) {
                console.error("❌ Database update error:", error);
                return res.status(500).json({ error: "Database update failed" });
            }
        } else {
            console.log("No membership dues detected. Ignoring this payment.");
        }
    } else {
        console.log("Ignoring event:", event.type);
    }

    res.json({ received: true });
});


module.exports = router;
