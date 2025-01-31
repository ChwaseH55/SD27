const express = require('express');
const router = express.Router();
require('dotenv').config({ path: `${__dirname}/../.env` });
//console.log('Loaded Environment Variables:', process.env);
//console.log('Stripe Secret Key:', process.env.STRIPE_SECRET_KEY);
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

const YOUR_DOMAIN = 'http://localhost:4242';

//Get all products in stripe
router.get('/products', async (req, res) => {
    try {
        const products = await stripe.products.list({ active: true });

        const prices = await stripe.prices.list({ active: true });

        const productsWithPrices = products.data.map((product) => {
            return {
                id: product.id,
                name: product.name,
                description: product.description,
                images: product.images,
                price: prices.data.find((price) => price.product === product.id),
            };
        });
        res.status(200).json(productsWithPrices);
    }catch (err) {
        res.status(500).json({ error: err.message });
    }
});

router.post('/create-checkout-session', async (req,res) =>{
    try{
        const { cartItems } = req.body; // cartItems must include priceID IDS and quantities

        const lineItems = cartItems.map((item) => ({
            price: item.priceId,
            quantity: item.quantity,
        }));

        //checkout session
        const session = await stripe.checkout.sessions.create({
            line_items: lineItems,
            mode: 'payment',
            success_url: `${YOUR_DOMAIN}/success.html`, //need to make success page
            cancel_url: `${YOUR_DOMAIN}/cancel.html`, //need to make error page
        });
        res.status(200).json({ url: session.url });
    }catch(err){
        res.status(500).json({error: err.message});
    }
});
/*
// Create Checkout Session
router.post('/create-checkout-session', async (req, res) => {
    try {
        const session = await stripe.checkout.sessions.create({
            line_items: [
                {
                    price: 'price_1QLzZ0Rs4YZmhcoeVv9jQXbV', 
                    quantity: 1,
                },
            ],
            mode: 'payment',
            success_url: `${YOUR_DOMAIN}/success.html`, //need to make success page
            cancel_url: `${YOUR_DOMAIN}/cancel.html`, //need to make error page
        });

        res.status(200).json({ url: session.url }); //this allows front end to handle redirection also i needed it to test postamn
        //res.redirect(303, session.url); //redirecting to checkout 
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});*/

module.exports = router;
