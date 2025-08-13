import React, { useState, useEffect } from 'react';
import Sidebar from '../components/Sidebar';
import Header from '../components/Header';
import '../styles/dashboard.css';
import '../styles/moderatorhome.css';
import '../styles/moderatorhome-responsive.css';

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
import bellIcon from '../assets/icons/bell-solid-full.svg';
import searchIcon from '../assets/icons/search.svg';
import facultyAvatar from '../assets/images/avatars/237d3876ef98d5364ed1326813f4ed5b.jpg';
import beatrizSolis from '../assets/images/avatars/1c9a4dd0bbd964e3eecbd40caf3b7e37.jpg';
import johnClarenz from '../assets/images/avatars/c33237da3438494d1abc67166196484e.jpg';
import kriztopher from '../assets/images/avatars/8940e8ea369def14e82f05a5fee994b9.jpg';
import nielCerezo from '../assets/images/avatars/237d3876ef98d5364ed1326813f4ed5b.jpg';
import pennyLumbera from '../assets/images/avatars/237d3876ef98d5364ed1326813f4ed5b.jpg';
import bobbyBuendia from '../assets/images/avatars/237d3876ef98d5364ed1326813f4ed5b.jpg';

const truncateReason = (reason, maxLength = 40) => {
  if (!reason) return '';
  return reason.length > maxLength ? reason.slice(0, maxLength) + '...' : reason;
};

const ModeratorHome = () => {
  const [selectedFaculty, setSelectedFaculty] = useState(null);
  const [selectedSchedule, setSelectedSchedule] = useState(null);
  const [showScheduleModal, setShowScheduleModal] = useState(false);
  const [showSuccessModal, setShowSuccessModal] = useState(false);
  const [detailsModalAppointment, setDetailsModalAppointment] = useState(null);
  const [alertVisible, setAlertVisible] = useState(false);
  const [alertTransition, setAlertTransition] = useState(false);
  const [facultySearch, setFacultySearch] = useState('');
  const [facultySelected, setFacultySelected] = useState('');
  const [studentName, setStudentName] = useState('');
  const [studentSearch, setStudentSearch] = useState('');
  const [reason, setReason] = useState('');
  const [mainSearchInput, setMainSearchInput] = useState('');
  const [mainSearch, setMainSearch] = useState('');

  const facultyHistoryStudents = [
    { name: 'Beatriz Solis', avatar: beatrizSolis },
    { name: 'John Clarenz Dimazana', avatar: johnClarenz },
    { name: 'Kriztopher Kier Estioco', avatar: kriztopher },
    { name: 'Niel Cerezo', avatar: nielCerezo }
  ];

  const upcomingAppointments = [
    {
      id: 1,
      name: 'Jei Pastrana',
      studentName: 'Beatriz Solis',
      department: 'Faculty - SACE',
      time: 'June 15 • 09:00 - 10:00',
      avatar: jeiPastranaAvatar,
      reason: 'Consultation about thesis proposal and research direction.'
    },
    {
      id: 2,
      name: 'Irene Balmes',
      studentName: 'John Clarenz Dimazana',
      department: 'Faculty - SACE',
      time: 'June 14 • 09:00 - 10:00',
      avatar: ireneBalmes,
      reason: 'Grade inquiry for last semester.'
    },
    {
      id: 3,
      name: 'Jei Pastrana',
      studentName: 'Kriztopher Kier Estioco',
      department: 'Faculty - SACE',
      time: 'June 15 • 09:00 - 10:00',
      avatar: jeiPastranaAvatar,
      reason: 'Requesting recommendation letter for scholarship application.'
    },
    {
      id: 4,
      name: 'Carlo Torres',
      studentName: 'Niel Cerezo',
      department: 'Faculty - SACE',
      time: 'June 16 • 10:00 - 11:00',
      avatar: carloTorres,
      reason: 'Follow-up on project feedback.'
    },
    {
      id: 5,
      name: 'Archie Menisis',
      studentName: 'Ella Ramos',
      department: 'Faculty - SACE',
      time: 'June 17 • 11:00 - 12:00',
      avatar: archieMenisis,
      reason: 'Consultation regarding course requirements and deadlines.'
    },
    {
      id: 6,
      name: 'Michael Joseph Aramil',
      studentName: 'Francis Lee',
      department: 'Faculty - SACE',
      time: 'June 18 • 12:00 - 01:00',
      avatar: michaelAramil,
      reason: 'Request for extension on assignment submission.'
    },
    {
      id: 7,
      name: 'Erwin De Castro',
      studentName: 'Grace Uy',
      department: 'Faculty - SACE',
      time: 'June 19 • 01:00 - 02:00',
      avatar: erwinDeCastro,
      reason: 'Discussion about internship opportunities.'
    },
    {
      id: 8,
      name: 'Joel Enriquez',
      studentName: 'Henry Sy',
      department: 'Faculty - SACE',
      time: 'June 20 • 02:00 - 03:00',
      avatar: joelEnriquez,
      reason: 'Clarification on exam coverage.'
    },
    {
      id: 9,
      name: 'Bernie Fabito',
      studentName: 'Ivy Dela Cruz',
      department: 'Faculty - SACE',
      time: 'June 21 • 03:00 - 04:00',
      avatar: bernieFabito,
      reason: 'Request for additional consultation slot due to schedule conflict.'
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
    { id: 9, name: 'Bernie Fabito', department: 'Faculty - SACE', status: 'online', avatar: bernieFabito },
    { id: 10, name: 'Bobby Buendia', department: 'Faculty - SAHS', status: 'online', avatar: bobbyBuendia },
    { id: 11, name: 'Penny Lumbera', department: 'Faculty - SAHS', status: 'offline', avatar: pennyLumbera }
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

  const handleMainSearchInputChange = (value) => {
    setMainSearchInput(value);
  };

  const handleSearch = () => {
    setMainSearch(mainSearchInput);
  };

  const handleViewDetails = (appointment) => {
    setDetailsModalAppointment(appointment);
  };

  const handleNotifyAppointees = (appointment) => {

    const audio = new window.Audio('/nutified.wav');
    audio.play();

    setAlertVisible(true);
    setTimeout(() => setAlertTransition(true), 10);
    setTimeout(() => {
      setAlertTransition(false);
      setTimeout(() => setAlertVisible(false), 350);
    }, 2500);
  };

  const handleAlertClose = () => {
    setAlertTransition(false);
    setTimeout(() => setAlertVisible(false), 350);
  };

  // Filter faculty list for search (on-the-spot request)
  const filteredFaculty = facultyList.filter(f =>
    f.name.toLowerCase().includes(facultySearch.toLowerCase())
  );

  // Filter students for search (on-the-spot request)
  const filteredStudents = facultyHistoryStudents.filter(s =>
    s.name.toLowerCase().includes(studentSearch.toLowerCase())
  );

  // Filter queue and faculty for main search bar
  const filteredQueue = upcomingAppointments.filter(a =>
    a.name.toLowerCase().includes(mainSearch.toLowerCase()) ||
    a.studentName.toLowerCase().includes(mainSearch.toLowerCase()) ||
    a.department.toLowerCase().includes(mainSearch.toLowerCase())
  );
  const filteredFacultyList = facultyList.filter(f =>
    f.name.toLowerCase().includes(mainSearch.toLowerCase()) ||
    f.department.toLowerCase().includes(mainSearch.toLowerCase())
  );

  // Handler for scheduling (dummy)
  const handleSchedule = () => {
    // Implement scheduling logic here
    setFacultySelected('');
    setFacultySearch('');
    setStudentName('');
    setReason('');
  };

  useEffect(() => {
    document.title = "Home - NUtify";
  }, []);

  return (
    <div>
      {alertVisible && (
        <div
          style={{
            position: 'fixed',
            top: '32px',
            left: '50%',
            transform: 'translateX(-50%)',
            minWidth: '320px',
            maxWidth: '90vw',
            background: '#F7E57F',
            color: '#1c1d1e',
            borderRadius: '8px',
            boxShadow: '0 2px 8px rgba(0,0,0,0.12)',
            padding: '10px 18px',
            display: 'flex',
            alignItems: 'center',
            gap: '10px',
            zIndex: 3000,
            fontFamily: 'Helvetica, Arial, sans-serif',
            fontSize: '15px',
            fontWeight: 500,
            opacity: alertTransition ? 1 : 0,
            transform: alertTransition
              ? 'translateX(-50%) translateY(0)'
              : 'translateX(-50%) translateY(-12px)',
            transition: 'opacity 0.35s, transform 0.35s'
          }}
        >
          <span style={{
            display: 'flex',
            alignItems: 'center',
            marginRight: '2px' 
          }}>
            <img src={bellIcon} alt="Bell" width="22" height="22" />
          </span>
          <span style={{ fontWeight: 600, marginRight: '2px' }}>Success:</span>
          <span style={{ marginRight: '8px' }}>Appointee NUtified!</span>
          <span
            style={{
              marginLeft: 'auto',
              cursor: 'pointer',
              fontSize: '18px',
              color: '#1c1d1e',
              fontWeight: 700,
              lineHeight: '1',
              paddingLeft: '8px'
            }}
            onClick={handleAlertClose}
            aria-label="Close"
            title="Close"
          >
            &#10005;
          </span>
        </div>
      )}

      <Sidebar 
        userType="moderator"
        userName="John Doe"
        userRole="Moderator - SACE"
        userAvatar={johnDoeAvatar}
      />
      
      <Header 
        title="Hello, John Doe"
        subtitle="Manage your appointments and consultations in one place"
        searchPlaceholder="Search Faculty or Queue"
        searchValue={mainSearchInput}
        onSearchChange={handleMainSearchInputChange}
        onSearch={handleSearch}
      />

      <div className="moderator-home-main-content">
        <div className="moderator-home-content-container">
          <div className="moderator-home-left-column">
            <div className="moderator-home-appointment-section" id="moderator-home-upcomingAppointments">
              <div className="moderator-home-section-header">
                <h2>Current Queue</h2>
              </div>
              <div className="moderator-home-queue-list">
                {filteredQueue.map(appointment => (
                  <div key={appointment.id} className="moderator-home-appointment-item">
                    <div className="moderator-home-appointment-avatar">
                      <img src={appointment.avatar} alt={appointment.name} className="moderator-home-avatar-img" />
                    </div>
                    <div className="moderator-home-appointment-info" style={{ flex: 1 }}>
                      <div className="moderator-home-appointment-name">{appointment.name}</div>
                      <div className="moderator-home-appointment-details">
                        Student: {appointment.studentName}
                      </div>
                      <div className="moderator-home-appointment-time">
                        {appointment.time}
                      </div>
                      <div className="moderator-home-appointment-details" style={{ marginTop: '2px', marginBottom: '8px' }}>
                        Reason: {truncateReason(appointment.reason)}
                      </div>
                      <div style={{ display: 'flex', gap: '10px', marginTop: '6px' }}>
                        <button
                          className="moderator-home-see-more-btn small-btn-text"
                          onClick={() => handleViewDetails(appointment)}
                        >
                          View Details
                        </button>
                        <button
                          className="moderator-home-notify-btn small-btn-text"
                          onClick={() => handleNotifyAppointees(appointment)}
                        >
                          Notify Appointees
                        </button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            <div className="moderator-home-appointment-section">
              <div className="moderator-home-section-header">
                <h2>Create On-the-spot Request</h2>
              </div>
              {/* Select Faculty label */}
              <div style={{ fontWeight: 500, marginBottom: '6px' }}>Select Faculty</div>
              {/* Faculty search typebox */}
              <div className="input-group" style={{ marginBottom: '18px', position: 'relative' }}>
                <img src={searchIcon} alt="Search" className="input-icon" style={{ left: 18, width: 22, height: 22 }} />
                <input
                  type="text"
                  className="login-input"
                  placeholder="Search Faculty"
                  value={facultySearch}
                  onChange={e => {
                    setFacultySearch(e.target.value);
                    setFacultySelected('');
                  }}
                  style={{ paddingLeft: '55px', borderRadius: '15px' }}
                />
                {/* Faculty dropdown results */}
                {facultySearch && !facultySelected && (
                  <div style={{
                    position: 'absolute',
                    top: '110%',
                    left: 0,
                    right: 0,
                    background: '#fff',
                    borderRadius: '10px',
                    boxShadow: '0 2px 8px rgba(0,0,0,0.09)',
                    zIndex: 10,
                    maxHeight: '180px',
                    overflowY: 'auto'
                  }}>
                    {filteredFaculty.length === 0 && (
                      <div style={{ padding: '10px 18px', color: '#888' }}>No faculty found</div>
                    )}
                    {filteredFaculty.map(f => (
                      <div
                        key={f.id}
                        style={{
                          padding: '10px 18px',
                          cursor: 'pointer',
                          display: 'flex',
                          alignItems: 'center',
                          gap: '10px'
                        }}
                        onClick={() => {
                          setFacultySelected(f.name);
                          setFacultySearch(f.name);
                        }}
                      >
                        <img src={f.avatar} alt={f.name} style={{ width: 28, height: 28, borderRadius: '50%' }} />
                        <span>{f.name}</span>
                      </div>
                    ))}
                  </div>
                )}
              </div>
              {/* Selected faculty */}
              {facultySelected && (
                <div style={{ marginBottom: '18px', color: '#323d87', fontWeight: 500 }}>
                  Selected: {facultySelected}
                </div>
              )}

              {/* Select Student label */}
              <div style={{ fontWeight: 500, marginBottom: '6px' }}>Select Student</div>
              {/* Student search typebox with popup */}
              <div className="input-group" style={{ marginBottom: '18px', position: 'relative' }}>
                <img src={searchIcon} alt="Search" className="input-icon" style={{ left: 18, width: 22, height: 22 }} />
                <input
                  type="text"
                  className="login-input"
                  placeholder="Search Student"
                  value={studentSearch}
                  onChange={e => {
                    setStudentSearch(e.target.value);
                    setStudentName('');
                  }}
                  style={{ paddingLeft: '55px', borderRadius: '15px' }}
                />
                {/* Student dropdown results */}
                {studentSearch && !studentName && (
                  <div style={{
                    position: 'absolute',
                    top: '110%',
                    left: 0,
                    right: 0,
                    background: '#fff',
                    borderRadius: '10px',
                    boxShadow: '0 2px 8px rgba(0,0,0,0.09)',
                    zIndex: 10,
                    maxHeight: '180px',
                    overflowY: 'auto'
                  }}>
                    {filteredStudents.length === 0 && (
                      <div style={{ padding: '10px 18px', color: '#888' }}>No student found</div>
                    )}
                    {filteredStudents.map(s => (
                      <div
                        key={s.name}
                        style={{
                          padding: '10px 18px',
                          cursor: 'pointer',
                          display: 'flex',
                          alignItems: 'center',
                          gap: '10px'
                        }}
                        onClick={() => {
                          setStudentName(s.name);
                          setStudentSearch(s.name);
                        }}
                      >
                        <img src={s.avatar} alt={s.name} style={{ width: 28, height: 28, borderRadius: '50%' }} />
                        <span>{s.name}</span>
                      </div>
                    ))}
                  </div>
                )}
              </div>
              {/* Selected student */}
              {studentName && (
                <div style={{ marginBottom: '18px', color: '#323d87', fontWeight: 500 }}>
                  Selected: {studentName}
                </div>
              )}

              {/* Reason label */}
              <div style={{ fontWeight: 500, marginBottom: '6px' }}>Reason</div>
              {/* Reason typebox with border radius 10 */}
              <div style={{ marginBottom: '18px' }}>
                <input
                  type="text"
                  className="login-input"
                  placeholder="Enter Reason"
                  value={reason}
                  onChange={e => setReason(e.target.value)}
                  style={{
                    borderRadius: '10px',
                    marginBottom: 0,
                    paddingLeft: '25px'
                  }}
                />
              </div>

              {/* Schedule button */}
              <button
                className="login-button"
                style={{
                  background: (facultySelected && studentName && reason) ? undefined : '#d3d3d3',
                  color: (facultySelected && studentName && reason) ? '#fff' : '#888',
                  cursor: (facultySelected && studentName && reason) ? 'pointer' : 'not-allowed'
                }}
                disabled={!(facultySelected && studentName && reason)}
                onClick={handleSchedule}
              >
                Schedule
              </button>
            </div>
          </div>

          <div className="moderator-home-right-column">
            <div className="moderator-home-faculty-section">
              <div className="moderator-home-section-header">
                <h2>All Faculty List</h2>
              </div>
              <div className="moderator-home-faculty-list">
                {filteredFacultyList.map(faculty => (
                  <div
                    key={faculty.id}
                    className="moderator-home-faculty-item"
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

      {detailsModalAppointment && (
        <div className="modal fade show" style={{ display: 'block' }}>
          <div className="modal-dialog modal-dialog-centered">
            <div className="modal-content" style={{ borderRadius: '20px' }}>
              <div className="modal-header" style={{ borderBottom: 'none', position: 'relative' }}>
                <h5 className="modal-title" style={{ fontWeight: 700 }}>
                  {detailsModalAppointment.name}
                </h5>
                <span
                  style={{
                    position: 'absolute',
                    right: '18px',
                    top: '18px',
                    fontSize: '22px',
                    cursor: 'pointer',
                    color: '#888'
                  }}
                  onClick={() => setDetailsModalAppointment(null)}
                  aria-label="Close"
                  title="Close"
                >
                  &#10005;
                </span>
              </div>
              <div className="modal-body" style={{ paddingBottom: 0 }}>
                <div style={{ fontSize: '16px', marginBottom: '10px' }}>
                  <strong>Student:</strong> {detailsModalAppointment.studentName}
                </div>
                <div style={{ fontSize: '16px', marginBottom: '10px' }}>
                  <strong>Date:</strong> {detailsModalAppointment.time.split('•')[0].trim()} 2025
                </div>
                <div style={{ fontSize: '16px', marginBottom: '10px' }}>
                  <strong>Time:</strong> {detailsModalAppointment.time.split('•')[1]?.trim()}
                </div>
                <div style={{ fontSize: '16px', marginBottom: '10px' }}>
                  <strong>Reason:</strong> {detailsModalAppointment.reason}
                </div>
              </div>
              <div className="modal-footer" style={{ borderTop: 'none' }}>
              </div>
            </div>
          </div>
        </div>
      )}

      {detailsModalAppointment && (
        <div className="modal-backdrop fade show"></div>
      )}
    </div>
  );
};

export default ModeratorHome;