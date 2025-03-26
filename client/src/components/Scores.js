import React, { useState, useEffect } from "react";
import { useDropzone } from 'react-dropzone';
import { useSelector } from 'react-redux';
import { api } from '../config';
import { getStorage, ref as storageRef, uploadBytes, getDownloadURL } from 'firebase/storage';
import { storage } from '../firebase';
import UserAvatar from './UserAvatar';

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
      setLoading(true);
      setUploadProgress(0);

      // Upload image to Firebase Storage
      const file = files[0];
      const imageRef = storageRef(storage, `score_images/${selectedEvent.eventid}/${Date.now()}_${file.name}`);
      await uploadBytes(imageRef, file);
      const imageUrl = await getDownloadURL(imageRef);

      // Prepare score data
      const scoreData = {
        eventid: selectedEvent.eventid,
        userids: selectedPlayers.filter(player => player).join(','),
        scores: playerScores.filter((score, index) => selectedPlayers[index]).join(','),
        scoreimage: imageUrl,
        submissiondate: new Date().toISOString(),
        status: 'pending' // Default status for new submissions
      };

      // Submit score to your API
      const response = await api.post('/scores', scoreData);
      
      console.log("Scores submitted:", response.data);
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

  if (loading) {
    return <div className="text-center py-4">Loading...</div>;
  }

  if (error) {
    return <div className="text-center py-4 text-red-500">{error}</div>;
  }

  return (
    <div className="bg-gray-100 min-h-screen">
      <header className="bg-black text-gold p-6 shadow-md">
        <h1 className="text-3xl font-bold text-center">Tournament Scores</h1>
      </header>
      
      <main className="max-w-4xl mx-auto p-6">
        {/* Tournaments List */}
        <div className="mb-8">
          <h2 className="text-2xl font-semibold mb-4">Available Tournaments</h2>
          {events.length === 0 ? (
            <p className="text-gray-500 text-center">No tournaments available.</p>
          ) : (
            <div className="grid gap-4 md:grid-cols-2">
              {events.map(event => (
                <div 
                  key={event.eventid} 
                  className="bg-white p-6 rounded-lg shadow-md border border-gray-200"
                >
                  <h3 className="text-xl font-semibold mb-2">{event.eventname}</h3>
                  <p className="text-gray-600 mb-2">
                    Date: {new Date(event.eventdate).toLocaleDateString()}
                  </p>
                  <p className="text-gray-600 mb-4">
                    Location: {event.eventlocation}
                  </p>
                  <button
                    onClick={() => handleOpenSubmitModal(event)}
                    className="w-full bg-gold text-black py-2 px-4 rounded hover:bg-yellow-600 transition"
                  >
                    Submit Qualifying Score
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>
      </main>

      {/* Score Submission Modal */}
      {showSubmitModal && selectedEvent && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-xl font-bold">Submit Score for {selectedEvent.eventname}</h2>
              <button 
                onClick={() => setShowSubmitModal(false)}
                className="text-gray-500 hover:text-gray-700"
              >
                ✕
              </button>
            </div>

            {/* File Upload */}
            <div 
              {...getRootProps()} 
              className={`border-dashed border-2 ${files.length ? 'border-green-300 bg-green-50' : 'border-gray-300'} p-4 mb-4 cursor-pointer hover:border-blue-300 transition-colors`}
            >
              <input {...getInputProps()} />
              {files.length ? (
                <div className="text-center">
                  <p className="text-green-600">✓ Image selected</p>
                  <p className="text-sm text-gray-500">{files[0].name}</p>
                  {uploadProgress > 0 && uploadProgress < 100 && (
                    <div className="w-full bg-gray-200 rounded-full h-2.5 mt-2">
                      <div 
                        className="bg-green-600 h-2.5 rounded-full" 
                        style={{ width: `${uploadProgress}%` }}
                      ></div>
                    </div>
                  )}
                </div>
              ) : (
                <div className="text-center">
                  <p>Drag and drop a score image here, or click to select</p>
                  <p className="text-sm text-gray-500 mt-1">Maximum file size: 5MB</p>
                </div>
              )}
            </div>

            {/* Player Selection and Scores */}
            {[0, 1, 2, 3].map(index => (
              <div key={index} className="mb-4">
                <select
                  value={selectedPlayers[index] || ""}
                  onChange={(e) => {
                    const newPlayers = [...selectedPlayers];
                    newPlayers[index] = e.target.value;
                    setSelectedPlayers(newPlayers);
                  }}
                  className="w-full p-2 border border-gray-300 rounded mb-2"
                >
                  <option value="">Select Player</option>
                  {users.map(user => (
                    <option key={user.id} value={user.id}>
                      {user.firstname} {user.lastname}
                    </option>
                  ))}
                </select>
                <input
                  type="number"
                  placeholder="Enter score"
                  value={playerScores[index]}
                  onChange={(e) => {
                    const newScores = [...playerScores];
                    newScores[index] = e.target.value;
                    setPlayerScores(newScores);
                  }}
                  className="w-full p-2 border border-gray-300 rounded"
                  disabled={!selectedPlayers[index]}
                />
              </div>
            ))}
            
            <div className="flex justify-end space-x-2 mt-4">
              <button
                onClick={() => setShowSubmitModal(false)}
                className="px-4 py-2 border border-gray-300 rounded hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                onClick={handleScoreSubmit}
                disabled={loading || !files.length}
                className={`px-6 py-2 rounded ${
                  loading || !files.length
                    ? 'bg-gray-400 cursor-not-allowed' 
                    : 'bg-gold text-black hover:bg-yellow-600'
                }`}
              >
                {loading ? 'Submitting...' : 'Submit Score'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default ScoresPage;
