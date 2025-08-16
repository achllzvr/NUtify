import React, { useEffect, useState } from 'react';
import '../styles/hero.css';
import { useNavigate } from 'react-router-dom';
import AOS from 'aos';
import 'aos/dist/aos.css';

const useScreenWidth = () => {
  const [width, setWidth] = useState(window.innerWidth);
  useEffect(() => {
    const handleResize = () => setWidth(window.innerWidth);
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);
  return width;
};

const LandingPage = () => {
  const navigate = useNavigate();
  const screenWidth = useScreenWidth();

  useEffect(() => {
    AOS.init({ once: true });
  }, []);

  // Animation logic based on screen width
  const isTablet = screenWidth <= 1024;

  return (
    <div className="landing-body">
      <div className="top-left-logo">
        <img src="/NUtifywhite.png" alt="NUtify Logo" />
      </div>
      
      <div className="hero-container">
        <div className="hero-content">
          <div className="hero-text-section">
            <div
              className="hero-title"
              data-aos={isTablet ? "fade-up" : "fade-right"}
              data-aos-delay={isTablet ? "300" : "0"}
              data-aos-duration="700"
            >
              <h1 className="hero-main-title">
                STAY CONNECTED<br />
                STAY UPDATED
              </h1>
            </div>
            
            <div
              className="hero-description"
              data-aos={isTablet ? "fade-up" : "fade-right"}
              data-aos-delay={isTablet ? "500" : "400"}
              data-aos-duration="700"
            >
              <p>
                NUtify is a student-professor communication app designed to keep you informed and in touch. 
                Get real-time notifications for consultation requests, appointment updates, and important academic 
                announcements, all in one place. With NUtify, school coordination is simpler, faster, and more efficient.
              </p>
            </div>
            
            <div
              className="hero-buttons"
              data-aos={isTablet ? "fade-up" : "fade-right"}
              data-aos-delay={isTablet ? "700" : "700"}
              data-aos-duration="700"
            >
              <button
                className="hero-btn primary"
                onClick={() => navigate('/login')}
              >
                Admin Dashboard
              </button>
              <button className="hero-btn secondary">
              NUtify for Students and Faculty
              </button>
            </div>
          </div>
          
          <div
            className="hero-image-section"
            data-aos="fade-left"
            data-aos-delay={isTablet ? "0" : "200"}
            data-aos-duration="700"
          >
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
