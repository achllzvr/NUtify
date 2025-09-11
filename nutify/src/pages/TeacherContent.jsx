import React, { useEffect } from "react";
import "../styles/teachercontent.css";
import AOS from "aos";
import "aos/dist/aos.css";
import clockIcon from "../assets/icons/clock.svg";

const TeacherContent = () => {
  useEffect(() => {
    AOS.init({ duration: 500, easing: "ease-out", once: true });
    const onLoad = () => AOS.refresh();
    window.addEventListener("load", onLoad);
    return () => window.removeEventListener("load", onLoad);
  }, []);
  return (
    <section className="teacher-content-section">
      <div className="teacher-content-header">
        <h1 className="teacher-content-title" data-aos="fade-up">
          Your Schedule, Streamlined
        </h1>
        <p
          className="teacher-content-subtitle"
          data-aos="fade-up"
          data-aos-delay="150"
        >
          Your time is valuable. Nutify makes student appointments simple and
          powerful, giving you full control with an intuitive interface that
          fits your busy life.
        </p>
      </div>
      <div className="teacher-content-body">
        <div
          className="teacher-content-text"
          data-aos="fade-up"
          data-aos-delay="200"
        >
          <img
            src={clockIcon}
            alt="Clock"
            style={{ width: 48, height: 48, marginBottom: "0.5rem" }}
          />
          <h2 className="teacher-content-feature-title">
            Streamline Your Workflow
          </h2>
          <p className="teacher-content-feature-desc">
            Reclaim your time and streamline your workflow. Effortlessly manage
            and track all student appointments from one intuitive interface.
            Focus on excellence while fostering stronger connections and better
            outcomes.
          </p>
        </div>
        <div
          className="teacher-content-image-wrap"
          data-aos="fade-up"
          data-aos-delay="250"
        >
          <img
            src="Faculty.png"
            alt="Teacher App"
            className="teacher-content-image"
          />
        </div>
      </div>
    </section>
  );
};

export default TeacherContent;
