import React, { useState } from 'react';
import Sidebar from '../../components/Sidebar';
import Header from '../../components/Header';
import '../styles/dashboard.css';
import '../styles/studenthome.css';

// No avatar imports needed

const StudentHome = () => {
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
      avatar: null
    },
    {
      id: 2,
      name: 'Irene Balmes',
      department: 'Faculty - SACE',
      time: 'June 14 - 09:00 am',
      avatar: null
    },
    {
      id: 3,
      name: 'Jei Pastrana',
      department: 'Faculty - SACE',
      time: 'June 15 - 09:00 am',
      avatar: null
    }
  ];

  const recentAppointments = [
    {
      id: 1,
      name: 'Appointment done - June 24, 2025 - 00:00',
      details: 'Jei Pastrana - Faculty - SACE',
      avatar: null
    },
    {
      id: 2,
      name: 'Appointment done - June 18, 2025 - 00:00',
      details: 'Irene Balmes - Faculty - SACE',
      avatar: null
    },
    {
      id: 3,
      name: 'Appointment done - June 13, 2025 - 00:00',
      details: 'Jei Pastrana - Faculty - SACE',
      avatar: null
    }
  ];

  const facultyList = [
    { id: 1, name: 'Jayson Guia', department: 'Faculty - SACE', status: 'online', avatar: null },
    { id: 2, name: 'Jei Pastrana', department: 'Faculty - SACE', status: 'offline', avatar: null },
    { id: 3, name: 'Irene Balmes', department: 'Faculty - SACE', status: 'online', avatar: null },
    { id: 4, name: 'Carlo Torres', department: 'Faculty - SACE', status: 'offline', avatar: null },
    { id: 5, name: 'Archie Menisis', department: 'Faculty - SACE', status: 'online', avatar: null },
    { id: 6, name: 'Michael Joseph Aramil', department: 'Faculty - SACE', status: 'offline', avatar: null },
    { id: 7, name: 'Erwin De Castro', department: 'Faculty - SACE', status: 'online', avatar: null },
    { id: 8, name: 'Joel Enriquez', department: 'Faculty - SACE', status: 'offline', avatar: null },
    { id: 9, name: 'Bernie Fabito', department: 'Faculty - SACE', status: 'online', avatar: null }
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

  return (
    <div>
      <Sidebar
        userType="student"
        userName="John Doe"
        userRole="Student - SACE"
        userAvatar={null}
      />
      
      <Header 
        title="Hello, John Doe"
        subtitle="Manage your appointments and consultations in one place"
        searchPlaceholder="Search Faculty"
        onSearch={handleSearch}
      />

      <div className="student-home-main-content">
        <div className="student-home-content-container">
          <div className="student-home-left-column">
            {/* Upcoming Appointments */}
            <div className="student-home-appointment-section" id="student-home-upcomingAppointments">
              <div className="student-home-section-header">
                <h2>Your Upcoming Appointments</h2>
                <button className="student-home-see-more-btn">See More</button>
              </div>
              <div className="student-home-appointment-list">
                {upcomingAppointments.map(appointment => (
                  <div key={appointment.id} className="student-home-appointment-item">
                    <div className="student-home-appointment-avatar">
                      <div
                        className="student-home-avatar-img"
                        style={{
                          width: '40px',
                          height: '40px',
                          borderRadius: '50%',
                          backgroundColor: '#e0e0e0',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          fontSize: '16px',
                          fontWeight: 'bold',
                          color: '#666'
                        }}
                      >
                        {appointment.name.split(' ').map(n => n[0]).join('').substring(0, 2)}
                      </div>
                    </div>
                    <div className="student-home-appointment-info">
                      <div className="student-home-appointment-name">{appointment.name}</div>
                      <div className="student-home-appointment-details">{appointment.department}</div>
                      <div className="student-home-appointment-time">{appointment.time}</div>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Recent Sessions */}
            <div className="student-home-appointment-section">
              <div className="student-home-section-header">
                <h2>Your Most Recent</h2>
                <button className="student-home-see-more-btn">See More</button>
              </div>
              <div className="student-home-appointment-list">
                {recentAppointments.map(appointment => (
                  <div key={appointment.id} className="student-home-appointment-item">
                    <div className="student-home-appointment-avatar">
                      <div
                        className="student-home-avatar-img"
                        style={{
                          width: '40px',
                          height: '40px',
                          borderRadius: '50%',
                          backgroundColor: '#e0e0e0',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          fontSize: '16px',
                          fontWeight: 'bold',
                          color: '#666'
                        }}
                      >
                        {appointment.details.split(' - ')[0].split(' ').map(n => n[0]).join('').substring(0, 2)}
                      </div>
                    </div>
                    <div className="student-home-appointment-info">
                      <div className="student-home-appointment-name">{appointment.name}</div>
                      <div className="student-home-appointment-details">{appointment.details}</div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Faculty List */}
          <div className="student-home-right-column">
            <div className="student-home-faculty-section">
              <div className="student-home-section-header">
                <h2>All Faculty List</h2>
              </div>
              <div className="student-home-faculty-list">
                {facultyList.map(faculty => (
                  <div
                    key={faculty.id}
                    className="student-home-faculty-item"
                    onClick={() => handleFacultyClick(faculty)}
                  >
                    <div className="student-home-faculty-avatar">
                      <div
                        className="student-home-avatar-img"
                        style={{
                          width: '40px',
                          height: '40px',
                          borderRadius: '50%',
                          backgroundColor: '#e0e0e0',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          fontSize: '16px',
                          fontWeight: 'bold',
                          color: '#666'
                        }}
                      >
                        {faculty.name.split(' ').map(n => n[0]).join('').substring(0, 2)}
                      </div>
                    </div>
                    <div className="student-home-faculty-info">
                      <div className="student-home-faculty-name">{faculty.name}</div>
                      <div className="student-home-faculty-department">{faculty.department}</div>
                    </div>
                    <div className={`student-home-faculty-status ${faculty.status}`}></div>
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
                <div className="student-home-schedule-times-container">
                  <div className="row g-3">
                    {(facultySchedules[selectedFaculty?.name] || []).map((time, index) => (
                      <div key={index} className="col-6">
                        <div
                          className={`student-home-schedule-time-card ${selectedSchedule === time ? 'selected' : ''}`}
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
                <button
                  type="button"
                  className="btn btn-primary student-home-schedule-btn"
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

export default StudentHome;