import React, { useState, useEffect } from 'react';
import Sidebar from '../components/Sidebar';
import Header from '../components/Header';
import '../styles/dashboard.css';
import '../styles/moderatorhome.css'; // changed from studenthome.css

// Import avatar images
import johnDoeAvatar from '../assets/images/avatars/1c9a4dd0bbd964e3eecbd40caf3b7e37.jpg';
import jeiPastranaAvatar from '../assets/images/avatars/1c9a4dd0bbd964e3eecbd40caf3b7e37.jpg';
import ireneBalmes from '../assets/images/avatars/c33237da3438494d1abc67166196484e.jpg';
import jaysonGuia from '../assets/images/avatars/d447a9fd5010652f6c0911fbe9c662c6.jpg';
import carloTorres from '../assets/images/avatars/8940e8ea369def14e82f05a5fee994b9.jpg';
import archieMenisis from '../assets/images/avatars/78529e2ec8eb4a2eb2fb961e04915b0a.jpg';
import michaelAramil from '../assets/images/avatars/869f67a992bb6ca4cb657fb9fc634893.jpg';
import erwinDeCastro from '../assets/images/avatars/92770c61168481c94e1ba43df7615fd8.jpg';
import joelEnriquez from '../assets/images/avatars/944c5ba154e0489274504f38d01bcfaf.jpg';
import bernieFabito from '../assets/images/avatars/78529e2ec8eb4a2eb2fb961e04915b0a.jpg';

const ModeratorHome = () => {
  const [selectedFaculty, setSelectedFaculty] = useState(null);
  const [selectedSchedule, setSelectedSchedule] = useState(null);
  const [showScheduleModal, setShowScheduleModal] = useState(false);
  const [showSuccessModal, setShowSuccessModal] = useState(false);

  // Sample data
  const upcomingAppointments = [
    {
      id: 1,
      name: 'Jei Pastrana',
      department: 'Faculty - SACE',
      time: 'June 15 - 09:00 am',
      avatar: jeiPastranaAvatar
    },
    {
      id: 2,
      name: 'Irene Balmes',
      department: 'Faculty - SACE',
      time: 'June 14 - 09:00 am',
      avatar: ireneBalmes
    },
    {
      id: 3,
      name: 'Jei Pastrana',
      department: 'Faculty - SACE',
      time: 'June 15 - 09:00 am',
      avatar: jeiPastranaAvatar
    }
  ];

  const recentAppointments = [
    {
      id: 1,
      name: 'Appointment done - June 24, 2025 - 00:00',
      details: 'Jei Pastrana - Faculty - SACE',
      avatar: jeiPastranaAvatar
    },
    {
      id: 2,
      name: 'Appointment done - June 18, 2025 - 00:00',
      details: 'Irene Balmes - Faculty - SACE',
      avatar: ireneBalmes
    },
    {
      id: 3,
      name: 'Appointment done - June 13, 2025 - 00:00',
      details: 'Jei Pastrana - Faculty - SACE',
      avatar: jeiPastranaAvatar
    }
  ];

  const facultyList = [
    { id: 1, name: 'Jayson Guia', department: 'Faculty - SACE', status: 'online', avatar: jaysonGuia },
    { id: 2, name: 'Jei Pastrana', department: 'Faculty - SACE', status: 'offline', avatar: jeiPastranaAvatar },
    { id: 3, name: 'Irene Balmes', department: 'Faculty - SACE', status: 'online', avatar: ireneBalmes },
    { id: 4, name: 'Carlo Torres', department: 'Faculty - SACE', status: 'offline', avatar: carloTorres },
    { id: 5, name: 'Archie Menisis', department: 'Faculty - SACE', status: 'online', avatar: archieMenisis },
    { id: 6, name: 'Michael Joseph Aramil', department: 'Faculty - SACE', status: 'offline', avatar: michaelAramil },
    { id: 7, name: 'Erwin De Castro', department: 'Faculty - SACE', status: 'online', avatar: erwinDeCastro },
    { id: 8, name: 'Joel Enriquez', department: 'Faculty - SACE', status: 'offline', avatar: joelEnriquez },
    { id: 9, name: 'Bernie Fabito', department: 'Faculty - SACE', status: 'online', avatar: bernieFabito }
  ];

  const facultySchedules = {
    "Jayson Guia": [
      "Monday - 9:00 - 10:00",
      "Tuesday - 9:00 - 10:00",
      "Wednesday - 10:00 - 11:00",
      "Thursday - 1:00 - 2:00",
      "Friday - 9:00 - 10:00",
      "Friday - 2:00 - 3:00"
    ],
    "Jei Pastrana": [
      "Monday - 9:00 - 10:00",
      "Tuesday - 9:00 - 10:00",
      "Friday - 9:00 - 10:00"
    ],
    "Irene Balmes": [
      "Monday - 8:00 - 9:00",
      "Tuesday - 10:00 - 11:00",
      "Wednesday - 1:00 - 2:00",
      "Thursday - 3:00 - 4:00",
      "Friday - 11:00 - 12:00"
    ]
  };

  const handleFacultyClick = (faculty) => {
    setSelectedFaculty(faculty);
    setShowScheduleModal(true);
  };

  const handleScheduleSelect = (schedule) => {
    setSelectedSchedule(schedule);
  };

  const handleScheduleSubmit = () => {
    if (selectedSchedule) {
      setShowScheduleModal(false);
      setShowSuccessModal(true);
    }
  };

  const handleSearch = (searchTerm) => {
    console.log('Searching for:', searchTerm);
    // Implement search functionality
  };

  useEffect(() => {
    document.title = "Home - NUtify";
  }, []);

  return (
    <div>
      <Sidebar 
        userType="moderator"
        userName="John Doe"
        userRole="Moderator - SACE"
        userAvatar={johnDoeAvatar}
      />
      
      <Header 
        title="Hello, John Doe"
        subtitle="Manage your appointments and consultations in one place"
        searchPlaceholder="Search Faculty"
        onSearch={handleSearch}
      />

      <div className="moderator-home-main-content">
        <div className="moderator-home-content-container">
          <div className="moderator-home-left-column">
            {/* Upcoming Appointments */}
            <div className="moderator-home-appointment-section" id="moderator-home-upcomingAppointments">
              <div className="moderator-home-section-header">
                <h2>Your Upcoming Appointments</h2>
                <button className="moderator-home-see-more-btn">See More</button>
              </div>
              <div className="moderator-home-appointment-list">
                {upcomingAppointments.map(appointment => (
                  <div key={appointment.id} className="moderator-home-appointment-item">
                    <div className="moderator-home-appointment-avatar">
                      <img src={appointment.avatar} alt={appointment.name} className="moderator-home-avatar-img" />
                    </div>
                    <div className="moderator-home-appointment-info">
                      <div className="moderator-home-appointment-name">{appointment.name}</div>
                      <div className="moderator-home-appointment-details">{appointment.department}</div>
                      <div className="moderator-home-appointment-time">{appointment.time}</div>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Recent Sessions */}
            <div className="moderator-home-appointment-section">
              <div className="moderator-home-section-header">
                <h2>Your Most Recent</h2>
                <button className="moderator-home-see-more-btn">See More</button>
              </div>
              <div className="moderator-home-appointment-list">
                {recentAppointments.map(appointment => (
                  <div key={appointment.id} className="moderator-home-appointment-item">
                    <div className="moderator-home-appointment-avatar">
                      <img src={appointment.avatar} alt={appointment.name} className="moderator-home-avatar-img" />
                    </div>
                    <div className="moderator-home-appointment-info">
                      <div className="moderator-home-appointment-name">{appointment.name}</div>
                      <div className="moderator-home-appointment-details">{appointment.details}</div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Faculty List */}
          <div className="moderator-home-right-column">
            <div className="moderator-home-faculty-section">
              <div className="moderator-home-section-header">
                <h2>All Faculty List</h2>
              </div>
              <div className="moderator-home-faculty-list">
                {facultyList.map(faculty => (
                  // changed from student-home-faculty-item
                  <div
                    key={faculty.id}
                    className="moderator-home-faculty-item"
                    onClick={() => handleFacultyClick(faculty)}
                  >
                    <div className="moderator-home-faculty-avatar">
                      <img src={faculty.avatar} alt={faculty.name} className="moderator-home-avatar-img" />
                    </div>
                    <div className="moderator-home-faculty-info">
                      <div className="moderator-home-faculty-name">{faculty.name}</div>
                      <div className="moderator-home-faculty-department">{faculty.department}</div>
                    </div>
                    <div className={`moderator-home-faculty-status ${faculty.status}`}></div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Schedule Modal */}
      {showScheduleModal && (
        <div className="modal fade show" style={{ display: 'block' }}>
          <div className="modal-dialog modal-dialog-centered">
            <div className="modal-content">
              <div className="modal-header" style={{ borderBottom: 'none' }}>
                <h5 className="modal-title">
                  {selectedFaculty?.name}'s available times...
                </h5>
                <button
                  type="button"
                  className="btn-close"
                  onClick={() => setShowScheduleModal(false)}
                ></button>
              </div>
              <div className="modal-body" style={{ paddingBottom: 0 }}>
                <div className="moderator-home-schedule-times-container">
                  <div className="row g-3">
                    {(facultySchedules[selectedFaculty?.name] || []).map((time, index) => (
                      // changed from student-home-schedule-time-card
                      <div key={index} className="col-6">
                        <div
                          className={`moderator-home-schedule-time-card ${selectedSchedule === time ? 'selected' : ''}`}
                          onClick={() => handleScheduleSelect(time)}
                        >
                          {time}
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
              <div className="modal-footer" style={{ borderTop: 'none' }}>
                {/* changed from student-home-schedule-btn */}
                <button
                  type="button"
                  className="btn btn-primary moderator-home-schedule-btn"
                  style={{ width: '100%', borderRadius: '30px', fontSize: '18px' }}
                  disabled={!selectedSchedule}
                  onClick={handleScheduleSubmit}
                >
                  Schedule
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Success Modal */}
      {showSuccessModal && (
        <div className="modal fade show" style={{ display: 'block' }}>
          <div className="modal-dialog modal-dialog-centered">
            <div className="modal-content" style={{ borderRadius: '20px' }}>
              <div className="modal-body text-center" style={{ padding: '40px 30px 30px 30px' }}>
                <h4 style={{ fontWeight: 700, marginBottom: '18px' }}>
                  Requested Appointment Schedule!
                </h4>
                <div style={{ fontSize: '16px', marginBottom: '32px' }}>
                  Please check your History for the Confirmation of your scheduled appointment.
                </div>
                <button
                  type="button"
                  className="btn btn-primary w-100"
                  style={{ borderRadius: '30px', fontSize: '20px', padding: '12px 0' }}
                  onClick={() => setShowSuccessModal(false)}
                >
                  Go Back
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Modal backdrop */}
      {(showScheduleModal || showSuccessModal) && (
        <div className="modal-backdrop fade show"></div>
      )}
    </div>
  );
};

export default ModeratorHome;