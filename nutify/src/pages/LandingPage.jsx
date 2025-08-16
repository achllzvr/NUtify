import React from 'react';
import '../styles/hero.css';
import { useNavigate } from 'react-router-dom';

const LandingPage = () => {
  const navigate = useNavigate();

  return (
    <div className="landing-body">
      <div className="top-left-logo">
        <img src="/NUtifywhite.png" alt="NUtify Logo" />
      </div>
      <div className="hero-container">
        <div className="hero-content">
          <div className="hero-text-section">
            <div className="hero-title">
              <h1 className="hero-main-title">
                STAY CONNECTED<br />
                STAY UPDATED
              </h1>
            </div>
            
            <div className="hero-description">
              <p>
                NUtify is a student-professor communication app designed to keep you informed and in touch. 
                Get real-time notifications for consultation requests, appointment updates, and important academic 
                announcements, all in one place. With NUtify, school coordination is simpler, faster, and more efficient.
              </p>
            </div>
            
            <div className="hero-buttons">
              <button
                className="hero-btn primary"
                onClick={() => navigate('/login')}
              >
                Login to your NUtify account
              </button>
              <button className="hero-btn secondary">
                Download for Android
              </button>
            </div>
          </div>
          
          <div className="hero-image-section">
            <div className="device-mockup">
              <img src="/Mockup.png" alt="NUtify App Mockup" />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default LandingPage;
