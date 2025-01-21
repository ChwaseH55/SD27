import React from 'react';
import { Link } from 'react-router-dom';
import clubLogo from '../assets/clublogo.png';

const Home = () => {
    return (
        <div className="flex flex-col min-h-screen bg-gray-100">
            {/* Navbar */}
            <nav className="fixed top-0 left-0 w-full flex justify-between items-center px-6 py-4 z-20 bg-white bg-opacity-90 shadow-md backdrop-filter backdrop-blur-lg">
                <div className="flex items-center gap-2">
                    <img src={clubLogo} alt="UCF Golf Club Logo" className="h-10" />
                    <span className="text-2xl font-bold text-gray-800">Golf Club @ UCF</span>
                </div>
                <div className="flex gap-4">
                    <Link to="/account">
                        <button className="px-4 py-2 bg-transparent border border-yellow-500 text-yellow-500 rounded hover:bg-yellow-500 hover:text-white transition">
                            My Account
                        </button>
                    </Link>
                    <Link to="/calendar">
                        <button className="px-4 py-2 bg-transparent border border-yellow-500 text-yellow-500 rounded hover:bg-yellow-500 hover:text-white transition">
                            Calendar
                        </button>
                    </Link>
                    <Link to="/forum">
                        <button className="px-4 py-2 bg-transparent border border-yellow-500 text-yellow-500 rounded hover:bg-yellow-500 hover:text-white transition">
                            Forum
                        </button>
                    </Link>
                    <Link to="/store">
                        <button className="px-4 py-2 bg-yellow-500 text-white rounded hover:bg-yellow-600 transition">
                            Shop
                        </button>
                    </Link>
                </div>
            </nav>

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
                    <p className="text-gray-600 mb-6">View and plan for upcoming tournaments, events, and club activities.</p>
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
