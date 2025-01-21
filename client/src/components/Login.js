import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import { login } from '../reducers/userReducer';
import { useNavigate, Link } from 'react-router-dom';
import clubLogo from '../assets/clublogo.png';

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
        <div className="flex justify-center items-center min-h-screen bg-gradient-to-b from-gray-800 to-yellow-500 text-white">
            <div className="w-full max-w-md bg-gray-900 bg-opacity-90 p-8 rounded-lg shadow-2xl">
                <div className="flex justify-between items-center mb-6">
                    <img src={clubLogo} alt="UCF Golf Club Logo" className="h-12" />
                    <Link to="/" className="text-yellow-400 hover:underline text-lg">Home</Link>
                </div>
                <h2 className="text-4xl font-extrabold text-center mb-6">Welcome Back</h2>
                <p className="text-center text-gray-300 mb-6">
                    Log in to continue to your dashboard
                </p>
                {errorMessage && <p className="text-red-500 text-center mb-4">{errorMessage}</p>}
                <form onSubmit={handleLogin} className="flex flex-col space-y-4">
                    <input
                        type="text"
                        placeholder="Username"
                        value={username}
                        onChange={(e) => setUsername(e.target.value)}
                        className="border border-gray-400 bg-gray-800 text-white rounded-lg p-3 focus:outline-none focus:border-yellow-500"
                        required
                    />
                    <input
                        type="password"
                        placeholder="Password"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        className="border border-gray-400 bg-gray-800 text-white rounded-lg p-3 focus:outline-none focus:border-yellow-500"
                        required
                    />
                    <button
                        type="submit"
                        className="bg-yellow-500 text-gray-900 font-semibold py-3 rounded-lg hover:bg-yellow-600 transition"
                    >
                        Log In
                    </button>
                </form>
                <p className="text-center mt-4">
                    Don't have an account? <Link to="/register" className="text-yellow-400 hover:underline">Register</Link>
                </p>
            </div>
        </div>
    );
};

export default Login;
