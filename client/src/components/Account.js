import React, { useState, useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { logoutUser } from '../reducers/userReducer'; // Adjust the path if necessary
import { useNavigate } from 'react-router-dom';
import { AccessLevels } from '../utils/constants';
import Nav from './Nav'; // Import the Nav component
import UserAvatar from './UserAvatar';
import { api } from '../config'; // Update the import path for the api instance
import { storage } from '../firebase';
import { ref as storageRef, uploadBytes, getDownloadURL } from 'firebase/storage';

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

const accessLevelLabels = {
  [AccessLevels.GUEST]: 'Guest',
  [AccessLevels.MEMBER]: 'Member (Dues Not Paid)',
  [AccessLevels.PAID_MEMBER]: 'Member (Dues Paid)',
  [AccessLevels.COACH]: 'Coach',
  [AccessLevels.EXECUTIVE_BOARD]: 'Executive Board',
  [AccessLevels.PRESIDENT]: 'President',
};

const Account = () => {
  const dispatch = useDispatch();
  const navigate = useNavigate();

  const user = useSelector((state) => state.user);
  const [registeredEvents, setRegisteredEvents] = useState([]);
  const [announcements, setAnnouncements] = useState([]);
  const [newName, setNewName] = useState(user.user.firstname || '');
  const [newUsername, setNewUsername] = useState(user.user.username || '');
  const [isEditingName, setIsEditingName] = useState(false);
  const [isEditingUsername, setIsEditingUsername] = useState(false);
  const [uploadingPhoto, setUploadingPhoto] = useState(false);

  useEffect(() => {
    const fetchUserDetails = async () => {
      try {
        // Fetch user's current data including profile picture
        const userResponse = await api.get(`users/${user.user.id}`);
        
        // Map the response data to match our expected format
        const userData = {
          ...userResponse.data,
          firstname: userResponse.data.firstName,
          lastname: userResponse.data.lastName
        };

        // Update the user state with the mapped data
        dispatch({ 
          type: 'UPDATE_USER', 
          payload: userData
        });

        // If there's a profile picture in Firebase storage, get its URL
        if (userData.profilePicture) {
          try {
            const imageRef = storageRef(storage, userData.profilePicture);
            const downloadURL = await getDownloadURL(imageRef);
            
            // Update the user state with the download URL
            dispatch({ 
              type: 'UPDATE_USER_PROFILE_PICTURE', 
              payload: downloadURL 
            });

            // Update the full user object with the new URL
            const updatedUser = {
              ...userData,
              profilePicture: downloadURL
            };
            dispatch({ type: 'UPDATE_USER', payload: updatedUser });
          } catch (error) {
            console.error("Error getting profile picture URL:", error);
          }
        }

        // Fetch events and announcements
        const eventsResponse = await api.get(`events/my-events/${user.user.id}`);
        setRegisteredEvents(eventsResponse.data);

        const announcementsResponse = await api.get('announcements');
        setAnnouncements(announcementsResponse.data);
      } catch (error) {
        console.error("Error fetching user details:", error);
      }
    };

    fetchUserDetails();
  }, [user.user.id, dispatch]);

  const handleLogout = () => {
    dispatch(logoutUser());
    navigate('/login');
  };

  const handleEditName = async () => {
    try {
      const response = await api.put(`/users/${user.user.id}`, { firstname: newName });
      
      // Update Redux store with the new name
      dispatch({ 
        type: 'UPDATE_USER_NAME', 
        payload: newName 
      });

      // Update the local user state
      const updatedUser = {
        ...user.user,
        firstname: newName
      };
      dispatch({ type: 'UPDATE_USER', payload: updatedUser });

      setIsEditingName(false);
      alert('Name updated successfully!');
    } catch (error) {
      console.error('Error updating name:', error);
      alert('Failed to update name. Please try again.');
    }
  };

  const handleEditUsername = async () => {
    try {
      const response = await api.put(`/users/${user.user.id}`, { username: newUsername });
      alert('Username updated successfully!');
      // Update the user state with the new username
      dispatch({ type: 'UPDATE_USER_USERNAME', payload: newUsername });
      setIsEditingUsername(false);
    } catch (error) {
      console.error('Error updating username:', error);
    }
  };

  const fetchUserEvents = async () => {
    try {
      const userId = user.id; // Assuming you have access to the user's ID
      const response = await api.get(`/events/my-events/${userId}`);
      setRegisteredEvents(response.data);
    } catch (error) {
      console.error("Error fetching user events:", error);
    }
  };

  const handleProfilePictureUpload = async (event) => {
    const file = event.target.files[0];
    if (!file) return;

    try {
      setUploadingPhoto(true);
      
      // Create a storage reference with the user's ID
      const imageRef = storageRef(storage, `profile_pictures/${user.user.id}/${file.name}`);
      
      // Upload the file
      const snapshot = await uploadBytes(imageRef, file);
      
      // Get the download URL
      const downloadURL = await getDownloadURL(imageRef);
      
      // Update the user's profile in the database
      const response = await api.put(`users/${user.user.id}`, {
        profilePicture: `profile_pictures/${user.user.id}/${file.name}` // Store the path instead of URL
      });

      // Update Redux store with the new profile picture URL
      dispatch({ 
        type: 'UPDATE_USER_PROFILE_PICTURE', 
        payload: downloadURL 
      });

      // Update the local user state
      const updatedUser = {
        ...user.user,
        profilePicture: downloadURL
      };
      dispatch({ type: 'UPDATE_USER', payload: updatedUser });

      setUploadingPhoto(false);
    } catch (error) {
      console.error('Error uploading profile picture:', error);
      setUploadingPhoto(false);
      alert('Failed to upload profile picture. Please try again.');
    }
  };

  const handleUnregisterEvent = async (eventId) => {
    try {
      await api.delete(`/events/${eventId}/unregister/${user.user.id}`);
      setRegisteredEvents(registeredEvents.filter(event => event.eventid !== eventId));
      alert('Successfully unregistered from event');
    } catch (error) {
      console.error('Error unregistering from event:', error);
      alert('Failed to unregister from event. Please try again.');
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
          <h1 className="text-4xl font-bold text-white mb-4">My Account</h1>
          <p className="text-lg text-yellow-100">Manage your profile and preferences</p>
        </div>
      </div>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Profile Section */}
          <div className="bg-white rounded-xl shadow-lg overflow-hidden">
            <div className="p-6 border-b border-gray-200 bg-gradient-to-r from-yellow-500 to-yellow-600">
              <h2 className="text-xl font-bold text-white">Profile Information</h2>
            </div>
            <div className="p-6">
              <div className="flex flex-col items-center space-y-6">
                <div className="relative group">
                  <UserAvatar user={user.user} size="lg" />
                  <div className="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-20 rounded-full transition-all duration-300 flex items-center justify-center">
                    <svg className="w-8 h-8 text-white opacity-0 group-hover:opacity-100 transition-opacity duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
                    </svg>
                  </div>
                </div>
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleProfilePictureUpload}
                  className="hidden"
                  id="profile-picture-input"
                />
                <label
                  htmlFor="profile-picture-input"
                  className="cursor-pointer px-4 py-2 bg-yellow-500 text-white rounded-lg hover:bg-yellow-600 transition-colors flex items-center shadow-md hover:shadow-lg"
                >
                  <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                  </svg>
                  {uploadingPhoto ? 'Uploading...' : 'Upload Picture'}
                </label>

                <div className="w-full space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Name</label>
                    {isEditingName ? (
                      <div className="space-y-2">
                        <input
                          type="text"
                          value={newName}
                          onChange={(e) => setNewName(e.target.value)}
                          placeholder="Enter new name"
                          className="w-full p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-transparent"
                        />
                        <div className="flex space-x-2">
                          <button
                            onClick={handleEditName}
                            className="flex-1 px-4 py-2 bg-yellow-500 text-white rounded-lg hover:bg-yellow-600 transition-colors"
                          >
                            Save
                          </button>
                          <button
                            onClick={() => setIsEditingName(false)}
                            className="flex-1 px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
                          >
                            Cancel
                          </button>
                        </div>
                      </div>
                    ) : (
                      <div className="flex items-center justify-between p-2 bg-white rounded-lg shadow-sm">
                        <span className="text-gray-900">{user.user.firstname || 'Not set'}</span>
                        <button
                          onClick={() => setIsEditingName(true)}
                          className="text-yellow-500 hover:text-yellow-600 transition-colors"
                        >
                          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
                          </svg>
                        </button>
                      </div>
                    )}
                  </div>

                  <div className="mt-4">
                    <label className="block text-sm font-medium text-gray-700 mb-1">Username</label>
                    {isEditingUsername ? (
                      <div className="space-y-2">
                        <input
                          type="text"
                          value={newUsername}
                          onChange={(e) => setNewUsername(e.target.value)}
                          placeholder="Enter new username"
                          className="w-full p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-transparent"
                        />
                        <div className="flex space-x-2">
                          <button
                            onClick={handleEditUsername}
                            className="flex-1 px-4 py-2 bg-yellow-500 text-white rounded-lg hover:bg-yellow-600 transition-colors"
                          >
                            Save
                          </button>
                          <button
                            onClick={() => setIsEditingUsername(false)}
                            className="flex-1 px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
                          >
                            Cancel
                          </button>
                        </div>
                      </div>
                    ) : (
                      <div className="flex items-center justify-between p-2 bg-white rounded-lg shadow-sm">
                        <span className="text-gray-900">{user.user.username}</span>
                        <button
                          onClick={() => setIsEditingUsername(true)}
                          className="text-yellow-500 hover:text-yellow-600 transition-colors"
                        >
                          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
                          </svg>
                        </button>
                      </div>
                    )}
                  </div>

                  <div className="mt-4">
                    <label className="block text-sm font-medium text-gray-700 mb-1">Email</label>
                    <div className="p-2 bg-white rounded-lg shadow-sm">
                      <span className="text-gray-900">{user.user.email}</span>
                    </div>
                  </div>

                  <div className="mt-4">
                    <label className="block text-sm font-medium text-gray-700 mb-1">Membership Status</label>
                    <div className="p-2 bg-white rounded-lg shadow-sm">
                      <span className="text-gray-900">{accessLevelLabels[user.user.roleid] || 'Unknown Status'}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Events and Notifications Section */}
          <div className="space-y-6">
            {/* Registered Events */}
            <div className="bg-white rounded-xl shadow-lg overflow-hidden">
              <div className="p-6 border-b border-gray-200 bg-gradient-to-r from-yellow-500 to-yellow-600">
                <h2 className="text-xl font-bold text-white">Your Events</h2>
              </div>
              <div className="p-6">
                <div className="max-h-[300px] overflow-y-auto pr-2">
                  {registeredEvents.length > 0 ? (
                    <div className="space-y-4">
                      {registeredEvents.map(event => (
                        <div key={event.eventid} className="p-4 bg-gray-50 rounded-lg shadow-sm hover:shadow-md transition-shadow">
                          <div className="flex justify-between items-start">
                            <div>
                              <h4 className="font-medium text-gray-900">{event.eventname}</h4>
                              <p className="text-sm text-gray-500 mt-1">
                                {new Date(event.eventdate).toLocaleDateString()} at {event.eventlocation}
                              </p>
                              <p className="text-sm text-gray-600 mt-2">{event.eventdescription}</p>
                            </div>
                            <button
                              onClick={() => handleUnregisterEvent(event.eventid)}
                              className="px-3 py-1 text-sm text-red-600 hover:text-red-700 bg-red-50 hover:bg-red-100 rounded-md transition-colors duration-200 flex items-center"
                              title="Unregister from event"
                            >
                              <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
                              </svg>
                              Unregister
                            </button>
                          </div>
                        </div>
                      ))}
                    </div>
                  ) : (
                    <p className="text-center text-gray-500 py-4">
                      No events signed up yet.
                    </p>
                  )}
                </div>
              </div>
            </div>

            {/* Notifications */}
            <div className="bg-white rounded-xl shadow-lg overflow-hidden">
              <div className="p-6 border-b border-gray-200 bg-gradient-to-r from-yellow-500 to-yellow-600">
                <h2 className="text-xl font-bold text-white">Recent Announcements</h2>
              </div>
              <div className="p-6">
                <div className="max-h-[300px] overflow-y-auto pr-2">
                  {announcements.length > 0 ? (
                    <div className="space-y-4">
                      {announcements.map(announcement => (
                        <div key={announcement.announcementid} className="p-4 bg-gray-50 rounded-lg shadow-sm hover:shadow-md transition-shadow">
                          <h4 className="font-medium text-gray-900">{announcement.title}</h4>
                          <p className="text-sm text-gray-600 mt-1">{announcement.content}</p>
                          <p className="text-xs text-gray-400 mt-2">
                            {new Date(announcement.createddate).toLocaleDateString()}
                          </p>
                        </div>
                      ))}
                    </div>
                  ) : (
                    <p className="text-center text-gray-500 py-4">
                      No announcements yet.
                    </p>
                  )}
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
};

export default Account;
