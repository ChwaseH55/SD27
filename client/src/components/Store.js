import React, { useState, useEffect } from "react";
import { useSelector } from "react-redux";
import { useNavigate } from "react-router-dom";
import { loadStripe } from "@stripe/stripe-js";
import { api } from '../config';

// Initialize Stripe with your public key
const stripePromise = loadStripe("pk_test_51PzZ4xRs4YZmhcoeiINiWfKCCh0sC5gpVqxfhtT24PzY7OPcUAlZuxyldOm7kKOejlZxi1wIwwbzMPVLVAS2pz2f00zNR0YmWR");

const Store = () => {
  const navigate = useNavigate();
  const { user } = useSelector((state) => state.user);

  // State for cart and products
  const [cartItems, setCartItems] = useState([]);
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);

  // Redirect to login if the user is not logged in
  useEffect(() => {
    if (!user) {
      navigate("/login");
    }
  }, [user, navigate]);

  // Fetch products from the backend
  useEffect(() => {
    const fetchProducts = async () => {
      try {
        const response = await api.get("/stripe/productlist");
        setProducts(response.data);
        setLoading(false);
      } catch (error) {
        console.error("Error fetching products:", error);
        setLoading(false);
      }
    };

    fetchProducts();
  }, []);

  const handleCheckout = async () => {
    const lineItems = cartItems.map((item) => ({
      price: item.priceId,
      quantity: item.quantity,
    }));
  
    try {
      const response = await api.post("/stripe/create-checkout-session", {
        cartItems: lineItems
      });
    
      // Check if the URL exists and redirect
      if (response.data.url) {
        window.location.href = response.data.url;  // Redirect to the Stripe Checkout URL
      } else {
        console.error("Error: No URL returned from Stripe session creation.");
      }
    } catch (error) {
      console.error("Error creating checkout session:", error);
    }
  };
  

  const addToCart = (product) => {
    const existingItem = cartItems.find((item) => item.id === product.id);
    if (existingItem) {
      setCartItems(
        cartItems.map((item) =>
          item.id === product.id
            ? { ...item, quantity: item.quantity + 1 }
            : item
        )
      );
    } else {
      setCartItems([...cartItems, { ...product, quantity: 1 }]);
    }
  };

  return (
    <div className="bg-gray-100 min-h-screen">
      {user && (
        <>
          <div className="pt-20">
            {/* Store Header */}
            <div className="bg-ucfBlack text-white py-12 text-center shadow-md">
              <h1 className="text-4xl font-extrabold mb-4">UCF Golf Club Store</h1>
              <p className="text-lg font-light">
                Explore official club merchandise and pay your dues here.
              </p>
            </div>

            {/* Product Section */}
            <div className="max-w-7xl mx-auto py-16 px-4 sm:px-6 lg:px-8">
              <h2 className="text-3xl font-bold text-gray-800 mb-10 text-center">
                Shop Merchandise
              </h2>

              {loading ? (
                <p className="text-center">Loading products...</p>  // Display loading message
              ) : (
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-10">
                  {products.length === 0 ? (
                    <p className="text-center">No products available.</p>  // Handle empty product list
                  ) : (
                    products.map((product) => (
                      <div
                        key={product.id}
                        className="bg-white shadow-lg rounded-lg overflow-hidden hover:scale-105 transition transform duration-200 ease-in-out"
                      >
                        <div className="relative w-full h-48 bg-gray-200 flex items-center justify-center">
                          <img
                            src={"/assets/clublogo.png"}  // Handle missing images
                            alt={product.name}
                            className="object-contain h-32"
                          />
                        </div>
                        <div className="p-6">
                          <h3 className="text-xl font-semibold text-gray-800 mb-2">
                            {product.name}
                          </h3>
                          <p className="text-gray-500 mb-4">
                            {product.price ? `$${(product.price.unit_amount / 100).toFixed(2)}` : "Price not available"}
                          </p>
                          <button
                            onClick={() => addToCart(product)}
                            className="w-full bg-ucfGold text-white py-3 rounded-lg font-medium hover:bg-ucfGold-dark transition"
                          >
                            Add to Cart
                          </button>
                        </div>
                      </div>
                    ))
                  )}
                </div>
              )}
            </div>

            {/* Cart Section */}
            <div className="bg-ucfGold py-16">
              <div className="max-w-7xl mx-auto text-center px-4 sm:px-6 lg:px-8">
                <h2 className="text-3xl font-bold text-white mb-6">
                  Cart ({cartItems.length} items)
                </h2>
                <div className="space-y-4 mb-8">
                  {cartItems.map((item) => (
                    <div key={item.id} className="flex justify-between">
                      <span>{item.name}</span>
                      <span>Quantity: {item.quantity}</span>
                    </div>
                  ))}
                </div>
                <button
                  onClick={handleCheckout}
                  className="bg-white text-ucfGold py-3 px-6 rounded-lg text-lg font-semibold hover:bg-gray-100 transition shadow-md"
                >
                  Checkout - Pay Now
                </button>
              </div>
            </div>

            {/* Footer Section */}
            <footer className="bg-ucfBlack text-white py-6">
              <div className="max-w-7xl mx-auto flex flex-col md:flex-row justify-between items-center px-4">
                <p className="text-sm">
                  &copy; {new Date().getFullYear()} UCF Golf Club. All rights
                  reserved.
                </p>
                <div className="flex gap-6 mt-4 md:mt-0">
                  <a href="/" className="hover:underline">
                    Home
                  </a>
                  <a href="/contact" className="hover:underline">
                    Contact
                  </a>
                  <a href="/privacy" className="hover:underline">
                    Privacy Policy
                  </a>
                </div>
              </div>
            </footer>
          </div>
        </>
      )}
    </div>
  );
};

export default Store;
