// client/src/reducers/userReducer.js
import axios from 'axios';

// Action types
const LOGIN_SUCCESS = 'LOGIN_SUCCESS';
const REGISTER_SUCCESS = 'REGISTER_SUCCESS';
const LOGOUT = 'LOGOUT';

// Initial state
const initialState = {
  user: null,              // Stores user data (e.g., username, email, etc.)
  isAuthenticated: false,  // Boolean to track if user is logged in
};

// Action creators
export const loginSuccess = (userData) => ({
  type: LOGIN_SUCCESS,
  payload: userData,
});

export const registerSuccess = (userData) => ({
  type: REGISTER_SUCCESS,
  payload: userData,
});

export const logout = () => ({
  type: LOGOUT,
});

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
export const register = ({ username, email, password }) => async (dispatch) => {
  try {
      const response = await axios.post('http://localhost:5000/api/auth/register', { username, email, password });
      dispatch(registerSuccess(response.data));  // Dispatch success with user data
      return { success: true, data: response.data }; // Return success indication
  } catch (error) {
      console.error('Registration failed:', error);
      return { success: false, error: error.response?.data?.message || 'Registration failed' }; // Return error payload
  }
};


// Async action to handle logout
export const logoutUser = () => (dispatch) => {
  // Clear any client-side storage if needed (like JWT in local storage)
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
