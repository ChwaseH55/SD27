import React, { useState, useEffect, useRef } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { useSelector } from 'react-redux'; // Import useSelector to access Redux state
import clubLogo from '../assets/clublogo.png';

const Nav = ({ isLoggedIn, onLogout }) => {
  const location = useLocation();
  const user = useSelector((state) => state.user); // Access user from Redux state
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [showUserMenu, setShowUserMenu] = useState(false);
  const userMenuRef = useRef(null);

  // Close the menu when clicking outside
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (userMenuRef.current && !userMenuRef.current.contains(event.target)) {
        setShowUserMenu(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  // Close menus when route changes
  useEffect(() => {
    setIsMenuOpen(false);
    setShowUserMenu(false);
  }, [location]);

  // Function to check if a link is active
  const isActive = (path) => {
    // Keep it simple - consider a link active if the pathname starts with the path
    return location.pathname === path;
  };

  return (
    <nav className="fixed top-0 left-0 w-full z-30 bg-white shadow-md">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between h-16">
          {/* Logo and Title */}
          <div className="flex items-center">
            <Link to={isLoggedIn ? "/home" : "/"} className="flex items-center">
              <img src={clubLogo} alt="UCF Golf Club Logo" className="h-10 w-auto" />
              <span className="ml-2 text-xl font-bold text-gray-800 hidden sm:block">Golf Club @ UCF</span>
            </Link>
          </div>

          {/* Desktop Navigation */}
          <div className="hidden md:flex items-center space-x-2">
            {isLoggedIn ? (
              <>
                <Link to="/home">
                  <button
                    className={`px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                      isActive('/home') ? 'bg-yellow-500 text-white' : 'text-gray-700 hover:bg-yellow-50 hover:text-yellow-600'
                    }`}
                  >
                    Home
                  </button>
                </Link>
                <Link to="/calendar">
                  <button
                    className={`px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                      isActive('/calendar') ? 'bg-yellow-500 text-white' : 'text-gray-700 hover:bg-yellow-50 hover:text-yellow-600'
                    }`}
                  >
                    Calendar
                  </button>
                </Link>
                <Link to="/forum">
                  <button
                    className={`px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                      isActive('/forum') ? 'bg-yellow-500 text-white' : 'text-gray-700 hover:bg-yellow-50 hover:text-yellow-600'
                    }`}
                  >
                    Forum
                  </button>
                </Link>
                <Link to="/announcements">
                  <button
                    className={`px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                      isActive('/announcements') ? 'bg-yellow-500 text-white' : 'text-gray-700 hover:bg-yellow-50 hover:text-yellow-600'
                    }`}
                  >
                    Announcements
                  </button>
                </Link>
                <Link to="/scores">
                  <button
                    className={`px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                      isActive('/scores') ? 'bg-yellow-500 text-white' : 'text-gray-700 hover:bg-yellow-50 hover:text-yellow-600'
                    }`}
                  >
                    Tournaments
                  </button>
                </Link>
                <Link to="/store">
                  <button
                    className={`px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                      isActive('/store') ? 'bg-yellow-500 text-white' : 'text-gray-700 hover:bg-yellow-50 hover:text-yellow-600'
                    }`}
                  >
                    Shop
                  </button>
                </Link>
                <Link to="/chat">
                  <button
                    className={`px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                      isActive('/chat') ? 'bg-yellow-500 text-white' : 'text-gray-700 hover:bg-yellow-50 hover:text-yellow-600'
                    }`}
                  >
                    Chat
                  </button>
                </Link>
                {/* Admin button */}
                {user.user && user.user.roleid > 2 && (
                  <Link to="/admin">
                    <button
                      className={`px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                        isActive('/admin') ? 'bg-blue-600 text-white' : 'text-blue-600 hover:bg-blue-50'
                      }`}
                    >
                      Admin
                    </button>
                  </Link>
                )}

                {/* User menu dropdown */}
                <div className="relative ml-2" ref={userMenuRef}>
                  <button
                    onClick={() => setShowUserMenu(!showUserMenu)}
                    className="flex items-center px-3 py-2 rounded-full bg-gray-100 hover:bg-gray-200 transition-colors focus:outline-none"
                  >
                    <span className="text-sm font-medium text-gray-700 mr-1">
                      {user.user ? user.user.nickname || user.user.name || 'Account' : 'Account'}
                    </span>
                    <svg className="h-5 w-5 text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                    </svg>
                  </button>

                  {/* Dropdown menu */}
                  {showUserMenu && (
                    <div className="absolute right-0 mt-2 w-48 py-2 bg-white rounded-md shadow-xl z-20">
                      <Link
                        to="/account"
                        className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                      >
                        My Profile
                      </Link>
                      <button
                        onClick={onLogout}
                        className="block w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-gray-100"
                      >
                        Sign out
                      </button>
                    </div>
                  )}
                </div>
              </>
            ) : (
              <>
                <Link to="/login">
                  <button className="px-4 py-2 text-sm font-medium text-yellow-600 bg-transparent border border-yellow-500 rounded-md hover:bg-yellow-50 transition">
                    Sign in
                  </button>
                </Link>
                <Link to="/register">
                  <button className="px-4 py-2 text-sm font-medium text-white bg-yellow-500 rounded-md hover:bg-yellow-600 transition">
                    Sign up
                  </button>
                </Link>
              </>
            )}
          </div>

          {/* Mobile menu button */}
          <div className="flex items-center md:hidden">
            <button
              onClick={() => setIsMenuOpen(!isMenuOpen)}
              className="inline-flex items-center justify-center p-2 rounded-md text-gray-700 hover:text-gray-900 hover:bg-gray-100 focus:outline-none"
              aria-expanded="false"
            >
              <span className="sr-only">Open main menu</span>
              {!isMenuOpen ? (
                <svg className="block h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6h16M4 12h16M4 18h16" />
                </svg>
              ) : (
                <svg className="block h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
              )}
            </button>
          </div>
        </div>
      </div>

      {/* Mobile menu */}
      {isMenuOpen && (
        <div className="md:hidden bg-white shadow-lg">
          <div className="px-2 pt-2 pb-3 space-y-1 sm:px-3">
            {isLoggedIn ? (
              <>
                <Link
                  to="/home"
                  className={`block px-3 py-2 rounded-md text-base font-medium ${
                    isActive('/home') ? 'bg-yellow-500 text-white' : 'text-gray-700 hover:bg-yellow-50 hover:text-yellow-600'
                  }`}
                >
                  Home
                </Link>
                <Link
                  to="/calendar"
                  className={`block px-3 py-2 rounded-md text-base font-medium ${
                    isActive('/calendar') ? 'bg-yellow-500 text-white' : 'text-gray-700 hover:bg-yellow-50 hover:text-yellow-600'
                  }`}
                >
                  Calendar
                </Link>
                <Link
                  to="/forum"
                  className={`block px-3 py-2 rounded-md text-base font-medium ${
                    isActive('/forum') ? 'bg-yellow-500 text-white' : 'text-gray-700 hover:bg-yellow-50 hover:text-yellow-600'
                  }`}
                >
                  Forum
                </Link>
                <Link
                  to="/announcements"
                  className={`block px-3 py-2 rounded-md text-base font-medium ${
                    isActive('/announcements') ? 'bg-yellow-500 text-white' : 'text-gray-700 hover:bg-yellow-50 hover:text-yellow-600'
                  }`}
                >
                  Announcements
                </Link>
                <Link
                  to="/scores"
                  className={`block px-3 py-2 rounded-md text-base font-medium ${
                    isActive('/scores') ? 'bg-yellow-500 text-white' : 'text-gray-700 hover:bg-yellow-50 hover:text-yellow-600'
                  }`}
                >
                  Tournaments
                </Link>
                <Link
                  to="/store"
                  className={`block px-3 py-2 rounded-md text-base font-medium ${
                    isActive('/store') ? 'bg-yellow-500 text-white' : 'text-gray-700 hover:bg-yellow-50 hover:text-yellow-600'
                  }`}
                >
                  Shop
                </Link>
                <Link
                  to="/chat"
                  className={`block px-3 py-2 rounded-md text-base font-medium ${
                    isActive('/chat') ? 'bg-yellow-500 text-white' : 'text-gray-700 hover:bg-yellow-50 hover:text-yellow-600'
                  }`}
                >
                  Chat
                </Link>
                <Link
                  to="/account"
                  className={`block px-3 py-2 rounded-md text-base font-medium ${
                    isActive('/account') ? 'bg-yellow-500 text-white' : 'text-gray-700 hover:bg-yellow-50 hover:text-yellow-600'
                  }`}
                >
                  My Profile
                </Link>
                
                {user.user && user.user.roleid > 2 && (
                  <Link
                    to="/admin"
                    className={`block px-3 py-2 rounded-md text-base font-medium ${
                      isActive('/admin') ? 'bg-blue-600 text-white' : 'text-blue-600 hover:bg-blue-50'
                    }`}
                  >
                    Admin Dashboard
                  </Link>
                )}
                
                <button
                  onClick={onLogout}
                  className="block w-full text-left px-3 py-2 rounded-md text-base font-medium text-red-600 hover:bg-red-50"
                >
                  Sign out
                </button>
              </>
            ) : (
              <>
                <Link
                  to="/login"
                  className="block px-3 py-2 rounded-md text-base font-medium text-yellow-600 hover:bg-yellow-50"
                >
                  Sign in
                </Link>
                <Link
                  to="/register"
                  className="block px-3 py-2 rounded-md text-base font-medium bg-yellow-500 text-white hover:bg-yellow-600"
                >
                  Sign up
                </Link>
              </>
            )}
          </div>
        </div>
      )}
    </nav>
  );
};

export default Nav;
