import React, { useState, useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { logoutUser } from '../reducers/userReducer'; // Adjust the path if necessary
import { useNavigate } from 'react-router-dom';
import { AccessLevels } from '../utils/constants';
import Nav from './Nav'; // Import the Nav component
import clubLogo from '../assets/clublogo.png';
import { api } from '../config'; // Update the import path for the api instance

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

  useEffect(() => {
    const fetchUserDetails = async () => {
      try {
        // Use the correct endpoint for fetching user's registered events
        const eventsResponse = await api.get(`/events/my-events/${user.user.id}`);
        setRegisteredEvents(eventsResponse.data);

        const announcementsResponse = await api.get('/announcements');
        setAnnouncements(announcementsResponse.data);
      } catch (error) {
        console.error("Error fetching user details:", error);
      }
    };

    fetchUserDetails();
  }, [user.user.id]);

  const handleLogout = () => {
    dispatch(logoutUser());
    navigate('/login');
  };

  const handleEditName = async () => {
    try {
      const response = await api.put(`/users/${user.user.id}`, { firstname: newName });
      alert('Name updated successfully!');
      // Update the user state with the new name
      dispatch({ type: 'UPDATE_USER_NAME', payload: newName });
      setIsEditingName(false);
    } catch (error) {
      console.error('Error updating name:', error);
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

  return (
    <div className="flex flex-col min-h-screen bg-gray-100">
      {/* Navbar */}
      <Nav isLoggedIn={!!user} onLogout={handleLogout} /> {/* Ensure the Nav component is used here */}

      {/* Account Section */}
      <div className="flex flex-col items-center justify-center flex-grow pt-20 px-4">
        <div className="bg-white shadow-lg rounded-lg p-8 max-w-xl w-full">
          <h2 className="text-4xl font-extrabold text-gray-800 mb-6 text-center">
            Account
          </h2>

          {user ? (
            <div className="space-y-8">
              {/* Profile Picture Section */}
              <div className="flex flex-col items-center">
                <div className="w-24 h-24 bg-gray-200 rounded-full flex items-center justify-center overflow-hidden">
                  {/* Placeholder for User Picture */}
                  <span className="text-gray-400">Upload</span>
                </div>
                <button
                  className="mt-2 text-sm text-blue-500 hover:underline"
                  onClick={() => alert('Upload functionality coming soon!')}
                >
                  Upload Picture
                </button>
              </div>

              {/* User Information */}
              <div className="text-center">
                <p className="text-lg font-semibold">
                  Welcome, {user.user.username}!
                </p>
                <p className="text-sm text-gray-500">
                  Email: {user.user.email}
                </p>
              </div>

              {/* Edit Account Details */}
              <div className="space-y-4">
                {isEditingName ? (
                  <div>
                    <input
                      type="text"
                      value={newName}
                      onChange={(e) => setNewName(e.target.value)}
                      placeholder="Enter new name"
                      className="w-full px-4 py-2 border border-gray-300 rounded mb-2"
                    />
                    <div className="flex space-x-2">
                      <button
                        className="w-1/2 px-6 py-3 bg-yellow-500 text-white font-semibold rounded-lg hover:bg-yellow-600 transition"
                        onClick={handleEditName}
                      >
                        Submit
                      </button>
                      <button
                        className="w-1/2 px-6 py-3 bg-gray-300 text-gray-700 font-semibold rounded-lg hover:bg-gray-400 transition"
                        onClick={() => setIsEditingName(false)}
                      >
                        Cancel
                      </button>
                    </div>
                  </div>
                ) : (
                  <button
                    className="w-full px-6 py-3 bg-yellow-500 text-white font-semibold rounded-lg hover:bg-yellow-600 transition"
                    onClick={() => setIsEditingName(true)}
                  >
                    Edit Name
                  </button>
                )}

                {isEditingUsername ? (
                  <div>
                    <input
                      type="text"
                      value={newUsername}
                      onChange={(e) => setNewUsername(e.target.value)}
                      placeholder="Enter new username"
                      className="w-full px-4 py-2 border border-gray-300 rounded mb-2"
                    />
                    <div className="flex space-x-2">
                      <button
                        className="w-1/2 px-6 py-3 bg-yellow-500 text-white font-semibold rounded-lg hover:bg-yellow-600 transition"
                        onClick={handleEditUsername}
                      >
                        Submit
                      </button>
                      <button
                        className="w-1/2 px-6 py-3 bg-gray-300 text-gray-700 font-semibold rounded-lg hover:bg-gray-400 transition"
                        onClick={() => setIsEditingUsername(false)}
                      >
                        Cancel
                      </button>
                    </div>
                  </div>
                ) : (
                  <button
                    className="w-full px-6 py-3 bg-yellow-500 text-white font-semibold rounded-lg hover:bg-yellow-600 transition"
                    onClick={() => setIsEditingUsername(true)}
                  >
                    Edit Username
                  </button>
                )}
              </div>

              {/* Signed-Up Events */}
              <div>
                <h3 className="text-2xl font-semibold text-yellow-500 mb-4">
                  Your Events
                </h3>
                <div className="bg-gray-100 p-4 rounded shadow-sm">
                  {registeredEvents.length > 0 ? (
                    <ul>
                      {registeredEvents.map(event => (
                        <li key={event.eventid} className="text-gray-700">
                          {event.eventname} - {new Date(event.eventdate).toLocaleDateString()} at {event.eventlocation}
                        </li>
                      ))}
                    </ul>
                  ) : (
                    <p className="text-gray-500 text-center">
                      No events signed up yet.
                    </p>
                  )}
                </div>
              </div>

              {/* Notifications */}
              <div>
                <h3 className="text-2xl font-semibold text-yellow-500 mb-4">
                  Notifications
                </h3>
                <div className="bg-gray-100 p-4 rounded shadow-sm">
                  {announcements.length > 0 ? (
                    <ul>
                      {announcements.map(announcement => (
                        <li key={announcement.announcementid} className="text-gray-700 mb-2">
                          <h4 className="font-bold">{announcement.title}</h4>
                          <p>{announcement.content}</p>
                          <small className="text-gray-500">
                            {new Date(announcement.createddate).toLocaleDateString()}
                          </small>
                        </li>
                      ))}
                    </ul>
                  ) : (
                    <p className="text-gray-500 text-center">
                      No announcements yet.
                    </p>
                  )}
                </div>
              </div>

              {/* Payment Status */}
              <p className="text-center text-gray-500">
                Status: {accessLevelLabels[user.user.roleid] || 'Unknown Status'}
              </p>
            </div>
          ) : (
            <p className="text-center text-gray-500">
              Please log in to view your account details.
            </p>
          )}
        </div>
      </div>

      {/* Footer */}
      <footer className="py-6 bg-gray-800 text-center text-white">
        <p className="text-sm">
          &copy; {new Date().getFullYear()} Golf Club @ UCF. All rights reserved.
        </p>
      </footer>
    </div>
  );
};

export default Account;
