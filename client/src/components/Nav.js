import React from 'react';
import { Link } from 'react-router-dom';

const Nav = () => {
  return (
    <nav className="flex justify-between items-center w-full p-4 bg-ucfBlack bg-opacity-70 fixed top-0 z-10">
    <div className="text-xl font-bold">Golf Club @ UCF</div>
    <div className="flex gap-4">
        <Link to="/login">
            <button className="px-4 py-2 text-ucfGold bg-gold rounded hover:bg-opacity-80 transition">
                Login
            </button>
        </Link>
        <Link to="/register">
            <button className="px-4 py-2 text-ucfGold bg-gold rounded hover:bg-opacity-80 transition">
                Register
            </button>
        </Link>
    </div>
</nav>
  );
};

export default Nav;
