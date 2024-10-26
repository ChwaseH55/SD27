// client/src/reducers/index.js
import { combineReducers } from 'redux';
import todoReducer from './todoReducer';
import userReducer from './userReducer'; // Import the user reducer

const rootReducer = combineReducers({
  todos: todoReducer,
  user: userReducer, // Add user reducer to the root reducer
});

export default rootReducer;
