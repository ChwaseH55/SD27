// src/components/Landing.js

import React, { useEffect, useRef, useState } from 'react';
import { Link } from 'react-router-dom';
import { animateScroll as scroll, scroller } from 'react-scroll';
import AOS from 'aos';
import 'aos/dist/aos.css';
import clubLogo from '../assets/clublogo.png';
import Slider from 'react-slick';
import 'slick-carousel/slick/slick.css';
import 'slick-carousel/slick/slick-theme.css';
import emailjs from 'emailjs-com';

// Import exec board images
import execMember1 from '../assets/execboard/471294236_1117996383069418_2993765188952339883_n.jpg';
import execMember2 from '../assets/execboard/470944725_8852936081489973_5452253135322192659_n.jpg';
import execMember3 from '../assets/execboard/470894590_1612485296025133_2846590518025244253_n.jpg';
import execMember4 from '../assets/execboard/470944334_1802348343638415_735853040215810675_n.jpg';
import execMember5 from '../assets/execboard/470921057_641427514875234_8954534738715237090_n.jpg';
import execMember6 from '../assets/execboard/470944748_2009128262847496_6111136960068735296_n.jpg';

// Custom CSS for Instagram carousel
const customStyles = `
  .instagram-slide {
    transition: all 0.3s ease;
    transform: scale(0.85);
    opacity: 0.7;
  }
  
  .slick-center .instagram-slide {
    transform: scale(1);
    opacity: 1;
  }
  
  .slick-slide {
    padding: 0 10px;
  }
  
  /* Hide the caption section to make posts more compact */
  .instagram-media p {
    display: none !important;
  }
  
  /* Reduce padding inside Instagram embeds */
  .instagram-media div {
    padding-top: 8px !important;
    padding-bottom: 8px !important;
  }
`;

const Landing = () => {
  const [formStatus, setFormStatus] = useState({
    submitted: false,
    success: false,
    message: ''
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [showContactModal, setShowContactModal] = useState(false);

  // Initialize EmailJS
  useEffect(() => {
    emailjs.init(process.env.REACT_APP_EMAILJS_USER_ID || "YOUR_USER_ID");
  }, []);

  // Add Instagram script loading
  useEffect(() => {
    // Initialize AOS (Animate On Scroll) Library
    AOS.init({
      duration: 800,
      once: true,
    });
    
    // Load Instagram embed script
    const script = document.createElement('script');
    script.src = '//www.instagram.com/embed.js';
    script.async = true;
    document.body.appendChild(script);
    
    return () => {
      document.body.removeChild(script);
    };
  }, []);

  // Reference to slider
  const sliderRef = useRef(null);
  
  // Reload Instagram embeds after slider changes
  const reloadInstagramEmbeds = () => {
    if (window.instgrm) {
      window.instgrm.Embeds.process();
    }
  };

  // Process embeds on slide change
  const handleBeforeChange = (current, next) => {
    // Small delay to ensure DOM is updated before processing embeds
    setTimeout(() => {
      if (window.instgrm) {
        window.instgrm.Embeds.process();
      }
    }, 300);
  };

  const scrollToSection = (sectionId) => {
    scroller.scrollTo(sectionId, {
      duration: 800,
      delay: 0,
      smooth: 'easeInOutQuart',
      offset: -80, // Adjust for fixed navbar height
    });
  };

  // Slider settings
  const settings = {
    dots: true,
    infinite: true,
    speed: 500,
    slidesToShow: 3,
    slidesToScroll: 1,
    autoplay: true,
    autoplaySpeed: 5000,
    arrows: true,
    beforeChange: handleBeforeChange,
    afterChange: reloadInstagramEmbeds,
    onInit: reloadInstagramEmbeds,
    lazyLoad: true,
    centerMode: true,
    centerPadding: '0px',
    responsive: [
      {
        breakpoint: 1024,
        settings: {
          slidesToShow: 1,
          centerMode: true
        }
      }
    ]
  };

  const galleryStyle = {
    maxHeight: '500px',
    overflow: 'hidden'
  };

  const slideStyle = (index) => ({
    transform: 'scale(0.85)',
    opacity: 0.7,
    transition: 'all 0.3s ease'
  });

  const activeSlideStyle = {
    transform: 'scale(1)',
    opacity: 1,
    transition: 'all 0.3s ease'
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsSubmitting(true);
    
    const name = e.target.name.value;
    const subject = e.target.subject.value;
    const message = e.target.message.value;
    const email = e.target.email.value;

    const templateParams = {
      to_email: 'chase.hanson9@gmail.com',
      from_name: name,
      subject: subject,
      message: message,
      reply_to: email
    };

    try {
      await emailjs.send(
        process.env.REACT_APP_EMAILJS_SERVICE_ID || 'YOUR_SERVICE_ID',
        process.env.REACT_APP_EMAILJS_TEMPLATE_ID || 'YOUR_TEMPLATE_ID',
        templateParams
      );
      
      setFormStatus({
        submitted: true,
        success: true,
        message: `Thanks for your message, ${name}! We'll get back to you soon.`
      });
      
      // Clear the form
      e.target.reset();
    } catch (error) {
      console.error('Error sending email:', error);
      setFormStatus({
        submitted: true,
        success: false,
        message: 'There was an error sending your message. Please try again or contact us directly.'
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  // Function to toggle contact modal
  const toggleContactModal = () => {
    setShowContactModal(!showContactModal);
    // Reset form status when opening modal
    if (!showContactModal) {
      setFormStatus({
        submitted: false,
        success: false,
        message: ''
      });
    }
  };

  return (
    <div className="flex flex-col min-h-screen bg-white text-gray-800">
      {/* Add custom styles */}
      <style>{customStyles}</style>
      
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

      {/* Subtle divider */}
      <div className="w-full max-w-6xl mx-auto">
        <div className="h-px bg-gradient-to-r from-transparent via-gray-300 to-transparent"></div>
      </div>

      {/* Team Members Section */}
      <section id="team" className="py-16 px-8">
        <div className="max-w-7xl mx-auto" data-aos="fade-up">
          <h2 className="text-4xl font-bold text-center mb-12">Meet the Team</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {/* Team Member Card - President */}
            <div
              className="bg-white shadow-lg rounded-lg p-6 flex flex-col items-center"
              data-aos="zoom-in"
            >
              <img
                src={execMember1}
                alt="President"
                className="w-40 h-40 rounded-full mb-4 object-cover border-4 border-yellow-500"
              />
              <h3 className="text-xl font-semibold mb-1">Matthew Tigrett</h3>
              <p className="text-gray-600 font-medium">President</p>
            </div>
            
            {/* Team Member Card - Vice President */}
            <div
              className="bg-white shadow-lg rounded-lg p-6 flex flex-col items-center"
              data-aos="zoom-in"
              data-aos-delay="100"
            >
              <img
                src={execMember2}
                alt="Vice President"
                className="w-40 h-40 rounded-full mb-4 object-cover border-4 border-yellow-500"
              />
              <h3 className="text-xl font-semibold mb-1">Alex Hanfling</h3>
              <p className="text-gray-600 font-medium">Social Media Manager</p>
            </div>
            
            {/* Team Member Card - Treasurer */}
            <div
              className="bg-white shadow-lg rounded-lg p-6 flex flex-col items-center"
              data-aos="zoom-in"
              data-aos-delay="200"
            >
              <img
                src={execMember3}
                alt="Treasurer"
                className="w-40 h-40 rounded-full mb-4 object-cover border-4 border-yellow-500"
              />
              <h3 className="text-xl font-semibold mb-1">Jason Wong</h3>
              <p className="text-gray-600 font-medium">Tournament Manager</p>
            </div>
            
            {/* Team Member Card - Secretary */}
            <div
              className="bg-white shadow-lg rounded-lg p-6 flex flex-col items-center"
              data-aos="zoom-in"
              data-aos-delay="300"
            >
              <img
                src={execMember4}
                alt="Secretary"
                className="w-40 h-40 rounded-full mb-4 object-cover border-4 border-yellow-500"
              />
              <h3 className="text-xl font-semibold mb-1">Abby Compton</h3>
              <p className="text-gray-600 font-medium">Risk Manager</p>
            </div>
            
            {/* Team Member Card - Events Coordinator */}
            <div
              className="bg-white shadow-lg rounded-lg p-6 flex flex-col items-center"
              data-aos="zoom-in"
              data-aos-delay="400"
            >
              <img
                src={execMember5}
                alt="Events Coordinator"
                className="w-40 h-40 rounded-full mb-4 object-cover border-4 border-yellow-500"
              />
              <h3 className="text-xl font-semibold mb-1">Peyton Leach</h3>
              <p className="text-gray-600 font-medium">Vice President</p>
            </div>
            
            {/* Team Member Card - Social Media Manager */}
            <div
              className="bg-white shadow-lg rounded-lg p-6 flex flex-col items-center"
              data-aos="zoom-in"
              data-aos-delay="500"
            >
              <img
                src={execMember6}
                alt="Social Media Manager"
                className="w-40 h-40 rounded-full mb-4 object-cover border-4 border-yellow-500"
              />
              <h3 className="text-xl font-semibold mb-1">Elle Folland</h3>
              <p className="text-gray-600 font-medium">Treasurer</p>
            </div>
          </div>
          
          {/* View Instagram Post Link */}
          <div className="text-center mt-12">
            <a 
              href="https://www.instagram.com/p/DD0EI1exf_q/" 
              target="_blank" 
              rel="noreferrer"
              className="inline-flex items-center text-yellow-600 hover:text-yellow-700"
            >
              <svg className="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/>
              </svg>
              View full team on Instagram
            </a>
          </div>
        </div>
      </section>

      {/* Subtle divider */}
      <div className="w-full max-w-6xl mx-auto">
        <div className="h-px bg-gradient-to-r from-transparent via-gray-300 to-transparent"></div>
      </div>

      {/* Photo Gallery Section */}
      <section id="gallery" className="py-10 px-8">
        <div className="max-w-7xl mx-auto text-center" data-aos="fade-up">
          <h2 className="text-4xl font-bold mb-8">Gallery</h2>
          <div className="max-w-5xl mx-auto" style={galleryStyle}>
            <Slider ref={sliderRef} {...settings}>
              {/* Instagram Post 1 */}
              <div className="px-2 instagram-slide">
                <div className="instagram-container" style={{ maxWidth: '350px', margin: '0 auto' }}>
                  <blockquote 
                    className="instagram-media" 
                    data-instgrm-captioned 
                    data-instgrm-permalink="https://www.instagram.com/p/DG6WHMOOnBf/?utm_source=ig_embed&amp;utm_campaign=loading" 
                    data-instgrm-version="14"
                    style={{ 
                      background: '#FFF',
                      border: 0,
                      borderRadius: '3px',
                      boxShadow: '0 0 1px 0 rgba(0,0,0,0.5),0 1px 10px 0 rgba(0,0,0,0.15)',
                      margin: '1px',
                      maxWidth: '350px',
                      minWidth: '280px',
                      padding: 0,
                      width: '100%'
                    }}
                  >
                  </blockquote>
                </div>
              </div>
              
              {/* Instagram Post 2 */}
              <div className="px-2 instagram-slide">
                <div className="instagram-container" style={{ maxWidth: '350px', margin: '0 auto' }}>
                  <blockquote 
                    className="instagram-media" 
                    data-instgrm-captioned 
                    data-instgrm-permalink="https://www.instagram.com/p/DGowIkGOmwL/?utm_source=ig_embed&amp;utm_campaign=loading" 
                    data-instgrm-version="14"
                    style={{ 
                      background: '#FFF',
                      border: 0,
                      borderRadius: '3px',
                      boxShadow: '0 0 1px 0 rgba(0,0,0,0.5),0 1px 10px 0 rgba(0,0,0,0.15)',
                      margin: '1px',
                      maxWidth: '350px',
                      minWidth: '280px',
                      padding: 0,
                      width: '100%'
                    }}
                  >
                  </blockquote>
                </div>
              </div>
              
              {/* Instagram Post 3 */}
              <div className="px-2 instagram-slide">
                <div className="instagram-container" style={{ maxWidth: '350px', margin: '0 auto' }}>
                  <blockquote 
                    className="instagram-media" 
                    data-instgrm-captioned 
                    data-instgrm-permalink="https://www.instagram.com/p/DGdwdneunwO/?utm_source=ig_embed&amp;utm_campaign=loading" 
                    data-instgrm-version="14"
                    style={{ 
                      background: '#FFF',
                      border: 0,
                      borderRadius: '3px',
                      boxShadow: '0 0 1px 0 rgba(0,0,0,0.5),0 1px 10px 0 rgba(0,0,0,0.15)',
                      margin: '1px',
                      maxWidth: '350px',
                      minWidth: '280px',
                      padding: 0,
                      width: '100%'
                    }}
                  >
                  </blockquote>
                </div>
              </div>
            </Slider>
          </div>
          <div className="flex justify-center mt-4">
            <button 
              className="mx-2 px-4 py-2 bg-gray-200 rounded-full hover:bg-gray-300 transition"
              onClick={() => sliderRef.current.slickPrev()}
            >
              Previous
            </button>
            <button 
              className="mx-2 px-4 py-2 bg-yellow-500 text-white rounded-full hover:bg-yellow-600 transition"
              onClick={() => sliderRef.current.slickNext()}
            >
              Next
            </button>
          </div>
        </div>
      </section>

      {/* Subtle divider */}
      <div className="w-full max-w-6xl mx-auto">
        <div className="h-px bg-gradient-to-r from-transparent via-gray-300 to-transparent"></div>
      </div>

      {/* Contact Section */}
      <section id="contact" className="py-16 px-8 bg-gray-50">
        <div className="max-w-5xl mx-auto" data-aos="fade-up">
          <h2 className="text-4xl font-bold text-center mb-8">Get in Touch</h2>
          <p className="text-lg text-center mb-8">
            Have questions or want to learn more? Reach out to us!
          </p>
          
          <div className="text-center">
            <button
              onClick={toggleContactModal}
              className="px-8 py-4 bg-yellow-500 text-white rounded-full text-lg font-semibold hover:bg-yellow-600 transition"
            >
              Contact Us
            </button>
          </div>
        </div>
      </section>

      {/* Contact Modal */}
      {showContactModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-90vh overflow-y-auto">
            <div className="flex justify-between items-center p-6 border-b">
              <h3 className="text-2xl font-bold text-gray-800">Contact Us</h3>
              <button 
                onClick={toggleContactModal}
                className="text-gray-400 hover:text-gray-600"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12"></path>
                </svg>
              </button>
            </div>
            
            <div className="p-6">
              {formStatus.submitted && (
                <div className={`mb-6 p-4 rounded-md ${formStatus.success ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
                  {formStatus.message}
                </div>
              )}
              <form className="space-y-6" onSubmit={handleSubmit}>
                <div>
                  <label htmlFor="name" className="block text-gray-700 text-sm font-bold mb-2">
                    Your Name
                  </label>
                  <input
                    type="text"
                    id="name"
                    name="name"
                    required
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-yellow-500"
                    placeholder="John Doe"
                  />
                </div>
                
                <div>
                  <label htmlFor="email" className="block text-gray-700 text-sm font-bold mb-2">
                    Your Email
                  </label>
                  <input
                    type="email"
                    id="email"
                    name="email"
                    required
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-yellow-500"
                    placeholder="john@example.com"
                  />
                </div>
                
                <div>
                  <label htmlFor="subject" className="block text-gray-700 text-sm font-bold mb-2">
                    Subject
                  </label>
                  <input
                    type="text"
                    id="subject"
                    name="subject"
                    required
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-yellow-500"
                    placeholder="Membership Inquiry"
                  />
                </div>
                
                <div>
                  <label htmlFor="message" className="block text-gray-700 text-sm font-bold mb-2">
                    Message
                  </label>
                  <textarea
                    id="message"
                    name="message"
                    rows="5"
                    required
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-yellow-500"
                    placeholder="Your message here..."
                  ></textarea>
                </div>
                
                <div>
                  <button
                    type="submit"
                    disabled={isSubmitting}
                    className={`w-full px-4 py-3 text-white font-semibold rounded-md transition duration-300 ${isSubmitting 
                      ? 'bg-yellow-400 cursor-not-allowed' 
                      : 'bg-yellow-500 hover:bg-yellow-600'}`}
                  >
                    {isSubmitting ? 'Sending...' : 'Send Message'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}

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
            <button onClick={() => scrollToSection('team')} className="hover:underline">
              Team
            </button>
            <button onClick={() => scrollToSection('gallery')} className="hover:underline">
              Gallery
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