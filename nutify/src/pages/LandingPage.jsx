import React from "react";
import "../styles/hero.css";
import Navbar from "./Navbar";
import StudentContent from "./StudentContent";
import TeacherContent from "./TeacherContent";
import Footer from "./Footer";

const LandingPage = () => {
  return (
    <div className="landing-page">
      <Navbar />
      <section className="hero">
        <div className="hero-main-container">
          <div className="hero-text-content">
            <h1 className="hero-title">
              STAY CONNECTED
              <br />
              STAY UPDATED
            </h1>
            <p className="hero-paragraph">
              NUtify keeps the entire academic community in touch. Get real-time
              notifications for consultations, appointment updates, and important
              announcements, all in one place. School coordination has never been
              simpler, faster, or more efficient.
            </p>
          </div>
          <div className="hero-image-wrap">
            <img
              src="/facultystudent.png"
              alt="Faculty and Student App"
              className="hero-image"
            />
          </div>
        </div>
      </section>
      <StudentContent />
      <TeacherContent />
      <Footer />
    </div>
  );
};

export default LandingPage;