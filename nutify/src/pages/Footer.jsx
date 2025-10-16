import React, { useEffect } from "react";
import "../styles/footer.css";
import AOS from "aos";
import "aos/dist/aos.css";

const Footer = () => {
  // Simple redirect, modal downloader not needed anymore

  // Redirect target for Android download
  const ANDROID_URL = "https://nationalueduph-my.sharepoint.com/:f:/g/personal/rabinaad_students_nu-lipa_edu_ph/EpQ_BGS_yBpGiIQCgLUtINoB1H0j8N66uZegIf3BMdrukg?e=63E80K";

  useEffect(() => {
    AOS.init({ duration: 500, easing: "ease-out", once: true });
    const onLoad = () => AOS.refresh();
    window.addEventListener("load", onLoad);
    return () => window.removeEventListener("load", onLoad);
  }, []);

  // no-op placeholders from previous modal implementation removed

  const startDownload = () => {
    // Simple redirect to external download page
    window.location.href = ANDROID_URL;
  };

  // no cancel needed for redirect

  // formatting helpers no longer needed

  // modal removed
  return (
    <footer className="footer-section">
      <div className="footer-content">
        <h2 className="footer-title" data-aos="fade-up">
          Ready to Simplify Your Academic Life?
        </h2>
        <div data-aos="fade-up" data-aos-delay="150">
        <p className="footer-desc" >
          Download Nutify today to reclaim your time, streamline student
          interactions, and make appointment management effortless. Take control
          of your schedule and stay connected like never before.
        </p>
        <div className="footer-download-buttons">
          <button type="button" className="footer-cta-btn footer-cta-btn--android" onClick={startDownload}>
            Download for Android
          </button>
          <button type="button" className="footer-cta-btn footer-cta-btn--ios" disabled>
            IOS - Under Development
          </button>
        </div>
        </div>
      </div>
  {/* modal removed */}
    </footer>
  );
};

export default Footer;
