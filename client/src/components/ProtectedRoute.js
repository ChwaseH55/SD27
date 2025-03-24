// src/components/ProtectedRoute.js
import React from 'react';
import { Navigate } from 'react-router-dom';
import { useSelector } from 'react-redux';

const ProtectedRoute = ({ children, requiredRole = 0 }) => {
  const { user } = useSelector((state) => state.user);

  if (!user) {
    // If user is not logged in, redirect to login page
    return <Navigate to="/login" />;
  }

  if (user.roleid < requiredRole) {
    // If user doesn't have the required role, redirect to home page
    return <Navigate to="/home" />;
  }

  // If user is authenticated and authorized, render the component
  return children;
};

export default ProtectedRoute;
