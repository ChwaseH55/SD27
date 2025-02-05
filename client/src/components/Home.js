import React from 'react';
import { Link } from 'react-router-dom';

const Home = () => {
    return (
        <div className="flex flex-col h-full w-full bg-gradient-to-b from-ucfBlack to-ucfGold text-white">
            {/* Navbar */}
            <nav className="flex justify-between items-center w-full p-4 bg-ucfBlack bg-opacity-70 fixed top-0 z-10">
                <div className="text-xl font-bold">Golf Club @ UCF</div>
                <div className="flex gap-4">
                    <Link to="/account">
                        <button className="px-4 py-2 text-black bg-gold rounded hover:bg-opacity-80 transition">
                            My Account
                        </button>
                    </Link>
                    <Link to="/calendar">
                        <button className="px-4 py-2 text-black bg-gold rounded hover:bg-opacity-80 transition">
                            Calendar
                        </button>
                    </Link>
                    <Link to="/forum">
                        <button className="px-4 py-2 text-black bg-gold rounded hover:bg-opacity-80 transition">
                            Forum
                        </button>
                    </Link>
                    <Link to="/shop">
                        <button className="px-4 py-2 text-black bg-gold rounded hover:bg-opacity-80 transition">
                            Shop
                        </button>
                    </Link>
                </div>
            </nav>

            {/* Main Content */}
            <div className="flex flex-col items-center justify-center flex-1 p-4 mt-16">
                <h1 className="text-3xl font-bold mb-2 text-center">Welcome Back to the Golf Club at UCF!</h1>
                <p className="text-md text-center max-w-md mb-4">
                    We're excited to have you back! Explore your options below.
                </p>

                {/* Links to Other Pages */}
                <div className="bg-black bg-opacity-70 p-3 rounded-lg shadow-lg max-w-3xl w-full mt-4">
                    <h2 className="text-xl font-semibold mb-1">Explore</h2>
                    <ul className="list-disc pl-5 mb-4">
                        <li>
                            <Link to="/account" className="text-gold hover:underline">
                                Your Account
                            </Link>
                        </li>
                        <li>
                            <Link to="/calendar" className="text-gold hover:underline">
                                Upcoming Events
                            </Link>
                        </li>
                        <li>
                            <Link to="/forum" className="text-gold hover:underline">
                                Community Forum
                            </Link>
                        </li>
                        <li>
                            <Link to="/shop" className="text-gold hover:underline">
                                Merchandise Shop
                            </Link>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    );
};

export default Home;
