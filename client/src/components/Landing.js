import React from 'react';
import { Link } from 'react-router-dom';

const Landing = () => {
    return (
        <div className="flex flex-col h-full w-full bg-gradient-to-b from-ucfBlack to-ucfGold text-white overflow-y-hidden">
            {/* Navbar */}
            <nav className="flex justify-between items-center w-full p-4 bg-ucfBlack bg-opacity-70 fixed top-0 z-10">
                <div className="text-xl font-bold">Golf Club @ UCF</div>
                <div className="flex gap-4">
                    <Link to="/login">
                        <button className="px-4 py-2 text-ucfGold bg-gold rounded hover:bg-opacity-80 transition">
                            Login
                        </button>
                    </Link>
                    <Link to="/register">
                        <button className="px-4 py-2 text-ucfGold bg-gold rounded hover:bg-opacity-80 transition">
                            Register
                        </button>
                    </Link>
                </div>
            </nav>

            {/* Main Content */}
            <div className="flex flex-col items-center justify-center flex-1 p-4 mt-16">
                <h1 className="text-3xl font-bold mb-2 text-center">Welcome to the Golf Club at UCF!</h1>
                <p className="text-md text-center max-w-md mb-4">
                    Join us for exciting tournaments, events, and a community of golf enthusiasts.
                </p>
                
                {/* Carousel Placeholder */}
                <div className="w-full max-w-3xl h-40 bg-ucfDarkGray rounded-lg mb-4 flex items-center justify-center">
                    <span className="text-gray-600">[Image Carousel Placeholder]</span>
                </div>

                {/* About Section */}
                <div className="bg-black bg-opacity-70 p-3 rounded-lg shadow-lg max-w-3xl w-full">
                    <h2 className="text-xl font-semibold mb-1">About Us</h2>
                    <p className="mb-2">
                        Our mission is to foster a love for golf and provide a welcoming environment for players of all skill levels.
                    </p>
                    <h3 className="font-bold">Key Achievements:</h3>
                    <ul className="list-disc pl-5 mb-4">
                        <li>Annual tournaments</li>
                        <li>Community volunteer programs</li>
                    </ul>
                    <div className="flex items-center mb-2">
                        <p className="mr-2">Check out our social media to stay connected with the club!</p>
                        <div className="flex space-x-4">
                            <Link to="https://x.com/golfclubucf" target="_blank" rel="noopener noreferrer">
                                <img src={'/x.png'} alt="X (Twitter)" className="h-8 w-8" />
                            </Link>
                            <Link to="https://www.instagram.com/golfclubucf" target="_blank" rel="noopener noreferrer">
                                <img src={'/insta.png'} alt="Instagram" className="h-8 w-8" />
                            </Link>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Landing;
