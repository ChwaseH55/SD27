require('dotenv').config();
const functions = require("firebase-functions");
const { STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET } = require("firebase-functions/params");



const express = require('express');
const router = express.Router();
const pool = require("../db");

const YOUR_DOMAIN = 'https://sd27-87d55.web.app';

// Helper function to get Stripe instance
const getStripe = async () => {
    let secretKey;

    try {
        secretKey = await STRIPE_SECRET_KEY.value();
    } catch (error) {
        console.warn('⚠️ Failed to get Firebase-managed secret, falling back to environment variable.');
    }

    // Fallback to environment variable if needed
    if (!secretKey && process.env.STRIPE_SECRET_KEY) {
        secretKey = process.env.STRIPE_SECRET_KEY;
    }

    if (!secretKey) {
        throw new Error('❌ No Stripe secret key available');
    }

    return require('stripe')(secretKey);
};


// Test Route
router.get('/test', (req, res) => {
    try {
        const stripe = getStripe();
        res.json({ message: "Stripe API is working!" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.get('/productlist', async (req, res) => {
    try {
        const { userId } = req.query;
        console.log(`Fetching products for user: ${userId}`);

        if (!userId) {
            return res.status(400).json({ error: "User ID is required." });
        }

        const userResult = await pool.query("SELECT paymentstatus FROM users WHERE id = $1", [userId]);

        if (userResult.rows.length === 0) {
            return res.status(404).json({ error: "User not found" });
        }

        const userPaymentStatus = userResult.rows[0].paymentstatus;
        console.log("User payment status:", userPaymentStatus);

        const stripe = await getStripe();
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

        if (userPaymentStatus && hasMembership) {
            return res.status(400).json({ error: "You have already paid your dues for this year." });
        }

        const lineItems = cartItems.map((item) => ({
            price: item.price,
            quantity: item.quantity,
        }));

        let metadata = {};
        if (hasMembership) {
            metadata = {
                userId: String(userId),
                type: "membership_dues"
            };
        }

        const stripe = await getStripe();
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

const handleWebhook = async (req, res) => {
    console.log("STRIPE_SECRET_KEY:", process.env.STRIPE_SECRET_KEY ? '✔️ Loaded' : '❌ Missing');
    console.log("STRIPE_WEBHOOK_SECRET:", process.env.STRIPE_WEBHOOK_SECRET ? '✔️ Loaded' : '❌ Missing');
    console.log("Request headers:", req.headers);
    console.log("Request rawBody type:", typeof req.rawBody);

    const sig = req.headers['stripe-signature'];
    let event;

    console.log("✅ Webhook received");
    console.log("Signature:", sig);

    try {
        // ✅ Use the env variables passed in from index.js
        const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
        const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

        // ✅ Verify the Stripe webhook signature
        event = stripe.webhooks.constructEvent(
            req.rawBody,
            sig,
            webhookSecret
        );

        console.log("✅ Webhook verified successfully:", event.type);

        if (event.type === 'checkout.session.completed') {
            const session = event.data.object;
            console.log("✅ Checkout session completed:", session);
            console.log("✅ Extracted Metadata:", session.metadata);

            if (session.metadata && session.metadata.type === "membership_dues") {
                const userId = session.metadata.userId;
                console.log(`🔹 Membership payment received for User ID: ${userId}`);

                try {
                    await pool.query("UPDATE users SET paymentstatus = true WHERE id = $1", [userId]);
                    console.log(`✅ Membership status updated for user ID ${userId}`);
                } catch (error) {
                    console.error("❌ Database update failed:", error);
                    return res.status(500).json({ error: "Database update failed" });
                }
            } else {
                console.log("No membership dues in this session. Skipping update.");
            }
        } else {
            console.log("Ignoring non-checkout event:", event.type);
        }

        res.json({ received: true });

    } catch (err) {
        console.error("❌ Webhook error:", {
            message: err.message,
            type: err.type,
            stack: err.stack
        });

        res.status(400).send(`Webhook Error: ${err.message}`);
    }
};


// Export the webhook handler separately
module.exports = {
    router,
    handleWebhook
};
