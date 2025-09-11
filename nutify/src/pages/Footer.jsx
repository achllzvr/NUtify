import React, { useEffect } from "react";
import "../styles/footer.css";
import AOS from "aos";
import "aos/dist/aos.css";

const Footer = () => {
  useEffect(() => {
    AOS.init({ duration: 500, easing: "ease-out", once: true });
    const onLoad = () => AOS.refresh();
    window.addEventListener("load", onLoad);
    return () => window.removeEventListener("load", onLoad);
  }, []);
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
        <div
          className="footer-download-buttons"
        >
          <button type="button" className="footer-cta-btn footer-cta-btn--android">
            Download for Android
          </button>
          <button type="button" className="footer-cta-btn footer-cta-btn--ios" disabled>
            IOS - Under Development
          </button>
        </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
