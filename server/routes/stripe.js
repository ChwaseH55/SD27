const express = require('express');
const router = express.Router();
require('dotenv').config({ path: `${__dirname}/../.env` });
//console.log('Loaded Environment Variables:', process.env);
//console.log('Stripe Secret Key:', process.env.STRIPE_SECRET_KEY);
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

const YOUR_DOMAIN = 'http://localhost:3000';

// Get all products in Stripe
router.get('/productlist', async (req, res) => {
    try {
        // Fetch products and prices from Stripe
        const products = await stripe.products.list({ active: true });
        const prices = await stripe.prices.list({ active: true });

        // Create a list of products with prices and price IDs
        const productsWithPrices = products.data.map((product) => {
            // Find the price associated with this product
            const price = prices.data.find((price) => price.product === product.id);
            
            const productData = {
                id: product.id,
                name: product.name,
                description: product.description,
                images: product.images,
                price: price ? price.unit_amount / 100 : null, // Convert to dollars (if in cents)
                currency: price ? price.currency : null,
                priceId: price ? price.id : null, // Price ID from Stripe's prices API
            };

            // Log each product's details
            console.log('Product:', productData);

            return productData;
        });

        // Log all products with prices
        console.log('All Products with Prices:', productsWithPrices);

        // Send the products with prices and price IDs as the response
        res.status(200).json(productsWithPrices);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});



// // Route to fetch all products from Stripe
// router.get('/productlist', async (req, res) => {
//     try {
//       // Fetch products from Stripe
//       const products = await stripe.products.list({ active: true });
  
//       // Fetch prices associated with these products
//       const prices = await stripe.prices.list({ active: true });
  
//       // Map through the products and associate them with their prices
//       const productsWithPrices = products.data.map((product) => {
//         // Find the price related to this product
//         const price = prices.data.find((price) => price.product === product.id);
  
//         const productData = {
//           id: product.id,
//           name: product.name,
//           description: product.description,
//           images: product.images,
//           price: price ? price.unit_amount / 100 : null, // Convert to dollars (if in cents)
//           currency: price ? price.currency : null,
//         };
  
//         // Log the product data
//         console.log('Product:', productData);
  
//         return productData;
//       });
  
//       // Send a response to indicate the operation was successful (this part can stay the same)
//       res.status(200).json({ message: 'Products fetched and logged successfully.' });
  
//     } catch (error) {
//       console.error('Error fetching products from Stripe:', error);
//       res.status(500).json({ error: error.message });
//     }
//   });


router.post('/create-checkout-session', async (req, res) => {
    try {
        const { cartItems } = req.body; // cartItems must include priceId and quantities

        const lineItems = cartItems.map((item) => ({
            price: item.price, // price should be the actual priceId string
            quantity: item.quantity,
        }));

        // Create Checkout Session
        const session = await stripe.checkout.sessions.create({
            line_items: lineItems,
            mode: 'payment',
            success_url: `${YOUR_DOMAIN}/success.html`,
            cancel_url: `${YOUR_DOMAIN}/cancel.html`,
        });

        res.status(200).json({ url: session.url });
    } catch (err) {
        res.status(500).json({ error: err.message });
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
