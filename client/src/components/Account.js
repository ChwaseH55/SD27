// src/components/Account.js
import React from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { logoutUser } from '../reducers/userReducer'; // Adjust the path if necessary
import { useNavigate } from 'react-router-dom';

const Account = () => {
    const dispatch = useDispatch();
    const navigate = useNavigate();
    const user = useSelector((state) => state.user.user); // Access the user state from the Redux store

    const handleLogout = () => {
        dispatch(logoutUser());
        navigate('/login'); // Redirect to login page after logout
    };

    return (
        <div className="flex justify-center items-center min-h-screen bg-gray-100">
            <div className="w-full max-w-md bg-white p-8 rounded shadow-lg">
                <h2 className="text-3xl font-bold text-center mb-6">Account</h2>
                {user ? (
                    <div>
                        <p className="mb-4">Welcome, {user.username}!</p>
                        <p className="mb-4">Email: {user.email}</p>
                        <button
                            onClick={handleLogout}
                            className="bg-red-500 text-white font-semibold py-2 rounded hover:bg-red-600 transition w-full"
                        >
                            Logout
                        </button>
                    </div>
                ) : (
                    <p className="text-center">You are not logged in.</p>
                )}
            </div>
        </div>
    );
};

export default Account;
