// src/components/Login.js
import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import { login } from '../reducers/userReducer';
import { useNavigate } from 'react-router-dom'; // Change here

const Login = () => {
    const dispatch = useDispatch();
    const navigate = useNavigate(); // Change here
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [errorMessage, setErrorMessage] = useState('');

    const handleLogin = async (e) => {
        e.preventDefault();
        const result = await dispatch(login(username, password));
        if (result.error) {
            setErrorMessage(result.error.message); // Show error if login fails
        } else {
            navigate('/home'); // Use navigate for redirection
        }
    };
    

    return (
        <div className="flex justify-center items-center min-h-screen bg-gray-100">
            <div className="w-full max-w-md bg-white p-8 rounded shadow-lg">
                <h2 className="text-3xl font-bold text-center mb-6">Login</h2>
                {errorMessage && <p className="text-red-500">{errorMessage}</p>}
                <form onSubmit={handleLogin} className="flex flex-col space-y-4">
                    <input
                        type="text"
                        placeholder="Username"
                        value={username}
                        onChange={(e) => setUsername(e.target.value)}
                        className="border border-gray-300 rounded p-3 focus:outline-none focus:border-blue-500"
                        required
                    />
                    <input
                        type="password"
                        placeholder="Password"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        className="border border-gray-300 rounded p-3 focus:outline-none focus:border-blue-500"
                        required
                    />
                    <button type="submit" className="bg-blue-500 text-white font-semibold py-3 rounded hover:bg-blue-600 transition">
                        Login
                    </button>
                </form>
            </div>
        </div>
    );
};

export default Login;
