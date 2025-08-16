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
import messageCircleIcon from '../assets/icons/message-circle.svg';
import calendarIcon from '../assets/icons/calendar.svg';
import folderIcon from '../assets/icons/folder.svg';
import archiveIcon from '../assets/icons/archive.svg';

const REASON_OPTIONS = ['Consultation', 'Meeting', 'Project', 'Other'];
function mapReason(reason) {
  if (!reason) return 'Other';
  const found = REASON_OPTIONS.find(opt => reason.trim().toLowerCase().startsWith(opt.toLowerCase()));
  return found || 'Other';
}
const getReasonText = (reason) =>
  mapReason(reason) === 'Other'
    ? 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam euismod, nunc ut laoreet.'
    : mapReason(reason);

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
  const [reasonType, setReasonType] = useState('Consultation');
  const [mainSearchInput, setMainSearchInput] = useState('');
  const [mainSearch, setMainSearch] = useState('');
  const [requestAlertVisible, setRequestAlertVisible] = useState(false);
  const [requestAlertTransition, setRequestAlertTransition] = useState(false);
  const [facultyStatusFilter, setFacultyStatusFilter] = useState('all');
  const [showRequestModal, setShowRequestModal] = useState(false);

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

  const filteredFaculty = facultyDropdownList.filter(f =>
    f.name.toLowerCase().includes(facultySearch.toLowerCase())
  );

  const filteredStudents = studentDropdownList.filter(s =>
    s.name.toLowerCase().includes(studentSearch.toLowerCase())
  );

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

  useEffect(() => {
    if (showRequestModal) {
      const handleEsc = (event) => {
        if (event.key === "Escape") {
          setShowRequestModal(false);
        }
      };
      window.addEventListener("keydown", handleEsc);
      return () => window.removeEventListener("keydown", handleEsc);
    }
  }, [showRequestModal]);

  const reasonOptions = [
    'Consultation',
    'Meeting',
    'Project',
    'Other'
  ];

  return (
    <div>
      {alertVisible && (
        <div
          style={{
            position: 'fixed',
            top: '32px',
            left: '50%',
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
            transform: `translateX(-50%) ${alertTransition ? 'translateY(0)' : 'translateY(-12px)'}`,
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

      {requestAlertVisible && (
        <div
          style={{
            position: 'fixed',
            top: '32px',
            left: '50%',
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
            transform: `translateX(-50%) ${requestAlertTransition ? 'translateY(0)' : 'translateY(-12px)'}`,
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
            <CurrentQueue
              mainSearch={mainSearch}
              onViewDetails={handleViewDetails}
              onNotifyAppointees={handleNotifyAppointees}
              truncateReason={truncateReason}
            />
          </div>

          <div className="moderator-home-right-column">
            <FacultyList
              mainSearch={mainSearch}
              facultyStatusFilter={facultyStatusFilter}
              setFacultyStatusFilter={setFacultyStatusFilter}
            />
          </div>
        </div>
      </div>

      {/* Fixed Button */}
      <button
        className="fixed-create-request-btn"
        onClick={() => setShowRequestModal(true)}
      >
        <span className="fixed-create-request-btn-plus">+</span>
        <span className="fixed-create-request-btn-text">Create Request</span>
      </button>

      {/* Modal for Create On-the-spot Request */}
      {showRequestModal && (
        <>
          <div className="modal fade show" style={{ display: 'block', zIndex: 3000 }}>
            <div className="modal-dialog modal-dialog-centered">
              <div className="modal-content" style={{ borderRadius: '20px', padding: '0' }}>
                <div className="modal-header" style={{ borderBottom: 'none', position: 'relative' }}>
                  <h5 className="modal-title" style={{ fontWeight: 700 }}>
                    Create On-the-spot Request
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
                    onClick={() => setShowRequestModal(false)}
                    aria-label="Close"
                    title="Close"
                  >
                    &#10005;
                  </span>
                </div>
                <div className="modal-body" style={{ padding: '0 25px 25px 25px' }}>
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

                  <div style={{ fontWeight: 500, marginBottom: '6px' }}>Reason</div>
                  <div style={{ marginBottom: '18px' }}>
                    <select
                      className="moderator-home-faculty-filter-dropdown"
                      value={reasonType}
                      onChange={e => {
                        setReasonType(e.target.value);
                        if (e.target.value !== 'Other') setReason('');
                      }}
                      style={{
                        borderRadius: '15px',
                        padding: '8px 18px',
                        fontSize: '15px',
                        fontFamily: '"Helvetica", Arial, sans-serif',
                        border: 'none',
                        background: '#f0f0f0',
                        boxShadow: '8px 8px 15px rgba(0, 0, 0, 0.09), -8px -8px 15px rgba(255, 255, 255, 0.8)',
                        outline: 'none',
                        minWidth: '120px',
                        width: '100%',
                        appearance: 'none',
                        backgroundImage:
                          "url(\"data:image/svg+xml;utf8,<svg fill='%237F8C8D' height='18' viewBox='0 0 24 24' width='18' xmlns='http://www.w3.org/2000/svg'><path d='M7 10l5 5 5-5z'/></svg>\")",
                        backgroundRepeat: 'no-repeat',
                        backgroundPosition: 'right 14px center',
                        backgroundSize: '18px 18px'
                      }}
                    >
                      {reasonOptions.map(opt => (
                        <option key={opt} value={opt}>{opt}</option>
                      ))}
                    </select>
                    {reasonType === 'Other' && (
                      <input
                        type="text"
                        className="login-input"
                        placeholder="Enter Reason"
                        value={reason}
                        onChange={e => setReason(e.target.value)}
                        style={{
                          borderRadius: '10px',
                          marginTop: '10px',
                          paddingLeft: '25px'
                        }}
                      />
                    )}
                  </div>
                  <button
                    className="Schedule-Button"
                    disabled={
                      !(
                        facultySelected &&
                        studentName &&
                        ((reasonType !== 'Other' && reasonType) || (reasonType === 'Other' && reason))
                      )
                    }
                    onClick={() => {
                      handleSchedule();
                      setShowRequestModal(false);
                    }}
                  >
                    Schedule
                  </button>
                </div>
              </div>
            </div>
          </div>
          <div className="modal-backdrop fade show" style={{ zIndex: 2999 }}></div>
        </>
      )}

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
                  <strong>Reason:</strong> {getReasonText(detailsModalAppointment.reason)}
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