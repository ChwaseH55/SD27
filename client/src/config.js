import axios from 'axios';

// API Configuration
const isDevelopment = process.env.NODE_ENV === 'development';
export const API_BASE_URL = '/api';

// Create axios instance with default config
export const api = axios.create({
  baseURL: API_BASE_URL,
  withCredentials: false,  // Using token auth
  headers: {
    'Content-Type': 'application/json',
  }
});

// Add request interceptor to add auth token and logging
api.interceptors.request.use(
  async (config) => {
    // Get the token from localStorage
    const token = localStorage.getItem('token');
    console.log('Token from localStorage:', token ? 'Token exists' : 'No token found');
    
    // Ensure headers object exists and is properly initialized
    config.headers = {
      ...config.headers,
      'Content-Type': 'application/json'
    };
    
    // If token exists, add it to the Authorization header
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`;
      console.log('Added Authorization header:', config.headers['Authorization']);
    } else {
      console.log('No token available to add to request');
    }
    
    // Log the full request configuration with stringified headers
    console.log('Full request config:', {
      url: config.url,
      method: config.method,
      headers: JSON.stringify(config.headers),
      baseURL: config.baseURL
    });
    
    return config;
  },
  (error) => {
    console.error('Request interceptor error:', error);
    return Promise.reject(error);
  }
);

// Add response interceptor to handle auth errors and logging
api.interceptors.response.use(
  (response) => {
    // Log successful responses for debugging
    console.log('API response:', {
      status: response.status,
      data: response.data
    });
    return response;
  },
  (error) => {
    // Log error responses for debugging
    console.error('API error:', {
      status: error.response?.status,
      data: error.response?.data,
      headers: error.response?.headers
    });
    
    if (error.response?.status === 401) {
      // Clear token and redirect to login
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Helper function to get full API URL
export const getApiUrl = (endpoint) => {
  return `${API_BASE_URL}${endpoint}`;
}; 