// src/App.js
import { Route, Routes, useLocation, useNavigate } from 'react-router-dom';
import { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { api } from './config';
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
import Store from './components/Store'; 
import CalendarPage from './components/Calendar';
import Chat from './components/Chat';
import { logout } from './reducers/userReducer';
import ProtectedRoute from './components/ProtectedRoute'; // Import ProtectedRoute
import { loadStripe } from "@stripe/stripe-js";

const stripePromise = loadStripe("pk_test_51PzZ4xRs4YZmhcoeiINiWfKCCh0sC5gpVqxfhtT24PzY7OPcUAlZuxyldOm7kKOejlZxi1wIwwbzMPVLVAS2pz2f00zNR0YmWR");

function App() {
  const [data, setData] = useState(null);
  const location = useLocation();
  const navigate = useNavigate();
  const dispatch = useDispatch();
  const { user } = useSelector((state) => state.user);

  const isLandingPage = location.pathname === '/';

  useEffect(() => {
    api
      .get('/test')
      .then((response) => setData(response.data.message))
      .catch((error) => console.error(error));
  }, []);

  const handleLogout = () => {
    dispatch(logout());
    navigate('/');
  };

  return (
    <div>
      {!isLandingPage && <Nav isLoggedIn={!!user} onLogout={handleLogout} />}
      <div className="flex flex-col min-h-screen">
        <Routes>
          {/* Public Routes */}
          <Route path="/" element={<Landing />} />
          <Route path="/register" element={<Register />} />
          <Route path="/login" element={<Login />} />

          {/* Protected Routes */}
          <Route
            path="/admin"
            element={
              <ProtectedRoute requiredRole={3}>
                <AdminDash />
              </ProtectedRoute>
            }
          />
          
          {/* Protected Routes for Logged-in Users */}
          <Route
            path="/home"
            element={
              <ProtectedRoute>
                <Home />
              </ProtectedRoute>
            }
          />
          <Route
            path="/account"
            element={
              <ProtectedRoute>
                <Account />
              </ProtectedRoute>
            }
          />
          <Route
            path="/forum"
            element={
              <ProtectedRoute>
                <Forum />
              </ProtectedRoute>
            }
          />
          <Route
            path="/calendar"
            element={
              <ProtectedRoute>
                <CalendarPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/events"
            element={
              <ProtectedRoute>
                <EventsPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/scores"
            element={
              <ProtectedRoute>
                <ScoresPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/store"
            element={
              <ProtectedRoute>
                <Store />
              </ProtectedRoute>
            }
          />
          <Route
            path="/chat"
            element={
              <ProtectedRoute>
                <Chat />
              </ProtectedRoute>
            }
          />
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
