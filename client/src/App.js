// src/App.js
import { Route, Routes, useLocation, useNavigate } from 'react-router-dom';
import { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import axios from 'axios';
import Register from './components/Register';
import Login from './components/Login';
import Landing from './components/Landing';
import Home from './components/Home';
import Nav from './components/Nav';
import Account from './components/Account';
import Forum from './components/Forum';
import AdminDash from './components/AdminDash';
import EventsPage from './components/Events';
import ScoresPage from './components/Scores';
import Store from './components/Store'; // Ensure this import exists
import { logout } from './reducers/userReducer';

function App() {
  const [data, setData] = useState(null);
  const location = useLocation();
  const navigate = useNavigate();
  const dispatch = useDispatch();

  const isLandingPage = location.pathname === '/';
  const { user } = useSelector((state) => state.user);

  useEffect(() => {
    axios
      .get('http://localhost:5000/api/test')
      .then((response) => setData(response.data.message))
      .catch((error) => console.error(error));
  }, []);

  const handleLogout = () => {
    dispatch(logout());
    navigate('/');
  };

  return (
    <div>
      {!isLandingPage && <Nav onLogout={handleLogout} isLoggedIn={!!user} />}
      <div className="flex flex-col min-h-screen">
        <Routes>
          <Route path="/" element={<Landing />} />
          <Route path="/home" element={<Home />} />
          <Route path="/register" element={<Register />} />
          <Route path="/login" element={<Login />} />
          <Route path="/account" element={<Account />} />
          <Route path="/forum" element={<Forum />} />
          <Route path="/admin" element={<AdminDash />} />
          <Route path="/events" element={<EventsPage />} />
          <Route path="/scores" element={<ScoresPage />} />
          <Route path="/store" element={<Store />} /> {/* Correct route */}
        </Routes>
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
