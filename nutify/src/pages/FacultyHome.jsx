import React, { useState } from 'react';
import Sidebar from '../components/Sidebar';
import Header from '../components/Header';
import '../styles/dashboard.css';
import '../styles/facultyhome.css';

// Import avatar images
import facultyAvatar from '../assets/images/avatars/237d3876ef98d5364ed1326813f4ed5b.jpg';
import beatrizSolis from '../assets/images/avatars/1c9a4dd0bbd964e3eecbd40caf3b7e37.jpg';
import johnClarenz from '../assets/images/avatars/c33237da3438494d1abc67166196484e.jpg';
import kriztopher from '../assets/images/avatars/8940e8ea369def14e82f05a5fee994b9.jpg';
import nielCerezo from '../assets/images/avatars/237d3876ef98d5364ed1326813f4ed5b.jpg';

const FacultyHome = () => {
  const [showDetailsModal, setShowDetailsModal] = useState(false);
  const [selectedAppointment, setSelectedAppointment] = useState(null);

  // Sample data for upcoming student appointments
  const upcomingAppointments = [
    {
      id: 1,
      name: 'Beatriz Solis',
      department: 'Student - SACE',
      time: 'June 15 - 00:00 am',
      status: 'accepted',
      avatar: beatrizSolis
    },
    {
      id: 2,
      name: 'John Clarenz Dimazana',
      department: 'Student - SACE',
      time: 'June 16 - 10:00 am',
      status: 'accepted',
      avatar: johnClarenz
    },
    {
      id: 3,
      name: 'Kriztopher Kier Estioco',
      department: 'Student - SACE',
      time: 'June 18 - 02:00 pm',
      status: 'accepted',
      avatar: kriztopher
    },
    {
      id: 4,
      name: 'Niel Cerezo',
      department: 'Student - SACE',
      time: 'June 19 - 11:00 am',
      status: 'accepted',
      avatar: nielCerezo
    }
  ];

  const statusModalMap = {
    pending: {
      main: { text: "-", class: "pending" },
      secondary: [
        { text: "Accept Appointment?", class: "secondary pending-badge" },
        { text: "Pending - June 11; 6:00 pm", class: "secondary" }
      ]
    },
    accepted: {
      main: { text: "-", class: "pending" },
      secondary: [
        { text: "Accepted - June 13; 9:23 am", class: "accepted" },
        { text: "Pending - June 11; 6:00 pm", class: "secondary" }
      ]
    }
  };

  const handleSeeMore = (appointment) => {
    setSelectedAppointment(appointment);
    setShowDetailsModal(true);
  };

  const handleSearch = (searchTerm) => {
    console.log('Searching for:', searchTerm);
    // Implement search functionality
  };

  return (
    <div>
      <Sidebar 
        userType="faculty"
        userName="Not John Doe"
        userRole="Faculty - SACE"
        userAvatar={facultyAvatar}
      />
      
      <Header 
        title="Hello, Not John Doe"
        subtitle="Manage all your student appointments and consultations in one place"
        searchPlaceholder="Search Students"
        onSearch={handleSearch}
      />

      <div className="faculty-home-main-content">
        <div className="faculty-home-content-container">
          <div className="faculty-home-left-column">
            <div className="faculty-home-section" style={{ marginTop: '2.5em' }}>
              <div className="faculty-home-section-header">
                <h2>Upcoming Student Appointments</h2>
              </div>
              <div className="faculty-home-card-list faculty-home-appointment-list">
                {upcomingAppointments.map(appointment => (
                  <div
                    key={appointment.id}
                    className="faculty-home-appointment-item faculty-home-item"
                    data-status={appointment.status}
                  >
                    <div className="faculty-home-appointment-avatar">
                      <img
                        src={appointment.avatar}
                        alt={appointment.name}
                        className="faculty-home-avatar-img"
                      />
                    </div>
                    <div className="faculty-home-appointment-info">
                      <div className="faculty-home-appointment-name faculty-home-name">{appointment.name}</div>
                      <div className="faculty-home-appointment-details faculty-home-details">
                        {appointment.department}
                      </div>
                      <div className="faculty-home-appointment-time">{appointment.time}</div>
                      <button
                        className="faculty-home-see-more-btn"
                        onClick={() => handleSeeMore(appointment)}
                      >
                        See More
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* History Details Modal */}
      {showDetailsModal && selectedAppointment && (
        <div className="modal fade show" style={{ display: 'block' }}>
          <div className="modal-dialog modal-dialog-centered">
            <div className="modal-content faculty-home-details-modal-content">
              <div className="modal-header">
                <h5 className="modal-title">Appointment Status</h5>
                <button
                  type="button"
                  className="btn-close"
                  onClick={() => setShowDetailsModal(false)}
                ></button>
              </div>
              <div className="modal-body">
                <div className="faculty-home-details-modal-body">
                  <div className="faculty-home-details-modal-title">{selectedAppointment.name}</div>
                  <div className="faculty-home-details-modal-time">{selectedAppointment.time}</div>
                  
                  {statusModalMap[selectedAppointment.status] && (
                    <>
                      <div className={`faculty-home-details-modal-status ${statusModalMap[selectedAppointment.status].main.class}`}>
                        {statusModalMap[selectedAppointment.status].main.text}
                      </div>
                      {statusModalMap[selectedAppointment.status].secondary?.map((sec, index) => (
                        <div
                          key={index}
                          className={`faculty-home-details-modal-status ${sec.class} ${sec.text === "Accept Appointment?" ? "faculty-home-pending-badge" : ""}`}
                        >
                          {sec.text}
                        </div>
                      ))}
                    </>
                  )}
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Modal backdrop */}
      {showDetailsModal && (
        <div className="modal-backdrop fade show"></div>
      )}
    </div>
  );
};

export default FacultyHome;