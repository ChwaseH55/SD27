// src/components/Landing.js

import React, { useEffect } from 'react';
import { Link } from 'react-router-dom';
import { animateScroll as scroll, scroller } from 'react-scroll';
import AOS from 'aos';
import 'aos/dist/aos.css';
import clubLogo from '../assets/clublogo.png';

const Landing = () => {
  useEffect(() => {
    // Initialize AOS (Animate On Scroll) Library
    AOS.init({
      duration: 800,
      once: true,
    });
  }, []);

  const scrollToSection = (sectionId) => {
    scroller.scrollTo(sectionId, {
      duration: 800,
      delay: 0,
      smooth: 'easeInOutQuart',
      offset: -80, // Adjust for fixed navbar height
    });
  };

  return (
    <div className="flex flex-col min-h-screen bg-white text-gray-800">
      {/* Navbar */}
      <nav className="fixed top-0 left-0 w-full flex justify-between items-center px-6 py-4 z-20 bg-white bg-opacity-90 shadow-md backdrop-filter backdrop-blur-lg">
        <div className="flex items-center">
          <img src={clubLogo} alt="UCF Golf Club" className="h-10 mr-3" />
          <span className="text-2xl font-bold text-gray-800">UCF Golf Club</span>
        </div>
        <div className="flex items-center gap-6">
          <button
            onClick={() => scrollToSection('about')}
            className="text-gray-800 hover:text-yellow-500 transition"
          >
            About
          </button>
          <button
            onClick={() => scrollToSection('team')}
            className="text-gray-800 hover:text-yellow-500 transition"
          >
            Team
          </button>
          <button
            onClick={() => scrollToSection('events')}
            className="text-gray-800 hover:text-yellow-500 transition"
          >
            Events
          </button>
          <button
            onClick={() => scrollToSection('gallery')}
            className="text-gray-800 hover:text-yellow-500 transition"
          >
            Gallery
          </button>
          <button
            onClick={() => scrollToSection('contact')}
            className="text-gray-800 hover:text-yellow-500 transition"
          >
            Contact
          </button>
          <Link to="/login">
            <button className="px-4 py-2 bg-transparent border border-yellow-500 text-yellow-500 rounded hover:bg-yellow-500 hover:text-white transition">
              Login
            </button>
          </Link>
          <Link to="/register">
            <button className="px-4 py-2 bg-yellow-500 text-white rounded hover:bg-yellow-600 transition">
              Register
            </button>
          </Link>
        </div>
      </nav>

      {/* Hero Section */}
      <header
        id="hero"
        className="relative bg-cover bg-center min-h-screen flex items-center justify-center"
        style={{ backgroundImage: `url(${clubLogo})` }}
      >
        {/* Overlay */}
        <div className="absolute inset-0 bg-black bg-opacity-60"></div>
        {/* Hero Content */}
        <div
          className="relative z-10 text-center text-white px-4"
          data-aos="fade-in"
        >
          <h1 className="text-5xl md:text-7xl font-extrabold mb-6">
            Welcome to the UCF Golf Club
          </h1>
          <p className="text-xl md:text-2xl max-w-2xl mx-auto mb-8">
            Join our community of passionate golfers at the University of Central Florida.
          </p>
          <Link to="/register">
            <button className="mt-4 px-8 py-4 bg-yellow-500 text-white rounded-full text-lg font-semibold hover:bg-yellow-600 transition">
              Become a Member
            </button>
          </Link>
        </div>
        {/* Scroll Down Indicator */}
        <div className="absolute bottom-10 left-1/2 transform -translate-x-1/2">
          <button onClick={() => scrollToSection('about')}>
            <svg
              className="w-8 h-8 text-white animate-bounce"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
            </svg>
          </button>
        </div>
      </header>

      {/* About Us Section */}
      <section id="about" className="py-16 px-8 bg-gray-50">
        <div className="max-w-5xl mx-auto text-center" data-aos="fade-up">
          <h2 className="text-4xl font-bold mb-8">About Us</h2>
          <p className="text-lg mb-6">
            The UCF Golf Club is dedicated to promoting the sport of golf among students and faculty.
            Whether you're a seasoned player or just starting out, our club offers something for everyone.
          </p>
          <p className="text-lg">
            We host regular tournaments, training sessions, and social events to bring together golf enthusiasts at UCF.
          </p>
        </div>
      </section>

      {/* Team Members Section */}
      <section id="team" className="py-16 px-8">
        <div className="max-w-7xl mx-auto" data-aos="fade-up">
          <h2 className="text-4xl font-bold text-center mb-12">Meet the Team</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {/* Team Member Card */}
            <div
              className="bg-white shadow-lg rounded-lg p-6 flex flex-col items-center"
              data-aos="zoom-in"
            >
              <img
                src={clubLogo}
                alt="Team Member"
                className="w-32 h-32 rounded-full mb-4 object-cover"
              />
              <h3 className="text-xl font-semibold mb-2">Alex Johnson</h3>
              <p className="text-gray-600">Club President</p>
            </div>
          </div>
        </div>
      </section>

      {/* Upcoming Events Section */}
      <section id="events" className="py-16 px-8 bg-gray-50">
        <div className="max-w-7xl mx-auto" data-aos="fade-up">
          <h2 className="text-4xl font-bold text-center mb-12">Upcoming Events</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div
              className="bg-white shadow-lg rounded-lg p-6 flex flex-col"
              data-aos="fade-up"
              data-aos-delay="100"
            >
              <h3 className="text-2xl font-semibold mb-2">Spring Tournament</h3>
              <p className="text-gray-600 mb-4">March 15, 2024</p>
              <p className="text-gray-700 mb-6">
                Join us for our annual spring tournament. All skill levels welcome!
              </p>
              <Link to="/events" className="mt-auto">
                <button className="px-6 py-2 bg-yellow-500 text-white rounded-full hover:bg-yellow-600 transition">
                  Learn More
                </button>
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* Photo Gallery Section */}
      <section id="gallery" className="py-16 px-8">
        <div className="max-w-7xl mx-auto text-center" data-aos="fade-up">
          <h2 className="text-4xl font-bold mb-12">Gallery</h2>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <img
              src={clubLogo}
              alt="Gallery"
              className="w-full h-48 object-cover rounded-lg"
              data-aos="zoom-in"
            />
          </div>
        </div>
      </section>

      {/* Contact Section */}
      <section id="contact" className="py-16 px-8 bg-gray-50">
        <div className="max-w-5xl mx-auto text-center" data-aos="fade-up">
          <h2 className="text-4xl font-bold mb-8">Get in Touch</h2>
          <p className="text-lg mb-6">
            Have questions or want to learn more? Reach out to us!
          </p>
          <Link to="/contact">
            <button className="mt-6 px-8 py-4 bg-yellow-500 text-white rounded-full text-lg font-semibold hover:bg-yellow-600 transition">
              Contact Us
            </button>
          </Link>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-8 bg-gray-800 text-white">
        <div className="max-w-7xl mx-auto flex flex-col md:flex-row justify-between items-center px-4">
          <p className="text-center md:text-left">
            &copy; {new Date().getFullYear()} UCF Golf Club. All rights reserved.
          </p>
          <div className="flex gap-6 mt-4 md:mt-0">
            <button onClick={() => scrollToSection('about')} className="hover:underline">
              About
            </button>
            <button onClick={() => scrollToSection('events')} className="hover:underline">
              Events
            </button>
            <button onClick={() => scrollToSection('contact')} className="hover:underline">
              Contact
            </button>
            <Link to="/privacy" className="hover:underline">
              Privacy Policy
            </Link>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default Landing;
