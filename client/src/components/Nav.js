import React from 'react';
import { Link } from 'react-router-dom';

const Nav = () => {
  return (
    <nav className="bg-blue-500 p-4">
      <ul className="flex space-x-4">
        <li>
          <Link to="/" className="text-white hover:text-gray-200">About</Link>
        </li>
        <li>
          <Link to="/register" className="text-white hover:text-gray-200">Register</Link>
        </li>
        <li>
          <Link to="/login" className="text-white hover:text-gray-200">Login</Link>
        </li>
      </ul>
    </nav>
  );
};

export default Nav;
