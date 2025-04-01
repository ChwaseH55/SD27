import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useSelector } from 'react-redux';
import clubLogo from '../assets/clublogo.png';
import { api } from '../config';

// Define background style objects instead of inline SVG patterns
const mainBgStyle = {
  backgroundImage: "url('data:image/svg+xml,%3Csvg width=\"52\" height=\"26\" viewBox=\"0 0 52 26\" xmlns=\"http://www.w3.org/2000/svg\"%3E%3Cg fill=\"none\" fill-rule=\"evenodd\"%3E%3Cg fill=\"%23f0f0f0\" fill-opacity=\"0.8\"%3E%3Cpath d=\"M10 10c0-2.21-1.79-4-4-4-3.314 0-6-2.686-6-6h2c0 2.21 1.79 4 4 4 3.314 0 6 2.686 6 6 0 2.21 1.79 4 4 4 3.314 0 6 2.686 6 6 0 2.21 1.79 4 4 4v2c-3.314 0-6-2.686-6-6 0-2.21-1.79-4-4-4-3.314 0-6-2.686-6-6zm25.464-1.95l8.486 8.486-1.414 1.414-8.486-8.486 1.414-1.414z\"%2F%3E%3C%2Fg%3E%3C%2Fg%3E%3C%2Fsvg%3E'), linear-gradient(to bottom, rgba(250, 244, 230, 0.8), rgba(243, 244, 246, 0.9) 70%, rgba(209, 213, 219, 1))",
  backgroundRepeat: 'repeat, no-repeat',
  backgroundSize: 'auto, 100% 100%',
};

const announcementsBgStyle = {
  backgroundImage: "url('data:image/svg+xml,%3Csvg width=\"40\" height=\"40\" viewBox=\"0 0 40 40\" xmlns=\"http://www.w3.org/2000/svg\"%3E%3Cg fill=\"%23f3f4f6\" fill-opacity=\"0.7\" fill-rule=\"evenodd\"%3E%3Cpath d=\"M0 38.59l2.83-2.83 1.41 1.41L1.41 40H0v-1.41zM0 1.4l2.83 2.83 1.41-1.41L1.41 0H0v1.41zM38.59 40l-2.83-2.83 1.41-1.41L40 38.59V40h-1.41zM40 1.41l-2.83 2.83-1.41-1.41L38.59 0H40v1.41zM20 18.6l2.83-2.83 1.41 1.41L21.41 20l2.83 2.83-1.41 1.41L20 21.41l-2.83 2.83-1.41-1.41L18.59 20l-2.83-2.83 1.41-1.41L20 18.59z\"%3E%3C%2Fpath%3E%3C%2Fg%3E%3C%2Fsvg%3E')",
  backgroundRepeat: 'repeat'
};

// Simple dot pattern for hero section
const heroBgStyle = {
  backgroundImage: "radial-gradient(white 2px, transparent 0)",
  backgroundSize: "30px 30px",
  backgroundPosition: "0 0",
  opacity: 0.2
};

// Grid pattern for quick links
const gridBgStyle = {
  backgroundImage: "linear-gradient(to right, rgba(243, 244, 246, 0.1) 1px, transparent 1px), linear-gradient(to bottom, rgba(243, 244, 246, 0.1) 1px, transparent 1px)",
  backgroundSize: "40px 40px",
  backgroundPosition: "0 0",
};

// Animation styles
const floatAnimation = {
  animation: "float 6s ease-in-out infinite"
};

// CSS for animations
const globalStyles = `
  @keyframes float {
    0% { transform: translateY(0px); }
    50% { transform: translateY(-10px); }
    100% { transform: translateY(0px); }
  }
`;

// Import icons
const CalendarIcon = () => (
  <svg className="w-10 h-10 text-yellow-500" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
  </svg>
);

const ForumIcon = () => (
  <svg className="w-10 h-10 text-yellow-500" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M17 8h2a2 2 0 012 2v6a2 2 0 01-2 2h-2v4l-4-4H9a1.994 1.994 0 01-1.414-.586m0 0L11 14h4a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2v4l.586-.586z"></path>
  </svg>
);

const ShopIcon = () => (
  <svg className="w-10 h-10 text-yellow-500" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"></path>
  </svg>
);

const ScoreIcon = () => (
  <svg className="w-10 h-10 text-yellow-500" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
  </svg>
);

const ChatIcon = () => (
  <svg className="w-10 h-10 text-yellow-500" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"></path>
  </svg>
);

const ProfileIcon = () => (
  <svg className="w-10 h-10 text-yellow-500" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
  </svg>
);

const Home = () => {
  const user = useSelector((state) => state.user);
  const [announcements, setAnnouncements] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  // Get user's first name for greeting
  const firstName = user?.user?.firstName || 'there';

  // Fetch announcements from API
  useEffect(() => {
    const fetchAnnouncements = async () => {
      try {
        setLoading(true);
        const response = await api.get('/announcements');
        setAnnouncements(response.data);
        setLoading(false);
      } catch (err) {
        console.error('Error fetching announcements:', err);
        setError('Failed to load announcements');
        setLoading(false);
      }
    };

    fetchAnnouncements();
  }, []);

  // Format date for announcement display
  const formatDate = (dateString) => {
    const options = { year: 'numeric', month: 'long', day: 'numeric' };
    return new Date(dateString).toLocaleDateString(undefined, options);
  };

  return (
    <div className="flex flex-col min-h-screen bg-gray-50" style={mainBgStyle}>
      {/* Inject global styles */}
      <style dangerouslySetInnerHTML={{ __html: globalStyles }} />
      
      {/* Hero Section with Welcome Message */}
      <header className="relative pt-24 pb-16 px-4 sm:px-6 lg:px-8 bg-gradient-to-r from-yellow-500 to-yellow-600 text-white overflow-hidden">
        {/* Pattern overlay */}
        <div className="absolute inset-0 opacity-20" style={heroBgStyle}></div>
        <div className="max-w-7xl mx-auto">
          <div className="md:flex md:items-center md:justify-between">
            <div className="mb-8 md:mb-0">
              <h1 className="text-4xl md:text-5xl font-bold">
                Welcome back, {firstName}!
              </h1>
              <p className="mt-3 text-lg md:text-xl text-yellow-100 max-w-2xl">
                Stay updated with club activities, upcoming events, and connect with fellow golf enthusiasts.
              </p>
            </div>
            <img 
              src={clubLogo} 
              alt="UCF Golf Club" 
              className="hidden md:block h-32 w-32 rounded-full border-4 border-white shadow-lg" 
              style={floatAnimation}
            />
          </div>
        </div>
        
        {/* Wave SVG divider */}
        <div className="absolute bottom-0 left-0 right-0 overflow-hidden">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 120" preserveAspectRatio="none" className="fill-current text-gray-50" style={{ width: '100%', height: '50px' }}>
            <path d="M321.39,56.44c58-10.79,114.16-30.13,172-41.86,82.39-16.72,168.19-17.73,250.45-.39C823.78,31,906.67,72,985.66,92.83c70.05,18.48,146.53,26.09,214.34,3V0H0V27.35A600.21,600.21,0,0,0,321.39,56.44Z"></path>
          </svg>
        </div>
      </header>

      {/* Quick Links Section */}
      <section className="py-12 px-4 sm:px-6 lg:px-8 relative">
        <div className="absolute inset-0 bg-gradient-to-r from-yellow-50 to-transparent opacity-50"></div>
        <div className="absolute inset-0" style={gridBgStyle}></div>
        <div className="max-w-7xl mx-auto relative z-10">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-gray-800">Quick Links</h2>
            <p className="mt-4 text-lg text-gray-600 max-w-2xl mx-auto">
              Everything you need, all in one place. Navigate to any part of the UCF Golf Club portal.
            </p>
          </div>
          
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
            {/* Calendar Card */}
            <Link 
              to="/calendar" 
              className="bg-white rounded-xl shadow-md overflow-hidden hover:shadow-lg transition-all duration-300 transform hover:-translate-y-1 flex flex-col"
            >
              <div className="p-6 flex-grow">
                <div className="mb-4 transform transition hover:scale-110 duration-300"><CalendarIcon /></div>
                <h3 className="text-xl font-bold text-gray-800 mb-2">Calendar & Events</h3>
                <p className="text-gray-600">
                  View all club activities and events on our interactive calendar. Register for tournaments, social events, and practice sessions.
                </p>
              </div>
              <div className="px-6 pb-6">
                <button className="w-full py-2 bg-yellow-500 hover:bg-yellow-600 text-white rounded-md transition-colors duration-300 flex items-center justify-center group">
                  <span>Browse Calendar & Events</span>
                  <svg className="ml-2 w-5 h-5 transform group-hover:translate-x-1 transition-transform duration-200" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 5l7 7-7 7"></path>
                  </svg>
                </button>
              </div>
            </Link>

            {/* Forum Card */}
            <Link 
              to="/forum" 
              className="bg-white rounded-xl shadow-md overflow-hidden hover:shadow-lg transition-all duration-300 transform hover:-translate-y-1 flex flex-col"
            >
              <div className="p-6 flex-grow">
                <div className="mb-4 transform transition hover:scale-110 duration-300"><ForumIcon /></div>
                <h3 className="text-xl font-bold text-gray-800 mb-2">Community Forum</h3>
                <p className="text-gray-600">
                  Connect with other members, share tips, and join discussions.
                </p>
              </div>
              <div className="px-6 pb-6">
                <button className="w-full py-2 bg-yellow-500 hover:bg-yellow-600 text-white rounded-md transition-colors duration-300 flex items-center justify-center group">
                  <span>Join Conversations</span>
                  <svg className="ml-2 w-5 h-5 transform group-hover:translate-x-1 transition-transform duration-200" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 5l7 7-7 7"></path>
                  </svg>
                </button>
              </div>
            </Link>

            {/* Shop Card */}
            <Link 
              to="/store" 
              className="bg-white rounded-xl shadow-md overflow-hidden hover:shadow-lg transition-all duration-300 transform hover:-translate-y-1 flex flex-col"
            >
              <div className="p-6 flex-grow">
                <div className="mb-4 transform transition hover:scale-110 duration-300"><ShopIcon /></div>
                <h3 className="text-xl font-bold text-gray-800 mb-2">Club Shop</h3>
                <p className="text-gray-600">
                  Purchase official club merchandise, gear, and pay your membership dues.
                </p>
              </div>
              <div className="px-6 pb-6">
                <button className="w-full py-2 bg-yellow-500 hover:bg-yellow-600 text-white rounded-md transition-colors duration-300 flex items-center justify-center group">
                  <span>Go Shopping</span>
                  <svg className="ml-2 w-5 h-5 transform group-hover:translate-x-1 transition-transform duration-200" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 5l7 7-7 7"></path>
                  </svg>
                </button>
              </div>
            </Link>

            {/* Scores Card */}
            <Link 
              to="/scores" 
              className="bg-white rounded-xl shadow-md overflow-hidden hover:shadow-lg transition-all duration-300 transform hover:-translate-y-1 flex flex-col"
            >
              <div className="p-6 flex-grow">
                <div className="mb-4 transform transition hover:scale-110 duration-300"><ScoreIcon /></div>
                <h3 className="text-xl font-bold text-gray-800 mb-2">Tournaments</h3>
                <p className="text-gray-600">
                  View tournament results, submit qualifying scores, and check leaderboards
                </p>
              </div>
              <div className="px-6 pb-6">
                <button className="w-full py-2 bg-yellow-500 hover:bg-yellow-600 text-white rounded-md transition-colors duration-300 flex items-center justify-center group">
                  <span>View Tournaments</span>
                  <svg className="ml-2 w-5 h-5 transform group-hover:translate-x-1 transition-transform duration-200" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 5l7 7-7 7"></path>
                  </svg>
                </button>
              </div>
            </Link>

            {/* Chat Card */}
            <Link 
              to="/chat" 
              className="bg-white rounded-xl shadow-md overflow-hidden hover:shadow-lg transition-all duration-300 transform hover:-translate-y-1 flex flex-col"
            >
              <div className="p-6 flex-grow">
                <div className="mb-4 transform transition hover:scale-110 duration-300"><ChatIcon /></div>
                <h3 className="text-xl font-bold text-gray-800 mb-2">Chat Room</h3>
                <p className="text-gray-600">
                  Real-time messaging with other members currently online.
                </p>
              </div>
              <div className="px-6 pb-6">
                <button className="w-full py-2 bg-yellow-500 hover:bg-yellow-600 text-white rounded-md transition-colors duration-300 flex items-center justify-center group">
                  <span>Start Chatting</span>
                  <svg className="ml-2 w-5 h-5 transform group-hover:translate-x-1 transition-transform duration-200" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 5l7 7-7 7"></path>
                  </svg>
                </button>
              </div>
            </Link>

            {/* Profile Card */}
            <Link 
              to="/account" 
              className="bg-white rounded-xl shadow-md overflow-hidden hover:shadow-lg transition-all duration-300 transform hover:-translate-y-1 flex flex-col"
            >
              <div className="p-6 flex-grow">
                <div className="mb-4 transform transition hover:scale-110 duration-300"><ProfileIcon /></div>
                <h3 className="text-xl font-bold text-gray-800 mb-2">My Account</h3>
                <p className="text-gray-600">
                  Update your profile, manage notifications, and view membership status.
                </p>
              </div>
              <div className="px-6 pb-6">
                <button className="w-full py-2 bg-yellow-500 hover:bg-yellow-600 text-white rounded-md transition-colors duration-300 flex items-center justify-center group">
                  <span>Edit Profile</span>
                  <svg className="ml-2 w-5 h-5 transform group-hover:translate-x-1 transition-transform duration-200" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 5l7 7-7 7"></path>
                  </svg>
                </button>
              </div>
            </Link>
          </div>
        </div>
        
        {/* Subtle wave divider */}
        <div className="absolute bottom-0 left-0 right-0 overflow-hidden">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 120" preserveAspectRatio="none" className="fill-current text-yellow-50 opacity-50" style={{ width: '100%', height: '50px' }}>
            <path d="M985.66,92.83C906.67,72,823.78,31,743.84,14.19c-82.26-17.34-168.06-16.33-250.45.39-57.84,11.73-114,31.07-172,41.86A600.21,600.21,0,0,1,0,27.35V120H1200V95.8C1132.19,118.92,1055.71,111.31,985.66,92.83Z"></path>
          </svg>
        </div>
      </section>

      {/* Club Announcement Section */}
      <section className="py-12 px-4 sm:px-6 lg:px-8 relative">
        <div className="absolute inset-0 opacity-30" style={announcementsBgStyle}></div>
        <div className="max-w-7xl mx-auto relative z-10">
          <div className="bg-white bg-opacity-70 backdrop-filter backdrop-blur-sm rounded-xl overflow-hidden shadow-md">
            <div className="px-6 py-8 md:p-10 bg-yellow-500 md:flex md:items-center md:justify-between relative overflow-hidden">
              {/* Decorative circles */}
              <div className="absolute top-0 right-0 -mt-4 -mr-4 w-20 h-20 rounded-full bg-yellow-400 opacity-50"></div>
              <div className="absolute bottom-0 left-0 -mb-4 -ml-4 w-16 h-16 rounded-full bg-yellow-400 opacity-30"></div>
              
              <div className="relative">
                <h2 className="text-2xl font-bold text-white">Club Announcements</h2>
                <p className="mt-1 text-yellow-100">Stay updated with the latest club news and important announcements.</p>
              </div>
              <div className="mt-4 md:mt-0 relative">
                <span className="inline-flex rounded-md shadow-md">
                  <Link to="/announcements" className="inline-flex items-center px-4 py-2 border border-transparent text-base font-medium rounded-md text-yellow-600 bg-white hover:bg-yellow-50 transition">
                    View All Announcements
                    <svg className="ml-2 w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 5l7 7-7 7"></path>
                    </svg>
                  </Link>
                </span>
              </div>
            </div>
            
            <div className="p-6">
              {loading ? (
                <div className="py-8 text-center">
                  <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-yellow-500 mx-auto"></div>
                  <p className="mt-4 text-gray-600">Loading announcements...</p>
                </div>
              ) : error ? (
                <div className="py-8 text-center text-red-500">
                  <p className="text-lg">{error}</p>
                  <button 
                    className="mt-4 px-4 py-2 bg-yellow-500 text-white rounded-md hover:bg-yellow-600 transition"
                    onClick={() => window.location.reload()}
                  >
                    Try Again
                  </button>
                </div>
              ) : announcements.length === 0 ? (
                <div className="py-12 text-center text-gray-600">
                  <svg className="w-16 h-16 mx-auto text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"></path>
                  </svg>
                  <p className="mt-4 text-lg">No announcements available at this time.</p>
                </div>
              ) : (
                <div className="space-y-6">
                  {announcements.slice(0, 3).map((announcement) => (
                    <div key={announcement.announcementid} className="border-l-4 border-yellow-500 pl-4 py-2 hover:bg-yellow-50 transition-colors duration-200 rounded">
                      <h3 className="font-bold text-gray-800">{announcement.title}</h3>
                      <p className="text-gray-600 text-sm mt-1">{announcement.content}</p>
                      <p className="text-gray-500 text-xs mt-2 flex items-center">
                        <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                        </svg>
                        Posted {formatDate(announcement.createddate)}
                      </p>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      </section>
    </div>
  );
};

export default Home;
