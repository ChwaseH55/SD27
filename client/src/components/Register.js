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
    const [firstName, setFirstName] = useState('');
    const [lastName, setLastName] = useState('');

    const handleRegister = async (e) => {
        e.preventDefault();
        console.log("Registering with:", { username, email, password, firstName, lastName });
        const resultAction = await dispatch(register({ username, email, password, firstName, lastName }));
        if (resultAction.success) {
            navigate('/home');
        } else {
            console.error(resultAction.error);
            alert("Registration failed: " + resultAction.error);
        }
    };
    
    return (
        <div className="flex justify-center items-center min-h-screen bg-gradient-to-b from-ucfBlack to-ucfGold text-white">
            <div className="w-full max-w-md bg-ucfDarkGray bg-opacity-70 p-8 rounded-lg shadow-lg">
                <h2 className="text-3xl font-bold text-center mb-6">Register</h2>
                <form onSubmit={handleRegister} className="flex flex-col space-y-4">
                    <input
                        type="text"
                        placeholder="First Name"
                        value={firstName}
                        onChange={(e) => setFirstName(e.target.value)}
                        className="border border-gray-400 bg-black bg-opacity-40 text-white rounded p-3 focus:outline-none focus:border-ucfGold"
                        required
                    />
                    <input
                        type="text"
                        placeholder="Last Name"
                        value={lastName}
                        onChange={(e) => setLastName(e.target.value)}
                        className="border border-gray-400 bg-black bg-opacity-40 text-white rounded p-3 focus:outline-none focus:border-ucfGold"
                        required
                    />
                    <input
                        type="text"
                        placeholder="Username"
                        value={username}
                        onChange={(e) => setUsername(e.target.value)}
                        className="border border-gray-400 bg-black bg-opacity-40 text-white rounded p-3 focus:outline-none focus:border-ucfGold"
                        required
                    />
                    <input
                        type="email"
                        placeholder="Email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        className="border border-gray-400 bg-black bg-opacity-40 text-white rounded p-3 focus:outline-none focus:border-ucfGold"
                        required
                    />
                    <input
                        type="password"
                        placeholder="Password"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        className="border border-gray-400 bg-black bg-opacity-40 text-white rounded p-3 focus:outline-none focus:border-ucfGold"
                        required
                    />
                    <button type="submit" className="bg-ucfGold text-ucfBlack font-semibold py-3 rounded hover:bg-opacity-80 transition">
                        Register
                    </button>
                </form>
            </div>
        </div>
    );
};

export default Register;
