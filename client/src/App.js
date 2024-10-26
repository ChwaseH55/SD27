// src/App.js
import { Route, Routes, useLocation, useNavigate } from 'react-router-dom';
import { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import axios from 'axios';
import Register from './components/Register';
import Login from './components/Login';
import Landing from './components/Landing';
import Home from './components/Home';
import Account from './components/Account';
import Nav from './components/Nav';
import { logout } from './reducers/userReducer';

function App() {
  const [data, setData] = useState(null);
  const location = useLocation();
  const navigate = useNavigate();
  const dispatch = useDispatch();

  const isLandingPage = location.pathname === '/';
  const { user } = useSelector((state) => state.user); // Get user state from Redux

  // Fetch data from the backend on load
  useEffect(() => {
    axios.get('http://localhost:5000/api/test')
      .then(response => setData(response.data.message))
      .catch(error => console.error(error));
  }, []);

  // Logout function to clear user session
  const handleLogout = () => {
    dispatch(logout());
    navigate('/');
  };

  return (
    <div>
      {!isLandingPage && <Nav onLogout={handleLogout} isLoggedIn={!!user} />}
      <div className="flex items-center justify-center min-h-screen bg-gray-200">
        <Routes>
          <Route path="/account" element={<Account />} />
          <Route path="/home" element={<Home />} />
          <Route path="/register" element={<Register />} />
          <Route path="/login" element={<Login />} />
          <Route path="/" element={<Landing />} />
        </Routes>
        {/* Display server data for testing */}
        {data && (
          <p className="absolute bottom-4 text-center w-full text-sm text-gray-600">
            Server Message: {data}
          </p>
        )}
      </div>
    </div>
  );
}

export default App;
