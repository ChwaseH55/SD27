import axios from 'axios';

// Action types
const LOGIN_SUCCESS = 'LOGIN_SUCCESS';
const REGISTER_SUCCESS = 'REGISTER_SUCCESS';
const LOGOUT = 'LOGOUT';

// Initial state
const initialState = {
  user: JSON.parse(localStorage.getItem('user')) || null,  // Get user data from localStorage if available
  isAuthenticated: !!localStorage.getItem('token'),      // Check if token exists to set auth state
};
console.log("Initial localStorage user:", JSON.parse(localStorage.getItem('user')));

// Action creators
export const loginSuccess = (userData) => {
  console.log("Login Success - userData:", userData);  // Check userData here
  localStorage.setItem('token', userData.token);
  localStorage.setItem('user', JSON.stringify(userData.user));  // Save user data along with the token
  return {
    type: LOGIN_SUCCESS,
    payload: userData.user,
  };
};

export const registerSuccess = (userData) => {
  localStorage.setItem('token', userData.token);
  localStorage.setItem('user', JSON.stringify(userData));  // Save user data along with the token
  return {
    type: REGISTER_SUCCESS,
    payload: userData,
  };
};

export const logout = () => {
  localStorage.removeItem('token');
  localStorage.removeItem('user');  // Remove user data from localStorage
  return {
    type: LOGOUT,
  };
};

// Async action to handle login
export const login = (username, password) => async (dispatch) => {
  try {
    const response = await axios.post('http://localhost:5000/api/auth/login', { username, password });
    dispatch(loginSuccess(response.data)); // Dispatch login success with user data
    return { user: response.data }; // Return the user data
  } catch (error) {
    console.error('Login failed:', error);
    // Return an object with an error property
    return { error: { message: error.response?.data?.message || 'Login failed' } };
  }
};

// Async action to handle registration
export const register = ({ username, email, password, firstName, lastName }) => async (dispatch) => {
  try {
      const response = await axios.post('http://localhost:5000/api/auth/register', {           
        username, 
        email, 
        password, 
        firstName, 
        lastName
      });
      dispatch(registerSuccess(response.data));  // Dispatch success with user data
      return { success: true, data: response.data }; // Return success indication
  } catch (error) {
      console.error('Registration failed:', error);
      return { success: false, error: error.response?.data?.message || 'Registration failed' }; // Return error payload
  }
};

// Async action to handle logout
export const logoutUser = () => (dispatch) => {
  dispatch(logout());  // Dispatch logout action
};

// Reducer
const userReducer = (state = initialState, action) => {
  switch (action.type) {
    case LOGIN_SUCCESS:
    case REGISTER_SUCCESS:
      return {
        ...state,
        user: action.payload,
        isAuthenticated: true,
      };
    case LOGOUT:
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      return {
        ...state,
        user: null,
        isAuthenticated: false,
      };
    default:
      return state;
  }
};

export default userReducer;
