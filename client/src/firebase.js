import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getDatabase } from 'firebase/database';
import { getStorage } from 'firebase/storage';

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyDXXJnmGzgfMgUYP2LTb_YMwXh_Qz5QQWQ",
  authDomain: "sd27-87d55.firebaseapp.com",
  projectId: "sd27-87d55",
  storageBucket: "sd27-87d55.firebasestorage.app",
  messagingSenderId: "51740552750",
  appId: "1:51740552750:web:3b8b8b8b8b8b8b8b8b8b8b",
  databaseURL: "https://sd27-87d55-default-rtdb.firebaseio.com"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Get Auth, Database, and Storage instances
export const auth = getAuth(app);
export const database = getDatabase(app);
export const storage = getStorage(app);

export default app; 