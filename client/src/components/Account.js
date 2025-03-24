import React from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { logoutUser } from '../reducers/userReducer'; // Adjust the path if necessary
import { useNavigate } from 'react-router-dom';
import { AccessLevels } from '../utils/constants';
import Nav from './Nav'; // Import the Nav component
import clubLogo from '../assets/clublogo.png';

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

  const user = useSelector((state) => {
    console.log(state); // Log the entire Redux state
    return state.user;
  });
  //console.log(user.user.username);

  const handleLogout = () => {
    dispatch(logoutUser());
    navigate('/login'); // Redirect to login page after logout
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
                <button
                  className="w-full px-6 py-3 bg-yellow-500 text-white font-semibold rounded-lg hover:bg-yellow-600 transition"
                  onClick={() => alert('Edit name functionality coming soon!')}
                >
                  Edit Name
                </button>
                <button
                  className="w-full px-6 py-3 bg-yellow-500 text-white font-semibold rounded-lg hover:bg-yellow-600 transition"
                  onClick={() => alert('Edit username functionality coming soon!')}
                >
                  Edit Username
                </button>
              </div>

              {/* Signed-Up Events */}
              <div>
                <h3 className="text-2xl font-semibold text-yellow-500 mb-4">
                  Your Events
                </h3>
                <div className="bg-gray-100 p-4 rounded shadow-sm">
                  <p className="text-gray-500 text-center">
                    No events signed up yet.
                  </p>
                </div>
              </div>

              {/* Notifications */}
              <div>
                <h3 className="text-2xl font-semibold text-yellow-500 mb-4">
                  Notifications
                </h3>
                <div className="bg-gray-100 p-4 rounded shadow-sm">
                  <p className="text-gray-500 text-center">
                    No notifications yet.
                  </p>
                </div>
              </div>

              {/* Payment Status */}
              <p className="text-center text-gray-500">
                Status: {accessLevelLabels[user.user.roleid] || 'Unknown Status'}
              </p>
            </div>
          ) : (
            <p className="text-center">You are not logged in.</p>
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
