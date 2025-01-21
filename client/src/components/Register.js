import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import { register } from '../reducers/userReducer';
import { useNavigate, Link } from 'react-router-dom';
import clubLogo from '../assets/clublogo.png';

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
        const resultAction = await dispatch(register({ username, email, password, firstName, lastName }));
        if (resultAction.success) {
            navigate('/home');
        } else {
            console.error(resultAction.error);
            alert("Registration failed: " + resultAction.error);
        }
    };

    return (
        <div className="flex justify-center items-center min-h-screen bg-gradient-to-b from-gray-800 to-yellow-500 text-white">
            <div className="w-full max-w-md bg-gray-900 bg-opacity-90 p-8 rounded-lg shadow-2xl">
                <div className="flex justify-between items-center mb-6">
                    <img src={clubLogo} alt="UCF Golf Club Logo" className="h-12" />
                    <Link to="/" className="text-yellow-400 hover:underline text-lg">Home</Link>
                </div>
                <h2 className="text-4xl font-extrabold text-center mb-6">Register</h2>
                <form onSubmit={handleRegister} className="flex flex-col space-y-4">
                    <input
                        type="text"
                        placeholder="First Name"
                        value={firstName}
                        onChange={(e) => setFirstName(e.target.value)}
                        className="border border-gray-400 bg-gray-800 text-white rounded-lg p-3 focus:outline-none focus:border-yellow-500"
                        required
                    />
                    <input
                        type="text"
                        placeholder="Last Name"
                        value={lastName}
                        onChange={(e) => setLastName(e.target.value)}
                        className="border border-gray-400 bg-gray-800 text-white rounded-lg p-3 focus:outline-none focus:border-yellow-500"
                        required
                    />
                    <input
                        type="text"
                        placeholder="Username"
                        value={username}
                        onChange={(e) => setUsername(e.target.value)}
                        className="border border-gray-400 bg-gray-800 text-white rounded-lg p-3 focus:outline-none focus:border-yellow-500"
                        required
                    />
                    <input
                        type="email"
                        placeholder="Email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
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
                    <button type="submit" className="bg-yellow-500 text-gray-900 font-semibold py-3 rounded-lg hover:bg-yellow-600 transition">
                        Register
                    </button>
                </form>
                <p className="text-center mt-4">
                    Already have an account? <Link to="/login" className="text-yellow-400 hover:underline">Log In</Link>
                </p>
            </div>
        </div>
    );
};

export default Register;
