import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { useSelector } from 'react-redux'; // Import useSelector to access Redux state
import clubLogo from '../assets/clublogo.png';

const Nav = ({ isLoggedIn, onLogout }) => {
  const location = useLocation();
  const user = useSelector((state) => state.user); // Access user from Redux state

  // Utility function to determine if the link is active
  const isActive = (path) => location.pathname === path;

  return (
    <nav className="fixed top-0 left-0 w-full flex justify-between items-center px-6 py-4 z-20 bg-white bg-opacity-90 shadow-md backdrop-filter backdrop-blur-lg">
      {/* Logo and Title */}
      <div className="flex items-center gap-2">
        <img src={clubLogo} alt="UCF Golf Club Logo" className="h-10" />
        <span className="text-2xl font-bold text-gray-800">Golf Club @ UCF</span>
      </div>

      {/* Navigation Links */}
      <div className="flex gap-4">
        {isLoggedIn ? (
          <>
            <Link to="/account">
              <button
                className={`px-4 py-2 border rounded ${
                  isActive('/account')
                    ? 'bg-yellow-500 text-white'
                    : 'bg-transparent border-yellow-500 text-yellow-500 hover:bg-yellow-500 hover:text-white transition'
                }`}
              >
                My Account
              </button>
            </Link>
            <Link to="/calendar">
              <button
                className={`px-4 py-2 border rounded ${
                  isActive('/calendar')
                    ? 'bg-yellow-500 text-white'
                    : 'bg-transparent border-yellow-500 text-yellow-500 hover:bg-yellow-500 hover:text-white transition'
                }`}
              >
                Calendar
              </button>
            </Link>
            <Link to="/forum">
              <button
                className={`px-4 py-2 border rounded ${
                  isActive('/forum')
                    ? 'bg-yellow-500 text-white'
                    : 'bg-transparent border-yellow-500 text-yellow-500 hover:bg-yellow-500 hover:text-white transition'
                }`}
              >
                Forum
              </button>
            </Link>
            <Link to="/events">
              <button
                className={`px-4 py-2 border rounded ${
                  isActive('/events')
                    ? 'bg-yellow-500 text-white'
                    : 'bg-transparent border-yellow-500 text-yellow-500 hover:bg-yellow-500 hover:text-white transition'
                }`}
              >
                Events
              </button>
            </Link>
            <Link to="/scores">
              <button
                className={`px-4 py-2 border rounded ${
                  isActive('/scores')
                    ? 'bg-yellow-500 text-white'
                    : 'bg-transparent border-yellow-500 text-yellow-500 hover:bg-yellow-500 hover:text-white transition'
                }`}
              >
                Scores
              </button>
            </Link>
            <Link to="/store">
              <button
                className={`px-4 py-2 border rounded ${
                  isActive('/store')
                    ? 'bg-yellow-500 text-white'
                    : 'bg-transparent border-yellow-500 text-yellow-500 hover:bg-yellow-500 hover:text-white transition'
                }`}
              >
                Shop
              </button>
            </Link>
            {/* Conditionally render the admin dashboard link */}
            {user.user.roleid > 2 && (
              <Link to="/admin">
                <button
                  className={`px-4 py-2 border rounded ${
                    isActive('/admin')
                      ? 'bg-blue-500 text-white'
                      : 'bg-transparent border-blue-500 text-blue-500 hover:bg-blue-500 hover:text-white transition'
                  }`}
                >
                  Admin Dashboard
                </button>
              </Link>
            )}
            <button
              onClick={onLogout}
              className="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600 transition"
            >
              Logout
            </button>
          </>
        ) : (
          <>
            <Link to="/login">
              <button className="px-4 py-2 bg-transparent border border-yellow-500 text-yellow-500 rounded hover:bg-yellow-500 hover:text-white transition">
                Login
              </button>
            </Link>
            <Link to="/register">
              <button className="px-4 py-2 bg-yellow-500 text-white rounded hover:bg-yellow-600 transition">
                Register
              </button>
            </Link>
          </>
        )}
      </div>
    </nav>
  );
};

export default Nav;
