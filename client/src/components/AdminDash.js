import React, { useState, useEffect } from "react";
import { api } from '../config';  // Import our configured api instance
import { useSelector } from 'react-redux'; // Import useSelector to access Redux state
import { storage } from '../firebase';
import { ref, getDownloadURL } from 'firebase/storage';

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

// CSS for animations
const globalStyles = `
  @keyframes float {
    0% { transform: translateY(0px); }
    50% { transform: translateY(-10px); }
    100% { transform: translateY(0px); }
  }
  @keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
  }
`;

const AdminDashboard = () => {
  // Get the current user from Redux store
  const currentUser = useSelector(state => state.user.user);
  const userId = currentUser ? currentUser.id : 1; // Use the current user's ID or default to 1

  const [forumPosts, setForumPosts] = useState([]);
  const [users, setUsers] = useState([]);
  const [events, setEvents] = useState([]);
  const [scoreSubmissions, setScoreSubmissions] = useState([]);
  const [isForumPostsVisible, setIsForumPostsVisible] = useState(false);
  const [isUsersVisible, setIsUsersVisible] = useState(false);
  const [isEventsVisible, setIsEventsVisible] = useState(false);
  const [isCreatingEvent, setIsCreatingEvent] = useState(false);
  const [isEditingEvent, setIsEditingEvent] = useState(null);
  const [newEvent, setNewEvent] = useState({
    event_name: "",
    event_date: "",
    event_location: "",
    event_type: "",
    requires_registration: false,
    created_by_user_id: userId, // Use the current user's ID
    event_description: "",
  });
  const [announcement, setAnnouncement] = useState({
    title: "",
    content: "",
    userid: userId // Use the current user's ID
  });
  const [isCreatingAnnouncement, setIsCreatingAnnouncement] = useState(false);
  const [searchUserQuery, setSearchUserQuery] = useState('');
  const [searchForumQuery, setSearchForumQuery] = useState('');
  const [searchScoreQuery, setSearchScoreQuery] = useState('');
  const [selectedScore, setSelectedScore] = useState(null);
  const [showScoreModal, setShowScoreModal] = useState(false);
  const [scoreImageUrl, setScoreImageUrl] = useState(null);
  const [isLoadingImage, setIsLoadingImage] = useState(false);

  // Update event and announcement user IDs when the current user changes
  useEffect(() => {
    setNewEvent(prev => ({ ...prev, created_by_user_id: userId }));
    setAnnouncement(prev => ({ ...prev, userid: userId }));
  }, [userId]);

  // Fetch forum posts, users, events, and score submissions from API
  useEffect(() => {
    const fetchData = async () => {
      try {
        console.log("Fetching data...");
        const [forumResponse, usersResponse, eventsResponse, scoresResponse] = await Promise.all([
          api.get("/forum/posts"),
          api.get("/users"),
          api.get("/events"),
          api.get("/scores/pending"),
        ]);

        console.log("Scores response:", scoresResponse.data);
        setForumPosts(forumResponse.data);
        setUsers(usersResponse.data);
        setEvents(eventsResponse.data);
        setScoreSubmissions(scoresResponse.data);
      } catch (error) {
        console.error("Error fetching data:", error);
        console.error("Error details:", {
          message: error.message,
          response: error.response?.data,
          status: error.response?.status
        });
      }
    };

    fetchData();
  }, []);

  // Handle event form changes
  const handleEventChange = (e) => {
    setNewEvent({
      ...newEvent,
      [e.target.name]: e.target.value,
    });
  };

  // Create a new event
  const handleCreateEvent = async (e) => {
    e.preventDefault();
    try {
      const response = await api.post("/events", newEvent);
      setEvents([...events, response.data]);
      setNewEvent({
        event_name: "",
        event_date: "",
        event_location: "",
        event_type: "",
        requires_registration: false,
        created_by_user_id: userId, // Use the current user's ID
        event_description: "",
      });
      setIsCreatingEvent(false);
    } catch (error) {
      console.error("Error creating event:", error);
    }
  };

    // Toggle to show the event creation form
    const handleCreateEventClick = () => {
      setIsCreatingEvent(true);
      setIsEditingEvent(null); // Clear editing state if switching to create
    };

  // Update an existing event
  const handleUpdateEvent = async (e) => {
    e.preventDefault();
    try {
      const response = await api.put(`/events/${isEditingEvent}`, newEvent);
      setEvents(events.map(event => event.eventid === response.data.eventid ? response.data : event));
      setIsEditingEvent(null);
      setNewEvent({
        event_name: "",
        event_date: "",
        event_location: "",
        event_type: "",
        requires_registration: false,
        event_description: "",
      });
    } catch (error) {
      console.error("Error updating event:", error);
    }
  };

  // Handle event deletion
  const handleDeleteEvent = async (eventId) => {
    try {
      await api.delete(`/events/${eventId}`);
      setEvents(events.filter(event => event.eventid !== eventId));
    } catch (error) {
      console.error("Error deleting event:", error);
    }
  };

  // Handle deleting a forum post
  const handleDeletePost = async (postId) => {
    try {
      await api.delete(`/forum/posts/${postId}`);
      setForumPosts((prevPosts) => prevPosts.filter((post) => post.postid !== postId));
      alert("Post deleted successfully!");
    } catch (error) {
      console.error("Error deleting post:", error);
      alert("Failed to delete the post. Please try again.");
    }
  };

  // Toggle to show the announcement creation form
  const handleCreateAnnouncementClick = () => {
    setIsCreatingAnnouncement(true);
  };

  // Create an announcement
  const handleCreateAnnouncement = async (e) => {
    e.preventDefault();
    try {
      const response = await api.post('/announcements', announcement);
      alert('Announcement created successfully!');
      setAnnouncement({
        title: "",
        content: "",
        userid: userId // Use the current user's ID
      });
      setIsCreatingAnnouncement(false);
    } catch (error) {
      console.error("Error creating announcement:", error);
    }
  };

  // Update user role
  const handleUpdateUserRole = async (userId, newRoleId) => {
    try {
      // Use the general user update endpoint with the roleid field
      const response = await api.put(`/users/${userId}`, { roleid: newRoleId });
      setUsers(users.map(user => user.id === userId ? { ...user, roleid: newRoleId } : user));
      alert('User role updated successfully!');
    } catch (error) {
      console.error("Error updating user role:", error);
    }
  };

  // Add handlers for score approval/rejection
  const handleApproveScore = async (scoreId) => {
    try {
      await api.put('/scores/approve', { scoreid: scoreId });
      setScoreSubmissions(scoreSubmissions.filter(score => score.scoreid !== scoreId));
      alert('Score approved successfully!');
    } catch (error) {
      console.error("Error approving score:", error);
      alert('Failed to approve score. Please try again.');
    }
  };

  const handleRejectScore = async (scoreId) => {
    try {
      await api.put('/scores/not-approve', { scoreid: scoreId });
      setScoreSubmissions(scoreSubmissions.filter(score => score.scoreid !== scoreId));
      alert('Score rejected successfully!');
    } catch (error) {
      console.error("Error rejecting score:", error);
      alert('Failed to reject score. Please try again.');
    }
  };

  // Filter functions for search
  const filteredUsers = users.filter(user => 
    user.username.toLowerCase().includes(searchUserQuery.toLowerCase()) ||
    user.email.toLowerCase().includes(searchUserQuery.toLowerCase())
  );

  const filteredForumPosts = forumPosts.filter(post =>
    post.title.toLowerCase().includes(searchForumQuery.toLowerCase()) ||
    post.content.toLowerCase().includes(searchForumQuery.toLowerCase())
  );

  const filteredScoreSubmissions = scoreSubmissions.filter(score =>
    score.userid.toString().includes(searchScoreQuery) ||
    score.eventid.toString().includes(searchScoreQuery)
  );

  // Helper function to get user name
  const getUserName = (userId) => {
    const user = users.find(u => u.id === userId);
    return user ? `${user.firstname} ${user.lastname}` : `User ${userId}`;
  };

  // Helper function to get event name
  const getEventName = (eventId) => {
    const event = events.find(e => e.eventid === eventId);
    return event ? event.eventname : `Event ${eventId}`;
  };

  // Add function to handle viewing scorecard
  const handleViewScorecard = async (score) => {
    setSelectedScore(score);
    setShowScoreModal(true);
    setIsLoadingImage(true);
    
    try {
      // The scorecard image URL is stored directly in the scoreimage field
      if (!score.scoreimage) {
        throw new Error('No scorecard image found');
      }
      // If the scoreimage is already a URL, use it directly
      if (score.scoreimage.startsWith('http')) {
        setScoreImageUrl(score.scoreimage);
      } else {
        // If it's a Firebase Storage path, get the download URL
        const imageRef = ref(storage, score.scoreimage);
        const url = await getDownloadURL(imageRef);
        setScoreImageUrl(url);
      }
    } catch (error) {
      console.error('Error loading scorecard image:', error);
      alert('Failed to load scorecard image. Please try again.');
    } finally {
      setIsLoadingImage(false);
    }
  };

  return (
    <div className="min-h-screen pt-20" style={mainBgStyle}>
      {/* Inject global styles */}
      <style dangerouslySetInnerHTML={{ __html: globalStyles }} />
      
      {/* Header Section */}
      <div className="relative bg-gradient-to-r from-yellow-500 to-yellow-600 py-12 px-4 sm:px-6 lg:px-8">
        <div className="absolute inset-0" style={heroBgStyle}></div>
        <div className="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTkyMCIgaGVpZ2h0PSIxMDgwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPjxkZWZzPjxwYXR0ZXJuIGlkPSJzd2lybCIgd2lkdGg9IjQwIiBoZWlnaHQ9IjQwIiBwYXR0ZXJuVW5pdHM9InVzZXJTcGFjZU9uVXNlIj48cGF0aCBkPSJNIDQwIDAgTCAwIDAgMCA0MCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSIjZmZmIiBzdHJva2Utd2lkdGg9IjEiIG9wYWNpdHk9IjAuMSIvPjwvcGF0dGVybj48L2RlZnM+PHJlY3Qgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgZmlsbD0idXJsKCNzd2lybCkiLz48L3N2Zz4=')] opacity-10"></div>
        <div className="relative max-w-7xl mx-auto text-center">
          <h1 className="text-4xl font-bold text-white mb-4">Admin Dashboard</h1>
          <p className="text-lg text-yellow-100">Manage your community</p>
        </div>
      </div>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Announcements Section */}
          <div className="bg-white rounded-xl shadow-lg overflow-hidden">
            <div className="p-6 border-b border-gray-200">
              <h2 className="text-xl font-bold text-gray-800">Announcements</h2>
            </div>
            <div className="p-6">
              <button
                onClick={handleCreateAnnouncementClick}
                className="w-full bg-yellow-500 text-white p-3 rounded-lg hover:bg-yellow-600 transition-colors flex items-center justify-center"
              >
                <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4v16m8-8H4" />
                </svg>
                Create Announcement
              </button>
              
              {isCreatingAnnouncement && (
                <form onSubmit={handleCreateAnnouncement} className="mt-6 space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Title</label>
                    <input
                      type="text"
                      value={announcement.title}
                      onChange={(e) => setAnnouncement({...announcement, title: e.target.value})}
                      placeholder="Enter announcement title"
                      className="w-full p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-transparent"
                      required
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Content</label>
                    <textarea
                      value={announcement.content}
                      onChange={(e) => setAnnouncement({...announcement, content: e.target.value})}
                      placeholder="Enter announcement content"
                      className="w-full p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-transparent h-32"
                      required
                    />
                  </div>
                  <div className="flex justify-end space-x-3">
                    <button
                      type="button"
                      onClick={() => {
                        setIsCreatingAnnouncement(false);
                        setAnnouncement({
                          title: "",
                          content: "",
                          userid: userId
                        });
                      }}
                      className="px-4 py-2 text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors"
                    >
                      Cancel
                    </button>
                    <button 
                      type="submit" 
                      className="px-4 py-2 bg-yellow-500 text-white rounded-lg hover:bg-yellow-600 transition-colors"
                    >
                      Create
                    </button>
                  </div>
                </form>
              )}
            </div>
          </div>

          {/* Events Section */}
          <div className="bg-white rounded-xl shadow-lg overflow-hidden">
            <div className="p-6 border-b border-gray-200">
              <h2 className="text-xl font-bold text-gray-800">Events</h2>
            </div>
            <div className="p-6">
              <button
                onClick={handleCreateEventClick}
                className="w-full bg-yellow-500 text-white p-3 rounded-lg hover:bg-yellow-600 transition-colors flex items-center justify-center"
              >
                <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4v16m8-8H4" />
                </svg>
                Create Event
              </button>

              {(isCreatingEvent || isEditingEvent) && (
                <form onSubmit={isEditingEvent ? handleUpdateEvent : handleCreateEvent} className="mt-6 space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Event Name</label>
                    <input
                      type="text"
                      name="event_name"
                      value={newEvent.event_name}
                      onChange={handleEventChange}
                      placeholder="Event Name"
                      className="w-full p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-transparent"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Date & Time</label>
                    <input
                      type="datetime-local"
                      name="event_date"
                      value={newEvent.event_date}
                      onChange={handleEventChange}
                      className="w-full p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-transparent"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Location</label>
                    <input
                      type="text"
                      name="event_location"
                      value={newEvent.event_location}
                      onChange={handleEventChange}
                      placeholder="Event Location"
                      className="w-full p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-transparent"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                    <textarea
                      name="event_description"
                      value={newEvent.event_description}
                      onChange={handleEventChange}
                      placeholder="Event Description"
                      className="w-full p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-transparent h-32"
                    />
                  </div>
                  <div className="flex justify-end space-x-3">
                    <button
                      type="button"
                      onClick={() => {
                        setIsCreatingEvent(false);
                        setIsEditingEvent(null);
                        setNewEvent({
                          event_name: "",
                          event_date: "",
                          event_location: "",
                          event_type: "",
                          requires_registration: false,
                          created_by_user_id: userId,
                          event_description: "",
                        });
                      }}
                      className="px-4 py-2 text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors"
                    >
                      Cancel
                    </button>
                    <button 
                      type="submit" 
                      className="px-4 py-2 bg-yellow-500 text-white rounded-lg hover:bg-yellow-600 transition-colors"
                    >
                      {isEditingEvent ? "Update" : "Create"}
                    </button>
                  </div>
                </form>
              )}
            </div>
          </div>

          {/* Users Section */}
          <div className="bg-white rounded-xl shadow-lg overflow-hidden">
            <div className="p-6 border-b border-gray-200 bg-gradient-to-r from-yellow-500 to-yellow-600">
              <h2 className="text-xl font-bold text-white">User Management</h2>
            </div>
            <div className="p-6">
              <div className="mb-4">
                <input
                  type="text"
                  placeholder="Search users..."
                  value={searchUserQuery}
                  onChange={(e) => setSearchUserQuery(e.target.value)}
                  className="w-full p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-transparent"
                />
              </div>
              <div className="max-h-[400px] overflow-y-auto pr-2">
                <div className="space-y-4">
                  {filteredUsers.map((user) => (
                    <div key={user.id} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg hover:shadow-md transition-shadow">
                      <div>
                        <h4 className="font-medium text-gray-900">{user.username}</h4>
                        <p className="text-sm text-gray-500">{user.email}</p>
                      </div>
                      <select
                        value={user.roleid || 1}
                        onChange={(e) => handleUpdateUserRole(user.id, parseInt(e.target.value))}
                        className="p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-transparent"
                      >
                        <option value={1}>Guest</option>
                        <option value={2}>Member (Dues Not Paid)</option>
                        <option value={3}>Member (Dues Paid)</option>
                        <option value={4}>Coach</option>
                        <option value={5}>Executive Board</option>
                        <option value={6}>President</option>
                      </select>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>

          {/* Forum Posts Section */}
          <div className="bg-white rounded-xl shadow-lg overflow-hidden">
            <div className="p-6 border-b border-gray-200 bg-gradient-to-r from-yellow-500 to-yellow-600">
              <h2 className="text-xl font-bold text-white">Forum Posts</h2>
            </div>
            <div className="p-6">
              <div className="mb-4">
                <input
                  type="text"
                  placeholder="Search posts..."
                  value={searchForumQuery}
                  onChange={(e) => setSearchForumQuery(e.target.value)}
                  className="w-full p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-transparent"
                />
              </div>
              <div className="max-h-[400px] overflow-y-auto pr-2">
                <div className="space-y-4">
                  {filteredForumPosts.map((post) => (
                    <div key={post.postid} className="p-4 bg-gray-50 rounded-lg hover:shadow-md transition-shadow">
                      <div className="flex justify-between items-start">
                        <div>
                          <h4 className="font-medium text-gray-900">{post.title}</h4>
                          <p className="text-sm text-gray-500 mt-1">{post.content}</p>
                          <p className="text-xs text-gray-400 mt-2">
                            Posted by {post.userid} on {new Date(post.createddate).toLocaleDateString()}
                          </p>
                        </div>
                        <button
                          onClick={() => handleDeletePost(post.postid)}
                          className="text-red-500 hover:text-red-700 transition-colors"
                        >
                          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                          </svg>
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>

          {/* Score Approval Section */}
          <div className="bg-white rounded-xl shadow-lg overflow-hidden md:col-span-2">
            <div className="p-6 border-b border-gray-200 bg-gradient-to-r from-yellow-500 to-yellow-600">
              <h2 className="text-xl font-bold text-white">Score Approval</h2>
            </div>
            <div className="p-6">
              <div className="mb-4">
                <input
                  type="text"
                  placeholder="Search scores..."
                  value={searchScoreQuery}
                  onChange={(e) => setSearchScoreQuery(e.target.value)}
                  className="w-full p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-transparent"
                />
              </div>
              <div className="max-h-[400px] overflow-y-auto pr-2">
                <div className="space-y-4">
                  {filteredScoreSubmissions.map((score) => (
                    <div key={score.scoreid} className="p-4 bg-gray-50 rounded-lg hover:shadow-md transition-shadow">
                      <div className="flex justify-between items-start">
                        <div>
                          <h4 className="font-medium text-gray-900">{getUserName(score.userid)}</h4>
                          <p className="text-sm text-gray-500 mt-1">Event: {getEventName(score.eventid)}</p>
                          <p className="text-sm text-gray-600">Score: {score.score}</p>
                          <p className="text-xs text-gray-400 mt-2">
                            Submitted on {new Date(score.submissiondate).toLocaleDateString()}
                          </p>
                        </div>
                        <button
                          onClick={() => handleViewScorecard(score)}
                          className="px-3 py-1 text-sm text-yellow-600 hover:text-yellow-700 bg-yellow-50 hover:bg-yellow-100 rounded-md transition-colors duration-200 flex items-center"
                        >
                          <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                          </svg>
                          View Scorecard
                        </button>
                      </div>
                    </div>
                  ))}
                  {filteredScoreSubmissions.length === 0 && (
                    <p className="text-center text-gray-500 py-4">
                      No pending score submissions.
                    </p>
                  )}
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>

      {/* Scorecard Modal */}
      {showScoreModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg max-w-4xl w-full mx-4 max-h-[90vh] overflow-y-auto">
            <div className="p-6 border-b border-gray-200">
              <div className="flex justify-between items-center">
                <h3 className="text-xl font-bold text-gray-900">Scorecard Review</h3>
                <button
                  onClick={() => {
                    setShowScoreModal(false);
                    setSelectedScore(null);
                    setScoreImageUrl(null);
                  }}
                  className="text-gray-400 hover:text-gray-500"
                >
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
            </div>
            <div className="p-6">
              {isLoadingImage ? (
                <div className="flex justify-center items-center h-64">
                  <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-yellow-500"></div>
                </div>
              ) : scoreImageUrl ? (
                <div className="space-y-4">
                  <div className="aspect-w-16 aspect-h-9">
                    <img
                      src={scoreImageUrl}
                      alt="Scorecard"
                      className="rounded-lg shadow-lg"
                    />
                  </div>
                  <div className="flex justify-end space-x-3 mt-4">
                    <button
                      onClick={() => handleRejectScore(selectedScore.scoreid)}
                      className="px-4 py-2 text-red-600 hover:text-red-700 bg-red-50 hover:bg-red-100 rounded-md transition-colors duration-200 flex items-center"
                    >
                      <svg className="w-5 h-5 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
                      </svg>
                      Reject
                    </button>
                    <button
                      onClick={() => handleApproveScore(selectedScore.scoreid)}
                      className="px-4 py-2 text-green-600 hover:text-green-700 bg-green-50 hover:bg-green-100 rounded-md transition-colors duration-200 flex items-center"
                    >
                      <svg className="w-5 h-5 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7" />
                      </svg>
                      Approve
                    </button>
                  </div>
                </div>
              ) : (
                <p className="text-center text-gray-500 py-4">
                  Failed to load scorecard image.
                </p>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default AdminDashboard;
