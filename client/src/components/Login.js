// src/components/Login.js
import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import { login } from '../reducers/userReducer';
import { useNavigate } from 'react-router-dom';

const Login = () => {
    const dispatch = useDispatch();
    const navigate = useNavigate();
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [errorMessage, setErrorMessage] = useState('');

    const handleLogin = async (e) => {
        e.preventDefault();
        const result = await dispatch(login(username, password));
        if (result.error) {
            setErrorMessage(result.error.message);
        } else {
            navigate('/home');
        }
    };

    return (
        <div className="flex flex-col items-center min-h-screen bg-gradient-to-b from-blue-100 to-blue-200">
            <div className="w-full max-w-lg bg-white p-10 rounded-lg shadow-xl mt-20">
                <h2 className="text-4xl font-semibold text-center mb-4 text-blue-700">Welcome Back</h2>
                <p className="text-center text-gray-500 mb-6">
                    Log in to continue to your dashboard
                </p>
                {errorMessage && <p className="text-red-500 text-center mb-4">{errorMessage}</p>}
                <form onSubmit={handleLogin} className="flex flex-col space-y-5">
                    <input
                        type="text"
                        placeholder="Username"
                        value={username}
                        onChange={(e) => setUsername(e.target.value)}
                        className="border border-gray-300 rounded-lg p-3 focus:outline-none focus:ring focus:ring-blue-300 transition"
                        required
                    />
                    <input
                        type="password"
                        placeholder="Password"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        className="border border-gray-300 rounded-lg p-3 focus:outline-none focus:ring focus:ring-blue-300 transition"
                        required
                    />
                    <button
                        type="submit"
                        className="w-full bg-blue-500 text-white py-3 rounded-lg font-medium hover:bg-blue-600 transition"
                    >
                        Log In
                    </button>
                </form>
            </div>
        </div>
    );
};

export default Login;
