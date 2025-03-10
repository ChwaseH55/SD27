const express = require('express');
const pool = require('../db'); // PostgreSQL connection pool
const router = express.Router();

// Create a new product
router.post('/', async (req, res) => {
    const { productname, description, amount, quantity, producttype } = req.body;
    try {
        const newProduct = await pool.query(
            `INSERT INTO products (productname, description, amount, quantity, producttype) 
             VALUES ($1, $2, $3, $4, $5) RETURNING *`,
            [productname, description, amount, quantity, producttype]
        );
        res.status(201).json(newProduct.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

// Get all products
router.get('/', async (req, res) => {
    try {
        const products = await pool.query(`SELECT * FROM products ORDER BY productname ASC`);
        res.json(products.rows);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

// Get a single product by ID
router.get('/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const product = await pool.query(
            `SELECT * FROM products WHERE productid = $1`,
            [id]
        );
        if (product.rows.length === 0) {
            return res.status(404).json({ message: "Product not found" });
        }
        res.json(product.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

// Update a product
router.put('/:id', async (req, res) => {
    const { id } = req.params;
    const { productname, description, amount, quantity, producttype } = req.body;
    try {
        const updatedProduct = await pool.query(
            `UPDATE products SET productname = $1, description = $2, amount = $3, quantity = $4, producttype = $5 
             WHERE productid = $6 RETURNING *`,
            [productname, description, amount, quantity, producttype, id]
        );
        if (updatedProduct.rows.length === 0) {
            return res.status(404).json({ message: "Product not found" });
        }
        res.json(updatedProduct.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

// Delete a product
router.delete('/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const deletedProduct = await pool.query(
            `DELETE FROM products WHERE productid = $1 RETURNING *`,
            [id]
        );
        if (deletedProduct.rows.length === 0) {
            return res.status(404).json({ message: "Product not found" });
        }
        res.json({ message: "Product deleted successfully" });
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server error");
    }
});

module.exports = router;
