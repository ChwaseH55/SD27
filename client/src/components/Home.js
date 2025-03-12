import React from 'react';
import { Link } from 'react-router-dom';
import clubLogo from '../assets/clublogo.png';

const Home = () => {
    return (
        <div className="flex flex-col min-h-screen bg-gray-100">

            {/* Hero Section */}
            <header className="flex flex-col items-center justify-center flex-grow text-center bg-gray-200 pt-20 pb-8">
                <h1 className="text-5xl font-extrabold mb-4">
                    Welcome Back to UCF Golf Club!
                </h1>
                <p className="text-lg max-w-3xl mx-auto text-gray-700">
                    Discover everything our club has to offer. From upcoming events to exclusive merchandise, you're in the right place.
                </p>
            </header>

            {/* Main Section */}
            <section className="flex flex-wrap justify-center items-center gap-10 px-6 py-16 bg-gray-50">
                {/* Card 1 */}
                <div className="bg-white p-8 rounded-lg shadow-lg w-full max-w-xs text-center transform hover:scale-105 transition-all border border-gray-300">
                    <h2 className="text-2xl font-bold text-yellow-500 mb-4">Your Account</h2>
                    <p className="text-gray-600 mb-6">Manage your personal profile and stay up-to-date with your activities.</p>
                    <Link to="/account">
                        <button
                            aria-label="Go to Your Account"
                            className="px-6 py-2 bg-yellow-500 text-white font-semibold rounded hover:bg-yellow-600 transition"
                        >
                            Go to Account
                        </button>
                    </Link>
                </div>

                {/* Card 2 */}
                <div className="bg-white p-8 rounded-lg shadow-lg w-full max-w-xs text-center transform hover:scale-105 transition-all border border-gray-300">
                    <h2 className="text-2xl font-bold text-yellow-500 mb-4">Calendar</h2>
                    <p className="text-gray-600 mb-6">View upcoming tournaments, events, and club activities.</p>
                    <Link to="/calendar">
                        <button
                            aria-label="View Calendar"
                            className="px-6 py-2 bg-yellow-500 text-white font-semibold rounded hover:bg-yellow-600 transition"
                        >
                            View Calendar
                        </button>
                    </Link>
                </div>

                {/* Card 3 */}
                <div className="bg-white p-8 rounded-lg shadow-lg w-full max-w-xs text-center transform hover:scale-105 transition-all border border-gray-300">
                    <h2 className="text-2xl font-bold text-yellow-500 mb-4">Community Forum</h2>
                    <p className="text-gray-600 mb-6">Connect with fellow members and engage in meaningful discussions.</p>
                    <Link to="/forum">
                        <button
                            aria-label="Visit Community Forum"
                            className="px-6 py-2 bg-yellow-500 text-white font-semibold rounded hover:bg-yellow-600 transition"
                        >
                            Visit Forum
                        </button>
                    </Link>
                </div>

                {/* Card 4 */}
                <div className="bg-white p-8 rounded-lg shadow-lg w-full max-w-xs text-center transform hover:scale-105 transition-all border border-gray-300">
                    <h2 className="text-2xl font-bold text-yellow-500 mb-4">Shop</h2>
                    <p className="text-gray-600 mb-6">Purchase official club merchandise and pay your dues effortlessly.</p>
                    <Link to="/store">
                        <button
                            aria-label="Visit Shop"
                            className="px-6 py-2 bg-yellow-500 text-white font-semibold rounded hover:bg-yellow-600 transition"
                        >
                            Visit Shop
                        </button>
                    </Link>
                </div>
            </section>

            {/* Footer */}
            <footer className="py-6 bg-gray-800 text-center text-white">
                <p className="text-sm">
                    &copy; {new Date().getFullYear()} Golf Club @ UCF. All rights reserved.
                </p>
            </footer>
        </div>
    );
};

export default Home;
