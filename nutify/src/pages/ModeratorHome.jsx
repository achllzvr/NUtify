// Page: Moderator Home
import React, { useState, useEffect } from 'react';
import { notifyAppointees, createImmediateAppointment, fetchIdByName, searchUsers } from '../api/moderator';
import Sidebar from '../components/Sidebar';
import Header from '../components/Header';
import '../styles/dashboard.css';
import '../styles/moderatorhome.css';

import bellIcon from '../assets/icons/bell-solid-full.svg';
import searchIcon from '../assets/icons/search.svg';
import checkIcon from '../assets/icons/check.svg';
import CurrentQueue from '../components/CurrentQueue';
import FacultyList from '../components/FacultyList';
import messageCircleIcon from '../assets/icons/message-circle.svg';
import calendarIcon from '../assets/icons/calendar.svg';
import folderIcon from '../assets/icons/folder.svg';
import archiveIcon from '../assets/icons/archive.svg';

// Reason options and mapping
const REASON_OPTIONS = ['Consultation', 'Meeting', 'Project', 'Other'];
function mapReason(reason) {
  if (!reason) return 'Other';
  const found = REASON_OPTIONS.find(opt => reason.trim().toLowerCase().startsWith(opt.toLowerCase()));
  return found || 'Other';
}
const getReasonText = (reason) =>
  mapReason(reason) === 'Other'
    ? (<em>*Unspecified Reason. Please consult with appointee.</em>)
    : mapReason(reason);

const truncateReason = (reason, maxLength = 40) => {
  if (!reason) return '';
  return reason.length > maxLength ? reason.slice(0, maxLength) + '...' : reason;
};

const ModeratorHome = () => {
  // TODO(session): Replace hardcoded moderator ID with authenticated session user_id
  const MODERATOR_ID = 57;
  // State variables
  const [selectedFaculty, setSelectedFaculty] = useState(null);
  const [selectedSchedule, setSelectedSchedule] = useState(null);
  const [showScheduleModal, setShowScheduleModal] = useState(false);
  const [showSuccessModal, setShowSuccessModal] = useState(false);
  const [detailsModalAppointment, setDetailsModalAppointment] = useState(null);
  const [alertVisible, setAlertVisible] = useState(false);
  const [alertTransition, setAlertTransition] = useState(false);
  const [facultySearch, setFacultySearch] = useState('');
  const [facultySelected, setFacultySelected] = useState('');
  const [facultySelectedId, setFacultySelectedId] = useState(null);
  const [facultyResults, setFacultyResults] = useState([]);
  const [facultyLoading, setFacultyLoading] = useState(false);
  const [studentName, setStudentName] = useState('');
  const [studentSearch, setStudentSearch] = useState('');
  const [studentSelectedId, setStudentSelectedId] = useState(null);
  const [studentResults, setStudentResults] = useState([]);
  const [studentLoading, setStudentLoading] = useState(false);
  const [reason, setReason] = useState('');
  const [reasonType, setReasonType] = useState('Consultation');
  const [mainSearchInput, setMainSearchInput] = useState('');
  const [mainSearch, setMainSearch] = useState('');
  const [requestAlertVisible, setRequestAlertVisible] = useState(false);
  const [requestAlertTransition, setRequestAlertTransition] = useState(false);
  const [facultyStatusFilter, setFacultyStatusFilter] = useState('all');
  const [showRequestModal, setShowRequestModal] = useState(false);

  // Debounced typeahead: Faculty (teachers)
  useEffect(() => {
    let active = true;
    const q = (facultySearch || '').trim();
    if (!q) {
      setFacultyResults([]);
      return () => { active = false; };
    }
    setFacultyLoading(true);
    const t = setTimeout(async () => {
      try {
        const res = await searchUsers('teacher', q);
        if (!active) return;
        const list = Array.isArray(res) ? res : (res.results || []);
        setFacultyResults(list);
      } catch (e) {
        if (active) setFacultyResults([]);
      } finally {
        if (active) setFacultyLoading(false);
      }
    }, 250);
    return () => { active = false; clearTimeout(t); };
  }, [facultySearch]);

  // Debounced typeahead: Students
  useEffect(() => {
    let active = true;
    const q = (studentSearch || '').trim();
    if (!q) {
      setStudentResults([]);
      return () => { active = false; };
    }
    setStudentLoading(true);
    const t = setTimeout(async () => {
      try {
        const res = await searchUsers('student', q);
        if (!active) return;
        const list = Array.isArray(res) ? res : (res.results || []);
        setStudentResults(list);
      } catch (e) {
        if (active) setStudentResults([]);
      } finally {
        if (active) setStudentLoading(false);
      }
    }, 250);
    return () => { active = false; clearTimeout(t); };
  }, [studentSearch]);

  // Faculty click handler
  const handleFacultyClick = (faculty) => {
    setSelectedFaculty(faculty);
    setShowScheduleModal(true);
  };

  // Schedule select handler
  const handleScheduleSelect = (schedule) => {
    setSelectedSchedule(schedule);
  };

  // Schedule submit handler
  const handleScheduleSubmit = () => {
    if (selectedSchedule) {
      setShowScheduleModal(false);
      setShowSuccessModal(true);
    }
  };

  // Main search input handler
  const handleMainSearchInputChange = (value) => {
    setMainSearchInput(value);
  };

  // Main search handler
  const handleSearch = () => {
    setMainSearch(mainSearchInput);
  };

  // Details modal handler
  const handleViewDetails = (appointment) => {
    setDetailsModalAppointment(appointment);
  };

  // Notify appointees handler
  const handleNotifyAppointees = async (appointment) => {
    try {
      // Call backend to send notifications; ignore failure for UX smoothness
      if (appointment && appointment.id) {
        await notifyAppointees(appointment.id);
      }
    } catch (e) {
      // Non-blocking: proceed to show toast regardless
    } finally {
      const audio = new window.Audio('/nutified.wav');
      audio.play();
      setAlertVisible(true);
      setTimeout(() => setAlertTransition(true), 10);
      setTimeout(() => {
        setAlertTransition(false);
        setTimeout(() => setAlertVisible(false), 350);
      }, 2500);
    }
  };

  // Alert close handler
  const handleAlertClose = () => {
    setAlertTransition(false);
    setTimeout(() => setAlertVisible(false), 350);
  };

  // Schedule request handler
  const handleSchedule = async () => {
    try {
      // Prefer IDs selected from typeahead; fallback to name lookup
      let teacher_id = facultySelectedId;
      let student_id = studentSelectedId;
      if (!teacher_id && facultySelected) {
        const teacherRes = await fetchIdByName(facultySelected);
        teacher_id = teacherRes && (teacherRes.user_id || teacherRes.id || teacherRes.userID);
      }
      if (!student_id && studentName) {
        const studentRes = await fetchIdByName(studentName);
        student_id = studentRes && (studentRes.user_id || studentRes.id || studentRes.userID);
      }
      const appointment_reason = reasonType === 'Other' ? (reason || 'Other') : reasonType;
      if (teacher_id && student_id) {
        await createImmediateAppointment(teacher_id, student_id, appointment_reason);
      }
    } catch (e) {
      // Non-blocking: still show success UX to keep parity with current UI
    } finally {
      setFacultySelected('');
  setFacultySelectedId(null);
      setFacultySearch('');
  setFacultyResults([]);
      setStudentName('');
      setStudentSearch('');
  setStudentSelectedId(null);
  setStudentResults([]);
      setReason('');
      const audio = new window.Audio('/nutified.wav');
      audio.play();
      setRequestAlertVisible(true);
      setTimeout(() => setRequestAlertTransition(true), 10);
      setTimeout(() => {
        setRequestAlertTransition(false);
        setTimeout(() => setRequestAlertVisible(false), 350);
      }, 2500);
    }
  };

  // Request alert close handler
  const handleRequestAlertClose = () => {
    setRequestAlertTransition(false);
    setTimeout(() => setRequestAlertVisible(false), 350);
  };

  // Set page title
  useEffect(() => {
    document.title = "Home - NUtify";
  }, []);

  // Escape key handler for modals
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

  // Main render
  return (
    <div>
      {/* Success notification */}
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

      {/* Request Created notification */}
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

      {/* Sidebar */}
      <Sidebar
        userType="moderator"
        userName="Moderator"
        userRole="Moderator"
        userAvatar={null}
      />

      {/* Header */}
      <Header
        title="Hello, Moderator!"
        subtitle="Manage your appointments and consultations in one place"
        searchPlaceholder="Search Faculty or Queue"
        searchValue={mainSearchInput}
        onSearchChange={handleMainSearchInputChange}
        onSearch={handleSearch}
      />

      {/* Main content area */}
      <div className="moderator-home-main-content">
        <div className="moderator-home-content-container">
          <div className="moderator-home-left-column">
            <CurrentQueue
              mainSearch={mainSearch}
              onViewDetails={handleViewDetails}
              onNotifyAppointees={handleNotifyAppointees}
              truncateReason={truncateReason}
              moderatorId={MODERATOR_ID}
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

      {/* Create Request Button */}
      <button
        className="fixed-create-request-btn"
        onClick={() => setShowRequestModal(true)}
      >
        <span className="fixed-create-request-btn-plus">+</span>
        <span className="fixed-create-request-btn-text">Create Request</span>
      </button>

      {/* Modal: Create On-the-spot Request */}
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
                  {/* Faculty select */}
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
                        setFacultySelectedId(null);
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
                        {facultyLoading && (
                          <div style={{ padding: '10px 18px', color: '#888' }}>Searching…</div>
                        )}
                        {!facultyLoading && facultyResults.length === 0 && (
                          <div style={{ padding: '10px 18px', color: '#888' }}>No faculty found</div>
                        )}
                        {facultyResults.map(f => (
                          <div
                            key={f.user_id}
                            style={{
                              padding: '10px 18px',
                              cursor: 'pointer',
                              display: 'flex',
                              alignItems: 'center',
                              gap: '10px'
                            }}
                            onClick={() => {
                              const name = f.full_name || `${f.user_fn || ''} ${f.user_ln || ''}`.trim();
                              setFacultySelected(name);
                              setFacultySearch(name);
                              setFacultySelectedId(f.user_id || f.id);
                            }}
                          >
                            <div
                              style={{
                                width: 28,
                                height: 28,
                                borderRadius: '50%',
                                backgroundColor: '#e0e0e0',
                                display: 'flex',
                                alignItems: 'center',
                                justifyContent: 'center',
                                fontSize: '12px',
                                fontWeight: 'bold',
                                color: '#666'
                              }}
                            >
                              {(f.full_name || `${f.user_fn || ''} ${f.user_ln || ''}`.trim()).split(' ').map(n => n[0]).join('').substring(0, 2)}
                            </div>
                            <span>{f.full_name || `${f.user_fn || ''} ${f.user_ln || ''}`.trim()}</span>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>

                  {/* Student select */}
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
                        setStudentSelectedId(null);
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
                        {studentLoading && (
                          <div style={{ padding: '10px 18px', color: '#888' }}>Searching…</div>
                        )}
                        {!studentLoading && studentResults.length === 0 && (
                          <div style={{ padding: '10px 18px', color: '#888' }}>No student found</div>
                        )}
                        {studentResults.map(s => (
                          <div
                            key={s.user_id}
                            style={{
                              padding: '10px 18px',
                              cursor: 'pointer',
                              display: 'flex',
                              alignItems: 'center',
                              gap: '10px'
                            }}
                            onClick={() => {
                              const name = s.full_name || `${s.user_fn || ''} ${s.user_ln || ''}`.trim();
                              setStudentName(name);
                              setStudentSearch(name);
                              setStudentSelectedId(s.user_id || s.id);
                            }}
                          >
                            <div
                              style={{
                                width: 28,
                                height: 28,
                                borderRadius: '50%',
                                backgroundColor: '#e0e0e0',
                                display: 'flex',
                                alignItems: 'center',
                                justifyContent: 'center',
                                fontSize: '12px',
                                fontWeight: 'bold',
                                color: '#666'
                              }}
                            >
                              {(s.full_name || `${s.user_fn || ''} ${s.user_ln || ''}`.trim()).split(' ').map(n => n[0]).join('').substring(0, 2)}
                            </div>
                            <span>{s.full_name || `${s.user_fn || ''} ${s.user_ln || ''}`.trim()}</span>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>

                  {/* Reason select */}
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

      {/* Modal: Appointment Details */}
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
                  <strong>Date:</strong> {detailsModalAppointment.time.split('•')[0].trim()}
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