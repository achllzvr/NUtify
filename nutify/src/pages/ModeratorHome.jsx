// Moderator home page UI
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
import checkIcon from '../assets/icons/check.svg';
import CurrentQueue from '../components/CurrentQueue';
import FacultyList from '../components/FacultyList';

// Truncate long reason text
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
  const [requestAlertVisible, setRequestAlertVisible] = useState(false);
  const [requestAlertTransition, setRequestAlertTransition] = useState(false);
  const [facultyStatusFilter, setFacultyStatusFilter] = useState('all');

  // Faculty selection click
  const handleFacultyClick = (faculty) => {
    setSelectedFaculty(faculty);
    setShowScheduleModal(true);
  };

  // Schedule selection
  const handleScheduleSelect = (schedule) => {
    setSelectedSchedule(schedule);
  };

  // Schedule submit
  const handleScheduleSubmit = () => {
    if (selectedSchedule) {
      setShowScheduleModal(false);
      setShowSuccessModal(true);
    }
  };

  // Main search input
  const handleMainSearchInputChange = (value) => {
    setMainSearchInput(value);
  };

  // Main search click
  const handleSearch = () => {
    setMainSearch(mainSearchInput);
  };

  // View details for appointment
  const handleViewDetails = (appointment) => {
    setDetailsModalAppointment(appointment);
  };

  // Notify appointees button
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

  // Alert close
  const handleAlertClose = () => {
    setAlertTransition(false);
    setTimeout(() => setAlertVisible(false), 350);
  };

  // Dummy data for request dropdowns
  const facultyDropdownList = [
    { id: 1, name: 'Jayson Guia', avatar: jaysonGuia },
    { id: 2, name: 'Jei Pastrana', avatar: jeiPastranaAvatar },
    { id: 3, name: 'Irene Balmes', avatar: ireneBalmes },
    { id: 4, name: 'Carlo Torres', avatar: carloTorres },
    { id: 5, name: 'Archie Menisis', avatar: archieMenisis },
    { id: 6, name: 'Michael Joseph Aramil', avatar: michaelAramil },
    { id: 7, name: 'Erwin De Castro', avatar: erwinDeCastro },
    { id: 8, name: 'Joel Enriquez', avatar: joelEnriquez },
    { id: 9, name: 'Bernie Fabito', avatar: bernieFabito },
    { id: 10, name: 'Bobby Buendia', avatar: bobbyBuendia },
    { id: 11, name: 'Penny Lumbera', avatar: pennyLumbera }
  ];

  const studentDropdownList = [
    { name: 'Beatriz Solis', avatar: beatrizSolis },
    { name: 'John Clarenz Dimazana', avatar: johnClarenz },
    { name: 'Kriztopher Kier Estioco', avatar: kriztopher },
    { name: 'Niel Cerezo', avatar: nielCerezo }
  ];

  // Faculty search filter
  const filteredFaculty = facultyDropdownList.filter(f =>
    f.name.toLowerCase().includes(facultySearch.toLowerCase())
  );

  // Student search filter
  const filteredStudents = studentDropdownList.filter(s =>
    s.name.toLowerCase().includes(studentSearch.toLowerCase())
  );

  // Request scheduling handler
  const handleSchedule = () => {
    setFacultySelected('');
    setFacultySearch('');
    setStudentName('');
    setStudentSearch('');
    setReason('');
    const audio = new window.Audio('/nutified.wav');
    audio.play();
    setRequestAlertVisible(true);
    setTimeout(() => setRequestAlertTransition(true), 10);
    setTimeout(() => {
      setRequestAlertTransition(false);
      setTimeout(() => setRequestAlertVisible(false), 350);
    }, 2500);
  };

  // Request alert close
  const handleRequestAlertClose = () => {
    setRequestAlertTransition(false);
    setTimeout(() => setRequestAlertVisible(false), 350);
  };

  useEffect(() => {
    document.title = "Home - NUtify";
  }, []);

  useEffect(() => {
    if (detailsModalAppointment) {
      const handleEsc = (event) => {
        if (event.key === "Escape") {
          setDetailsModalAppointment(null);
        }
      };
      window.addEventListener("keydown", handleEsc);
      return () => window.removeEventListener("keydown", handleEsc);
    }
  }, [detailsModalAppointment]);

  return (
    <div>
      {/* Success alert for Notify Appointees */}
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

      {/* Green alert for Request */}
      {requestAlertVisible && (
        <div
          style={{
            position: 'fixed',
            top: '32px',
            left: '50%',
            transform: 'translateX(-50%)',
            minWidth: '320px',
            maxWidth: '90vw',
            background: '#D4F7DC',
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
            opacity: requestAlertTransition ? 1 : 0,
            transform: requestAlertTransition
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
            <img src={checkIcon} alt="Check" width="22" height="22" />
          </span>
          <span style={{ fontWeight: 600, marginRight: '2px' }}>Success:</span>
          <span style={{ marginRight: '8px' }}>Request Created!</span>
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
            onClick={handleRequestAlertClose}
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
        userRole="Moderator"
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
            {/* Current Queue Section */}
            <CurrentQueue
              mainSearch={mainSearch}
              onViewDetails={handleViewDetails}
              onNotifyAppointees={handleNotifyAppointees}
              truncateReason={truncateReason}
            />

            {/* Create On-the-spot Request Section */}
            <div className="moderator-home-appointment-section">
              <div className="moderator-home-section-header">
                <h2>Create On-the-spot Request</h2>
              </div>
              {/* Faculty selection */}
              <div style={{ fontWeight: 500, marginBottom: '6px' }}>Select Faculty</div>
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

              {/* Student selection */}
              <div style={{ fontWeight: 500, marginBottom: '6px' }}>Select Student</div>
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

              {/* Reason input */}
              <div style={{ fontWeight: 500, marginBottom: '6px' }}>Reason</div>
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
                className="Schedule-Button"
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
            {/* All Faculty List Section */}
            <FacultyList
              mainSearch={mainSearch}
              facultyStatusFilter={facultyStatusFilter}
              setFacultyStatusFilter={setFacultyStatusFilter}
            />
          </div>
        </div>
      </div>

      {/* Appointment details modal */}
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
              <div className="modal-footer" style={{ borderTop: 'none' }}></div>
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