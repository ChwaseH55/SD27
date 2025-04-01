import React, { useState, useEffect } from "react";
import { useSelector } from "react-redux";
import { useNavigate } from "react-router-dom";
import { loadStripe } from "@stripe/stripe-js";
import { api } from '../config';

// Initialize Stripe with your public key
const stripePromise = loadStripe("pk_test_51PzZ4xRs4YZmhcoeiINiWfKCCh0sC5gpVqxfhtT24PzY7OPcUAlZuxyldOm7kKOejlZxi1wIwwbzMPVLVAS2pz2f00zNR0YmWR");

// Define background style objects
const mainBgStyle = {
  backgroundImage: "url('data:image/svg+xml,%3Csvg width=\"52\" height=\"26\" viewBox=\"0 0 52 26\" xmlns=\"http://www.w3.org/2000/svg\"%3E%3Cg fill=\"none\" fill-rule=\"evenodd\"%3E%3Cg fill=\"%23f0f0f0\" fill-opacity=\"0.8\"%3E%3Cpath d=\"M10 10c0-2.21-1.79-4-4-4-3.314 0-6-2.686-6-6h2c0 2.21 1.79 4 4 4 3.314 0 6 2.686 6 6 0 2.21 1.79 4 4 4 3.314 0 6 2.686 6 6 0 2.21 1.79 4 4 4v2c-3.314 0-6-2.686-6-6 0-2.21-1.79-4-4-4-3.314 0-6-2.686-6-6zm25.464-1.95l8.486 8.486-1.414 1.414-8.486-8.486 1.414-1.414z\"%2F%3E%3C%2Fg%3E%3C%2Fg%3E%3C%2Fsvg%3E'), linear-gradient(to bottom, rgba(250, 244, 230, 0.8), rgba(243, 244, 246, 0.9) 70%, rgba(209, 213, 219, 1))",
  backgroundRepeat: 'repeat, no-repeat',
  backgroundSize: 'auto, 100% 100%',
};

// Simple dot pattern for hero section
const heroBgStyle = {
  backgroundImage: "radial-gradient(white 2px, transparent 0)",
  backgroundSize: "30px 30px",
  backgroundPosition: "0 0",
  opacity: 0.2
};

// Grid pattern for product section
const gridBgStyle = {
  backgroundImage: "linear-gradient(to right, rgba(243, 244, 246, 0.1) 1px, transparent 1px), linear-gradient(to bottom, rgba(243, 244, 246, 0.1) 1px, transparent 1px)",
  backgroundSize: "40px 40px",
  backgroundPosition: "0 0",
};

// CSS for animations
const globalStyles = `
  @keyframes float {
    0% { transform: translateY(0px); }
    50% { transform: translateY(-10px); }
    100% { transform: translateY(0px); }
  }
`;

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
        const response = await api.get(`/stripe/productlist?userId=${user.id}`);
        setProducts(response.data);
        console.log(response.data);
        setLoading(false);
      } catch (error) {
        console.error("Error fetching products:", error);
        setLoading(false);
      }
    };

    fetchProducts();
  }, [user]);

  const handleCheckout = async () => {
    const lineItems = cartItems.map((item) => ({
      price: item.priceId,
      quantity: item.quantity,
      name: item.name
    }));
  
    try {
      const response = await api.post("/stripe/create-checkout-session", {
        cartItems: lineItems,
        userId: user.id
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

  const removeFromCart = (itemId) => {
    setCartItems(cartItems.filter(item => item.id !== itemId));
  };

  return (
    <div className="flex flex-col min-h-screen bg-gray-50" style={mainBgStyle}>
      {/* Inject global styles */}
      <style dangerouslySetInnerHTML={{ __html: globalStyles }} />
      
      {user && (
        <>
          <div className="pt-20">
            {/* Shop Header with gradient and pattern */}
            <header className="relative pt-12 pb-16 px-4 sm:px-6 lg:px-8 bg-gradient-to-r from-yellow-500 to-yellow-600 text-white overflow-hidden">
              {/* Pattern overlay */}
              <div className="absolute inset-0" style={heroBgStyle}></div>
              <div className="max-w-7xl mx-auto text-center">
                <h1 className="text-4xl font-bold mb-3">Club Shop</h1>
                <p className="mt-2 text-lg text-yellow-100 max-w-2xl mx-auto">
                  Explore official club merchandise and pay your membership dues here.
                </p>
              </div>
              
              {/* Wave SVG divider */}
              <div className="absolute bottom-0 left-0 right-0 overflow-hidden">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 120" preserveAspectRatio="none" className="fill-current text-gray-50" style={{ width: '100%', height: '50px' }}>
                  <path d="M321.39,56.44c58-10.79,114.16-30.13,172-41.86,82.39-16.72,168.19-17.73,250.45-.39C823.78,31,906.67,72,985.66,92.83c70.05,18.48,146.53,26.09,214.34,3V0H0V27.35A600.21,600.21,0,0,0,321.39,56.44Z"></path>
                </svg>
              </div>
            </header>

            {/* Products Section */}
            <section className="py-8 px-4 sm:px-6 lg:px-8 relative">
              <div className="absolute inset-0 bg-gradient-to-r from-yellow-50 to-transparent opacity-50"></div>
              <div className="absolute inset-0" style={gridBgStyle}></div>
              <div className="max-w-7xl mx-auto relative z-10">
                <h2 className="text-2xl font-bold text-gray-800 mb-8 text-center">
                  Club Merchandise
                </h2>

                {/* Products Grid */}
                {loading ? (
                  <div className="flex flex-col items-center justify-center py-12">
                    <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-yellow-500"></div>
                    <p className="mt-4 text-gray-600">Loading products...</p>
                  </div>
                ) : (
                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
                    {products.length === 0 ? (
                      <div className="col-span-full text-center py-12 bg-white rounded-xl shadow-md">
                        <svg className="w-16 h-16 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"></path>
                        </svg>
                        <p className="text-lg font-medium text-gray-800 mb-2">No Products Available</p>
                        <p className="text-gray-600">Check back later for new merchandise.</p>
                      </div>
                    ) : (
                      products.map((product) => (
                        <div
                          key={product.id}
                          className="bg-white rounded-xl shadow-md overflow-hidden hover:shadow-lg transition-all duration-300 transform hover:-translate-y-1 flex flex-col"
                        >
                          <div className="relative group">
                            <div className="w-full h-48 bg-gray-100 flex items-center justify-center overflow-hidden">
                              <img
                                src={"/assets/clublogo.png"}
                                alt={product.name}
                                className="object-contain h-32 transition-transform duration-300 group-hover:scale-110"
                              />
                            </div>
                            {product.isFeatured && (
                              <div className="absolute top-2 right-2 bg-yellow-500 text-white px-2 py-1 rounded text-xs font-semibold">
                                Featured
                              </div>
                            )}
                          </div>
                          <div className="p-6 flex-grow">
                            <h3 className="text-xl font-bold text-gray-800 mb-2 line-clamp-1">
                              {product.name}
                            </h3>
                            <p className="text-gray-600 mb-4 text-sm line-clamp-2">
                              {product.description || "Official UCF Golf Club merchandise."}
                            </p>
                            <div className="mt-auto">
                              <div className="flex justify-between items-center">
                                <span className="text-xl font-bold text-gray-900">
                                  {product.price ? `$${(product.price).toFixed(2)}` : "Price not available"}
                                </span>
                              </div>
                            </div>
                          </div>
                          <div className="px-6 pb-6">
                            <button
                              onClick={() => addToCart(product)}
                              className="w-full py-2 bg-yellow-500 hover:bg-yellow-600 text-white rounded-md transition-colors duration-300 flex items-center justify-center group"
                            >
                              <span>Add to Cart</span>
                              <svg className="ml-2 w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
                              </svg>
                            </button>
                          </div>
                        </div>
                      ))
                    )}
                  </div>
                )}
              </div>
            </section>

            {/* Cart Section */}
            <section className="py-12 px-4 sm:px-6 lg:px-8 bg-gradient-to-r from-yellow-500 to-yellow-600 text-white mt-12">
              <div className="max-w-7xl mx-auto">
                <div className="flex items-center justify-between mb-8">
                  <h2 className="text-2xl font-bold text-white flex items-center">
                    <svg className="w-6 h-6 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
                    </svg>
                    Your Cart
                  </h2>
                  <span className="px-3 py-1 bg-white text-yellow-600 rounded-full font-medium">
                    {cartItems.length} {cartItems.length === 1 ? 'item' : 'items'}
                  </span>
                </div>
                
                {cartItems.length === 0 ? (
                  <div className="bg-white bg-opacity-10 rounded-xl p-8 text-center">
                    <svg className="w-16 h-16 text-white opacity-70 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
                    </svg>
                    <p className="text-xl font-medium text-white mb-2">Your Cart is Empty</p>
                    <p className="text-white text-opacity-70 mb-6">Add some products to your cart to continue.</p>
                  </div>
                ) : (
                  <div className="bg-white bg-opacity-10 rounded-xl overflow-hidden mb-8">
                    <div className="divide-y divide-white divide-opacity-10">
                      {cartItems.map((item) => (
                        <div key={item.id} className="flex items-center justify-between p-4 hover:bg-white hover:bg-opacity-5 transition-colors">
                          <div className="flex items-center">
                            <div className="bg-white bg-opacity-20 rounded-lg p-3 mr-4">
                              <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"></path>
                              </svg>
                            </div>
                            <div>
                              <h3 className="text-white font-medium">{item.name}</h3>
                              <p className="text-white text-opacity-70 text-sm">${item.price} × {item.quantity}</p>
                            </div>
                          </div>
                          <div className="flex items-center">
                            <span className="text-white font-bold mr-4">
                              ${(item.price * item.quantity).toFixed(2)}
                            </span>
                            <button 
                              onClick={() => removeFromCart(item.id)}
                              className="text-white text-opacity-70 hover:text-white transition-colors"
                            >
                              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                              </svg>
                            </button>
                          </div>
                        </div>
                      ))}
                    </div>
                    
                    <div className="p-6 bg-white bg-opacity-5">
                      <div className="flex justify-between text-white mb-4">
                        <span className="text-lg">Subtotal</span>
                        <span className="text-lg font-bold">
                          ${cartItems.reduce((total, item) => total + (item.price * item.quantity), 0).toFixed(2)}
                        </span>
                      </div>
                      
                      <button
                        onClick={handleCheckout}
                        className="w-full flex items-center justify-center bg-white text-yellow-600 py-3 px-4 rounded-md text-lg font-semibold hover:bg-gray-100 transition shadow-md"
                      >
                        <span>Proceed to Checkout</span>
                        <svg className="ml-2 w-5 h-5 transform group-hover:translate-x-1 transition-transform duration-200" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
                        </svg>
                      </button>
                    </div>
                  </div>
                )}
              </div>
            </section>
          </div>
        </>
      )}
    </div>
  );
};

export default Store;
