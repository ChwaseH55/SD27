import React, { useState, useEffect } from "react";
import { useDropzone } from 'react-dropzone';
import { useSelector } from 'react-redux';
import { api } from '../config';
import { getStorage, ref as storageRef, uploadBytes, getDownloadURL } from 'firebase/storage';
import { storage } from '../firebase';
import UserAvatar from './UserAvatar';

// Background pattern for tournaments
const bgStyle = {
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

// Define animation keyframes as a styled string
const animationStyle = `
  @keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
  }
  .animate-fadeIn {
    animation: fadeIn 0.3s ease-out;
  }
`;

const ScoresPage = () => {
  const [events, setEvents] = useState([]);
  const [selectedEvent, setSelectedEvent] = useState(null);
  const [selectedPlayers, setSelectedPlayers] = useState([null, null, null, null]);
  const [playerScores, setPlayerScores] = useState(["", "", "", ""]);
  const [files, setFiles] = useState([]);
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [showSubmitModal, setShowSubmitModal] = useState(false);
  const [showLeaderboardModal, setShowLeaderboardModal] = useState(false);
  const [eventLeaderboard, setEventLeaderboard] = useState([]);
  const [leaderboardLoading, setLeaderboardLoading] = useState(false);
  const [uploadProgress, setUploadProgress] = useState(0);
  const storage = getStorage();

  useEffect(() => {
    // Fetch users and events
    const fetchInitialData = async () => {
      setLoading(true);
      setError(null);
      try {
        const [usersResponse, eventsResponse] = await Promise.all([
          api.get('/users'),
          api.get('/events')
        ]);
        
        setUsers(usersResponse.data);
        // Filter events to only include tournaments
        const tournamentEvents = eventsResponse.data.filter(event => 
          event.eventname.toLowerCase().includes('tournament')
        );
        setEvents(tournamentEvents);
      } catch (error) {
        console.error("Error fetching initial data:", error);
        setError("Failed to load data. Please try again later.");
      } finally {
        setLoading(false);
      }
    };

    fetchInitialData();
  }, []);

  const fetchLeaderboard = async (eventId) => {
    setLeaderboardLoading(true);
    try {
      // This would be replaced with an actual API call to get scores for a specific event
      // const response = await api.get(`/scores/events/${eventId}`);
      
      // For now, let's create some sample data
      setTimeout(() => {
        const sampleLeaderboard = [
          { id: 1, firstName: 'John', lastName: 'Doe', score: 72, average: 74.5 },
          { id: 2, firstName: 'Jane', lastName: 'Smith', score: 68, average: 70.2 },
          { id: 3, firstName: 'Mike', lastName: 'Johnson', score: 75, average: 76.1 },
          { id: 4, firstName: 'Sarah', lastName: 'Williams', score: 70, average: 72.8 },
          { id: 5, firstName: 'David', lastName: 'Brown', score: 69, average: 71.3 },
          { id: 6, firstName: 'Emily', lastName: 'Davis', score: 73, average: 75.0 },
        ];
        
        setEventLeaderboard(sampleLeaderboard);
        setLeaderboardLoading(false);
      }, 1000);
    } catch (error) {
      console.error("Error fetching leaderboard:", error);
      setLeaderboardLoading(false);
    }
  };

  const handleOpenLeaderboardModal = (event) => {
    setSelectedEvent(event);
    setShowLeaderboardModal(true);
    fetchLeaderboard(event.eventid);
  };

  const handleScoreSubmit = async () => {
    // Validate inputs
    if (!selectedEvent) {
      alert("Please select an event");
      return;
    }
    
    if (!selectedPlayers.some(player => player) || !playerScores.some(score => score)) {
      alert("Please select at least one player and enter their score");
      return;
    }

    if (!files.length) {
      alert("Please upload a score image");
      return;
    }

    try {
      console.log("Starting score submission process...");
      setLoading(true);
      setUploadProgress(0);

      // Upload image to Firebase Storage
      const file = files[0];
      console.log("Preparing to upload file:", file.name);
      const imageRef = storageRef(storage, `score_images/${selectedEvent.eventid}/${Date.now()}_${file.name}`);
      console.log("Created Firebase storage reference:", imageRef.fullPath);
      
      console.log("Uploading file to Firebase Storage...");
      await uploadBytes(imageRef, file);
      console.log("File uploaded successfully to Firebase Storage");
      
      console.log("Getting download URL...");
      const imageUrl = await getDownloadURL(imageRef);
      console.log("Got download URL:", imageUrl);

      // Prepare score data
      const scoreData = {
        eventid: selectedEvent.eventid,
        userids: selectedPlayers.filter(player => player).join(','),
        scores: playerScores.filter((score, index) => selectedPlayers[index]).join(','),
        scoreimage: imageUrl,
        submissiondate: new Date().toISOString(),
        status: 'pending' // Default status for new submissions
      };
      console.log("Prepared score data:", scoreData);

      // Submit score to your API
      console.log("Making API call to /scores endpoint...");
      const response = await api.post('/scores', scoreData);
      console.log("API response received:", response.data);
      
      alert("Scores submitted for approval!");
      
      // Reset form
      setSelectedEvent(null);
      setSelectedPlayers([null, null, null, null]);
      setPlayerScores(["", "", "", ""]);
      setFiles([]);
      setShowSubmitModal(false);
      setUploadProgress(0);
    } catch (error) {
      console.error("Error submitting scores:", error);
      console.error("Error details:", {
        message: error.message,
        response: error.response?.data,
        status: error.response?.status,
        config: {
          url: error.config?.url,
          method: error.config?.method,
          headers: error.config?.headers
        }
      });
      alert("Failed to submit scores. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  const onDrop = (acceptedFiles) => {
    // Validate file size (e.g., max 5MB)
    const maxSize = 5 * 1024 * 1024; // 5MB in bytes
    const file = acceptedFiles[0];
    
    if (file.size > maxSize) {
      alert("File is too large. Maximum size is 5MB.");
      return;
    }

    setFiles(acceptedFiles);
  };

  const { getRootProps, getInputProps } = useDropzone({
    onDrop,
    accept: 'image/*',
    maxFiles: 1,
    maxSize: 5 * 1024 * 1024 // 5MB in bytes
  });

  const handleOpenSubmitModal = (event) => {
    setSelectedEvent(event);
    setShowSubmitModal(true);
  };

  const ScoreCard = ({ score }) => {
    const [imageLoaded, setImageLoaded] = useState(false);
    const [showFullImage, setShowFullImage] = useState(false);

    return (
      <div className="bg-white rounded-lg shadow-md p-4 mb-4">
        <div className="flex items-center mb-4">
          <UserAvatar 
            user={{
              id: score.userId,
              firstname: score.userName?.split(' ')[0] || '',
              lastname: score.userName?.split(' ')[1] || '',
              profilePicture: score.userProfilePicture
            }}
            size="sm"
          />
          <div className="ml-3">
            <h3 className="font-semibold">{score.userName}</h3>
            <p className="text-sm text-gray-500">
              {new Date(score.createdAt).toLocaleDateString()}
            </p>
          </div>
          <div className="ml-auto">
            <span className="text-2xl font-bold text-blue-600">
              {score.score}
            </span>
          </div>
        </div>
        
        {score.image && (
          <div 
            className="relative cursor-pointer" 
            onClick={() => setShowFullImage(!showFullImage)}
          >
            <img
              src={score.image}
              alt="Score submission"
              className={`w-full rounded-lg transition-all duration-300 ${
                showFullImage ? 'max-h-none' : 'max-h-48 object-cover'
              }`}
              onLoad={() => setImageLoaded(true)}
            />
            {!showFullImage && imageLoaded && (
              <div className="absolute bottom-0 left-0 right-0 text-center p-2 bg-black bg-opacity-50 text-white rounded-b-lg">
                Click to expand
              </div>
            )}
          </div>
        )}
        
        {score.description && (
          <p className="mt-4 text-gray-700">{score.description}</p>
        )}
      </div>
    );
  };

  if (loading && events.length === 0) {
    return (
      <div className="flex flex-col min-h-screen" style={bgStyle}>
        {/* Hero Section with Title */}
        <header className="relative pt-24 pb-16 px-4 sm:px-6 lg:px-8 bg-gradient-to-r from-yellow-500 to-yellow-600 text-white overflow-hidden">
          {/* Pattern overlay */}
          <div className="absolute inset-0 opacity-20" style={heroBgStyle}></div>
          <div className="max-w-7xl mx-auto">
            <div className="text-center">
              <h1 className="text-4xl md:text-5xl font-bold">Tournament Scores</h1>
              <p className="mt-3 text-lg md:text-xl text-yellow-100 max-w-3xl mx-auto">
                View tournament results, submit qualifying scores, and check leaderboards
              </p>
            </div>
          </div>
          
          {/* Wave SVG divider */}
          <div className="absolute bottom-0 left-0 right-0 overflow-hidden">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 120" preserveAspectRatio="none" className="fill-current text-gray-50" style={{ width: '100%', height: '50px' }}>
              <path d="M321.39,56.44c58-10.79,114.16-30.13,172-41.86,82.39-16.72,168.19-17.73,250.45-.39C823.78,31,906.67,72,985.66,92.83c70.05,18.48,146.53,26.09,214.34,3V0H0V27.35A600.21,600.21,0,0,0,321.39,56.44Z"></path>
            </svg>
          </div>
        </header>

        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <div className="text-center">
            <div className="animate-spin rounded-full h-16 w-16 border-t-2 border-b-2 border-yellow-500 mx-auto"></div>
            <p className="mt-4 text-gray-600">Loading tournaments...</p>
          </div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex flex-col min-h-screen" style={bgStyle}>
        {/* Hero Section with Title */}
        <header className="relative pt-24 pb-16 px-4 sm:px-6 lg:px-8 bg-gradient-to-r from-yellow-500 to-yellow-600 text-white overflow-hidden">
          {/* Pattern overlay */}
          <div className="absolute inset-0 opacity-20" style={heroBgStyle}></div>
          <div className="max-w-7xl mx-auto">
            <div className="text-center">
              <h1 className="text-4xl md:text-5xl font-bold">Tournament Scores</h1>
              <p className="mt-3 text-lg md:text-xl text-yellow-100 max-w-3xl mx-auto">
                View tournament results, submit qualifying scores, and check leaderboards
              </p>
            </div>
          </div>
          
          {/* Wave SVG divider */}
          <div className="absolute bottom-0 left-0 right-0 overflow-hidden">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 120" preserveAspectRatio="none" className="fill-current text-gray-50" style={{ width: '100%', height: '50px' }}>
              <path d="M321.39,56.44c58-10.79,114.16-30.13,172-41.86,82.39-16.72,168.19-17.73,250.45-.39C823.78,31,906.67,72,985.66,92.83c70.05,18.48,146.53,26.09,214.34,3V0H0V27.35A600.21,600.21,0,0,0,321.39,56.44Z"></path>
            </svg>
          </div>
        </header>

        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <div className="bg-white rounded-xl shadow-md p-8 text-center">
            <svg className="w-16 h-16 text-red-500 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
            </svg>
            <p className="text-xl text-red-500 font-medium mb-2">{error}</p>
            <p className="text-gray-600 mb-4">We encountered an issue loading the tournaments. Please try again.</p>
            <button 
              className="px-4 py-2 bg-yellow-500 text-white rounded-md hover:bg-yellow-600 transition-colors shadow-sm"
              onClick={() => window.location.reload()}
            >
              Refresh Page
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="flex flex-col min-h-screen" style={bgStyle}>
      {/* Inject custom animations */}
      <style dangerouslySetInnerHTML={{ __html: animationStyle }} />
      
      {/* Hero Section with Title */}
      <header className="relative pt-24 pb-16 px-4 sm:px-6 lg:px-8 bg-gradient-to-r from-yellow-500 to-yellow-600 text-white overflow-hidden">
        {/* Pattern overlay */}
        <div className="absolute inset-0 opacity-20" style={heroBgStyle}></div>
        <div className="max-w-7xl mx-auto">
          <div className="text-center">
            <h1 className="text-4xl md:text-5xl font-bold">Tournament Scores</h1>
            <p className="mt-3 text-lg md:text-xl text-yellow-100 max-w-3xl mx-auto">
              View tournament results, submit qualifying scores, and check leaderboards
            </p>
          </div>
        </div>
        
        {/* Wave SVG divider */}
        <div className="absolute bottom-0 left-0 right-0 overflow-hidden">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 120" preserveAspectRatio="none" className="fill-current text-gray-50" style={{ width: '100%', height: '50px' }}>
            <path d="M321.39,56.44c58-10.79,114.16-30.13,172-41.86,82.39-16.72,168.19-17.73,250.45-.39C823.78,31,906.67,72,985.66,92.83c70.05,18.48,146.53,26.09,214.34,3V0H0V27.35A600.21,600.21,0,0,0,321.39,56.44Z"></path>
          </svg>
        </div>
      </header>
      
      <main className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-10 mb-16">
        {/* Tournaments List */}
        <div className="mb-12">
          <h2 className="text-2xl font-bold text-gray-800 mb-6">Available Tournaments</h2>
          {events.length === 0 ? (
            <div className="bg-white rounded-xl shadow-md p-8 text-center">
              <svg className="w-16 h-16 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/>
              </svg>
              <p className="text-lg font-medium text-gray-800 mb-2">No Tournaments Available</p>
              <p className="text-gray-600">Check back later for upcoming tournament events.</p>
            </div>
          ) : (
            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
              {events.map(event => (
                <div 
                  key={event.eventid} 
                  className="bg-white rounded-xl shadow-md overflow-hidden transition-all duration-300 transform hover:-translate-y-1 hover:shadow-lg"
                >
                  <div className="bg-yellow-500 h-2"></div>
                  <div className="p-6">
                    <h3 className="text-xl font-bold text-gray-800 mb-3">{event.eventname}</h3>
                    <div className="flex items-center text-gray-600 mb-2">
                      <svg className="w-5 h-5 mr-2 text-yellow-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                      </svg>
                      <span>{new Date(event.eventdate).toLocaleDateString(undefined, {
                        weekday: 'long',
                        year: 'numeric',
                        month: 'long',
                        day: 'numeric'
                      })}</span>
                    </div>
                    <div className="flex items-center text-gray-600 mb-4">
                      <svg className="w-5 h-5 mr-2 text-yellow-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/>
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/>
                      </svg>
                      <span>{event.eventlocation}</span>
                    </div>
                    <div className="flex space-x-3">
                      <button
                        onClick={() => handleOpenSubmitModal(event)}
                        className="flex-1 bg-yellow-500 text-white py-2 px-4 rounded-md hover:bg-yellow-600 transition-colors flex items-center justify-center"
                      >
                        <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4v16m8-8H4"/>
                        </svg>
                        Submit Score
                      </button>
                      <button
                        onClick={() => handleOpenLeaderboardModal(event)}
                        className="flex-1 border border-yellow-500 text-yellow-600 py-2 px-4 rounded-md hover:bg-yellow-50 transition-colors flex items-center justify-center"
                      >
                        <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
                        </svg>
                        Leaderboard
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </main>

      {/* Score Submission Modal */}
      {showSubmitModal && selectedEvent && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50 animate-fadeIn">
          <div className="bg-white rounded-xl shadow-xl w-full max-w-2xl max-h-[90vh] overflow-y-auto">
            <div className="bg-gradient-to-r from-yellow-500 to-yellow-600 text-white px-6 py-4 rounded-t-xl">
              <div className="flex justify-between items-center">
                <h2 className="text-xl font-bold">Submit Score for {selectedEvent.eventname}</h2>
                <button 
                  onClick={() => setShowSubmitModal(false)}
                  className="text-white hover:text-yellow-200 transition-colors"
                >
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
            </div>
            
            <div className="p-6">
              <div className="mb-6">
                <h3 className="text-lg font-semibold text-gray-700 mb-2">Tournament Details</h3>
                <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
                  <div className="flex items-center text-gray-600 mb-2">
                    <svg className="w-5 h-5 mr-2 text-yellow-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                    </svg>
                    <span>{new Date(selectedEvent.eventdate).toLocaleDateString(undefined, {
                      weekday: 'long',
                      year: 'numeric',
                      month: 'long',
                      day: 'numeric'
                    })}</span>
                  </div>
                  <div className="flex items-center text-gray-600">
                    <svg className="w-5 h-5 mr-2 text-yellow-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/>
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/>
                    </svg>
                    <span>{selectedEvent.eventlocation}</span>
                  </div>
                </div>
              </div>
              
              <div className="mb-6">
                <h3 className="text-lg font-semibold text-gray-700 mb-2">Upload Score Card</h3>
                <div 
                  {...getRootProps()} 
                  className={`border-dashed border-2 rounded-lg ${files.length ? 'border-green-300 bg-green-50' : 'border-gray-300'} p-6 cursor-pointer hover:border-yellow-400 transition-colors text-center`}
                >
                  <input {...getInputProps()} />
                  {files.length ? (
                    <div className="text-center">
                      <svg className="w-12 h-12 mx-auto text-green-500 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                      </svg>
                      <p className="text-green-600 font-medium">Image Selected</p>
                      <p className="text-sm text-gray-500 mt-1">{files[0].name}</p>
                      {uploadProgress > 0 && uploadProgress < 100 && (
                        <div className="w-full bg-gray-200 rounded-full h-2.5 mt-3">
                          <div 
                            className="bg-green-600 h-2.5 rounded-full" 
                            style={{ width: `${uploadProgress}%` }}
                          ></div>
                        </div>
                      )}
                    </div>
                  ) : (
                    <div>
                      <svg className="w-12 h-12 mx-auto text-gray-400 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                      </svg>
                      <p className="text-gray-700">Drag and drop a score image here, or click to select</p>
                      <p className="text-sm text-gray-500 mt-1">Maximum file size: 5MB</p>
                    </div>
                  )}
                </div>
              </div>

              <div className="mb-6">
                <h3 className="text-lg font-semibold text-gray-700 mb-2">Player Scores</h3>
                <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
                  {[0, 1, 2, 3].map(index => (
                    <div key={index} className="mb-4 last:mb-0">
                      <label className="block text-sm font-medium text-gray-700 mb-1">Player {index + 1}</label>
                      <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
                        <div className="md:col-span-2">
                          <select
                            value={selectedPlayers[index] || ""}
                            onChange={(e) => {
                              const newPlayers = [...selectedPlayers];
                              newPlayers[index] = e.target.value;
                              setSelectedPlayers(newPlayers);
                            }}
                            className="w-full p-3 border border-gray-300 rounded-md focus:ring-yellow-500 focus:border-yellow-500"
                          >
                            <option value="">Select Player</option>
                            {users.map(user => (
                              <option key={user.id} value={user.id}>
                                {user.firstname} {user.lastname}
                              </option>
                            ))}
                          </select>
                        </div>
                        <div>
                          <input
                            type="number"
                            placeholder="Score"
                            value={playerScores[index]}
                            onChange={(e) => {
                              const newScores = [...playerScores];
                              newScores[index] = e.target.value;
                              setPlayerScores(newScores);
                            }}
                            className="w-full p-3 border border-gray-300 rounded-md focus:ring-yellow-500 focus:border-yellow-500"
                            disabled={!selectedPlayers[index]}
                          />
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
              
              <div className="flex justify-end space-x-3 mt-6">
                <button
                  onClick={() => setShowSubmitModal(false)}
                  className="px-5 py-2.5 border border-gray-300 rounded-md font-medium text-gray-700 hover:bg-gray-50 transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={handleScoreSubmit}
                  disabled={loading || !files.length}
                  className={`px-5 py-2.5 rounded-md font-medium ${
                    loading || !files.length
                      ? 'bg-gray-400 cursor-not-allowed text-gray-200' 
                      : 'bg-yellow-500 text-white hover:bg-yellow-600'
                  } transition-colors shadow-sm flex items-center`}
                >
                  {loading ? (
                    <>
                      <svg className="animate-spin -ml-1 mr-2 h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
                        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                        <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                      </svg>
                      Submitting...
                    </>
                  ) : (
                    <>
                      Submit Score
                    </>
                  )}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Leaderboard Modal */}
      {showLeaderboardModal && selectedEvent && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50 animate-fadeIn">
          <div className="bg-white rounded-xl shadow-xl w-full max-w-4xl max-h-[90vh] overflow-y-auto">
            <div className="bg-gradient-to-r from-yellow-500 to-yellow-600 text-white px-6 py-4 rounded-t-xl">
              <div className="flex justify-between items-center">
                <h2 className="text-xl font-bold">Leaderboard: {selectedEvent.eventname}</h2>
                <button 
                  onClick={() => setShowLeaderboardModal(false)}
                  className="text-white hover:text-yellow-200 transition-colors"
                >
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
            </div>
            
            <div className="p-6">
              <div className="mb-6">
                <h3 className="text-lg font-semibold text-gray-700 mb-2">Tournament Details</h3>
                <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
                  <div className="flex items-center text-gray-600 mb-2">
                    <svg className="w-5 h-5 mr-2 text-yellow-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                    </svg>
                    <span>{new Date(selectedEvent.eventdate).toLocaleDateString(undefined, {
                      weekday: 'long',
                      year: 'numeric',
                      month: 'long',
                      day: 'numeric'
                    })}</span>
                  </div>
                  <div className="flex items-center text-gray-600">
                    <svg className="w-5 h-5 mr-2 text-yellow-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/>
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/>
                    </svg>
                    <span>{selectedEvent.eventlocation}</span>
                  </div>
                </div>
              </div>
              
              {leaderboardLoading ? (
                <div className="py-12 text-center">
                  <div className="animate-spin rounded-full h-16 w-16 border-t-2 border-b-2 border-yellow-500 mx-auto"></div>
                  <p className="mt-4 text-gray-600">Loading leaderboard...</p>
                </div>
              ) : eventLeaderboard.length === 0 ? (
                <div className="bg-white rounded-xl shadow-md p-8 text-center">
                  <svg className="w-16 h-16 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
                  </svg>
                  <p className="text-lg font-medium text-gray-800 mb-2">No Scores Available</p>
                  <p className="text-gray-600">There are no approved scores for this tournament yet.</p>
                </div>
              ) : (
                <div className="overflow-x-auto">
                  <table className="min-w-full bg-white rounded-lg overflow-hidden">
                    <thead className="bg-gray-100 text-gray-700">
                      <tr className="text-left">
                        <th className="py-3 px-4 font-semibold">Rank</th>
                        <th className="py-3 px-4 font-semibold">Player</th>
                        <th className="py-3 px-4 font-semibold text-center">Score</th>
                        <th className="py-3 px-4 font-semibold text-center">Avg. Score</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-200">
                      {eventLeaderboard
                        .sort((a, b) => a.score - b.score)
                        .map((player, index) => (
                          <tr key={player.id} className="hover:bg-gray-50">
                            <td className="py-3 px-4 font-medium">
                              {index === 0 ? (
                                <span className="flex items-center text-yellow-500">
                                  <svg className="w-5 h-5 mr-1" fill="currentColor" viewBox="0 0 20 20">
                                    <path fillRule="evenodd" d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" clipRule="evenodd"/>
                                  </svg>
                                  1st
                                </span>
                              ) : index === 1 ? (
                                <span className="flex items-center text-gray-500">
                                  <svg className="w-5 h-5 mr-1" fill="currentColor" viewBox="0 0 20 20">
                                    <path fillRule="evenodd" d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" clipRule="evenodd"/>
                                  </svg>
                                  2nd
                                </span>
                              ) : index === 2 ? (
                                <span className="flex items-center text-yellow-700">
                                  <svg className="w-5 h-5 mr-1" fill="currentColor" viewBox="0 0 20 20">
                                    <path fillRule="evenodd" d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" clipRule="evenodd"/>
                                  </svg>
                                  3rd
                                </span>
                              ) : (
                                `${index + 1}th`
                              )}
                            </td>
                            <td className="py-3 px-4">{player.firstName} {player.lastName}</td>
                            <td className="py-3 px-4 text-center font-semibold">{player.score}</td>
                            <td className="py-3 px-4 text-center text-gray-600">{player.average}</td>
                          </tr>
                        ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default ScoresPage;
