import { api } from '../config';

// Action types
const LOGIN_SUCCESS = 'LOGIN_SUCCESS';
const REGISTER_SUCCESS = 'REGISTER_SUCCESS';
const LOGOUT = 'LOGOUT';
const UPDATE_PROFILE_PICTURE = 'UPDATE_PROFILE_PICTURE';

// Initial state
const initialState = {
  user: JSON.parse(localStorage.getItem('user')) || null,  // Get user data from localStorage if available
  isAuthenticated: !!localStorage.getItem('token'),      // Check if token exists to set auth state
};
console.log("Initial localStorage user:", JSON.parse(localStorage.getItem('user')));

// Action creators
export const loginSuccess = (data) => ({
  type: LOGIN_SUCCESS,
  payload: data
});

export const registerSuccess = (data) => ({
  type: REGISTER_SUCCESS,
  payload: data
});

export const logout = () => ({
  type: LOGOUT
});

export const updateProfilePicture = (pictureUrl) => ({
  type: UPDATE_PROFILE_PICTURE,
  payload: pictureUrl
});

// Async action to handle login
export const login = ({ username, password }) => async (dispatch) => {
  try {
    console.log('Attempting login with:', { username });
    const response = await api.post('/auth/login', { username, password });
    console.log('Login response:', response.data);
    dispatch(loginSuccess(response.data));
    return { success: true, data: response.data };
  } catch (error) {
    console.error('Login failed:', error);
    return { success: false, error: error.response?.data?.message || 'Login failed' };
  }
};

// Async action to handle registration
export const register = ({ username, email, password, firstName, lastName }) => async (dispatch) => {
  try {
    const response = await api.post('/auth/register', {           
      username, 
      email, 
      password, 
      firstName, 
      lastName
    });
    dispatch(registerSuccess(response.data));
    return { success: true, data: response.data };
  } catch (error) {
    console.error('Registration failed:', error);
    return { success: false, error: error.response?.data?.message || 'Registration failed' };
  }
};

// Async action to handle logout
export const logoutUser = () => (dispatch) => {
  dispatch(logout());  // Dispatch logout action
};

// Async action to update profile picture
export const uploadProfilePicture = (userId, file) => async (dispatch) => {
  try {
    const formData = new FormData();
    formData.append('profilePicture', file);

    const response = await api.put(`/users/${userId}/profile-picture`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    });

    dispatch(updateProfilePicture(response.data.user.profilepicture));
    return { success: true, data: response.data };
  } catch (error) {
    console.error('Profile picture update failed:', error);
    return { success: false, error: error.response?.data?.message || 'Profile picture update failed' };
  }
};

// Reducer
const userReducer = (state = initialState, action) => {
  switch (action.type) {
    case LOGIN_SUCCESS:
      localStorage.setItem('token', action.payload.token);
      localStorage.setItem('user', JSON.stringify(action.payload.user));
      return {
        ...state,
        isAuthenticated: true,
        user: action.payload.user
      };
    case REGISTER_SUCCESS:
      localStorage.setItem('token', action.payload.token);
      localStorage.setItem('user', JSON.stringify(action.payload.user));
      return {
        ...state,
        isAuthenticated: true,
        user: action.payload.user
      };
    case LOGOUT:
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      return {
        ...state,
        isAuthenticated: false,
        user: null
      };
    case UPDATE_PROFILE_PICTURE:
      const updatedUser = {
        ...state.user,
        profilePicture: action.payload
      };
      localStorage.setItem('user', JSON.stringify(updatedUser));
      return {
        ...state,
        user: updatedUser
      };
    default:
      return state;
  }
};

export default userReducer;
