// src/components/Register.js
import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import { register } from '../reducers/userReducer';
import { useNavigate } from 'react-router-dom';

const Register = () => {
    const dispatch = useDispatch();
    const navigate = useNavigate();
    const [username, setUsername] = useState('');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');

    const handleRegister = async (e) => {
        e.preventDefault();
        const resultAction = await dispatch(register({ username, email, password })); // Wait for the result
        if (resultAction.success) { // Check if registration was successful
            navigate('/home'); // Navigate only on success
        } else {
            // Handle unsuccessful registration (e.g., show an error message)
            console.error(resultAction.error); // Log error to console for debugging
            alert("Registration failed: " + resultAction.error); // Show error message to user
        }
    };
    

    return (
        <div className="flex justify-center items-center min-h-screen bg-gray-100">
            <div className="w-full max-w-md bg-white p-8 rounded shadow-lg">
                <h2 className="text-3xl font-bold text-center mb-6">Register</h2>
                <form onSubmit={handleRegister} className="flex flex-col space-y-4">
                    <input
                        type="text"
                        placeholder="Username"
                        value={username}
                        onChange={(e) => setUsername(e.target.value)}
                        className="border border-gray-300 rounded p-3 focus:outline-none focus:border-blue-500"
                        required
                    />
                    <input
                        type="email"
                        placeholder="Email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
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
                        Register
                    </button>
                </form>
            </div>
        </div>
    );
};

export default Register;
