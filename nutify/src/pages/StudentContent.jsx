import React, { useEffect } from "react";
import "../styles/studentcontent.css";
import AOS from "aos";
import "aos/dist/aos.css";
import calendarIcon from "../assets/icons/calendar.svg";

const StudentContent = () => {
  useEffect(() => {
    AOS.init({ duration: 500, easing: "ease-out", once: true });
    const onLoad = () => AOS.refresh();
    window.addEventListener("load", onLoad);
    return () => window.removeEventListener("load", onLoad);
  }, []);
  return (
    <section className="student-content-section">
      <div className="student-content-header">
        <h1 className="student-content-title" data-aos="fade-up">
          Book Appointments in Seconds
        </h1>
        <p
          className="student-content-subtitle"
          data-aos="fade-up"
          data-aos-delay="150"
        >
          Managing your busy appointments is effortless. Easily schedule quick
          meetings with professors or faculty and gain the help you need when you
          need it.
        </p>
      </div>
      <div className="student-content-body">
        <div className="student-content-image-wrap" data-aos="fade-up">
          <img
            src="/students.png"
            alt="Student App"
            className="student-content-image"
          />
        </div>
        <div
          className="student-content-text"
          data-aos="fade-up"
          data-aos-delay="200"
        >
          <img
            src={calendarIcon}
            alt="Calendar"
            className="student-content-calendar-icon"
            style={{ width: 48, height: 48, marginBottom: "0.5rem", fontWeight: 600 }}
          />
          <h2
            className="student-content-feature-title"
            style={{ fontWeight: 700, color: "#000" }}
          >
            Manage Your Academics
          </h2>
          <p className="student-content-feature-desc">
            Easily manage and track all your appointments with professors. Get
            real-time notifications for meetings, deadlines, and important
            updates. Stay on top of your academic schedule with our intuitive
            interface.
          </p>
        </div>
      </div>
    </section>
  );
};

export default StudentContent;
