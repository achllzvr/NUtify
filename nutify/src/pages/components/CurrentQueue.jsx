import React, { useState } from 'react';
import jeiPastranaAvatar from '../assets/images/avatars/1c9a4dd0bbd964e3eecbd40caf3b7e37.jpg';
import ireneBalmes from '../assets/images/avatars/c33237da3438494d1abc67166196484e.jpg';
import carloTorres from '../assets/images/avatars/8940e8ea369def14e82f05a5fee994b9.jpg';
import archieMenisis from '../assets/images/avatars/78529e2ec8eb4a2eb2fb961e04915b0a.jpg';
import michaelAramil from '../assets/images/avatars/869f67a992bb6ca4cb657fb9fc634893.jpg';
import erwinDeCastro from '../assets/images/avatars/92770c61168481c94e1ba43df7615fd8.jpg';
import joelEnriquez from '../assets/images/avatars/944c5ba154e0489274504f38d01bcfaf.jpg';
import bernieFabito from '../assets/images/avatars/78529e2ec8eb4a2eb2fb961e04915b0a.jpg';
import messageCircleIcon from '../assets/icons/message-circle.svg';
import calendarIcon from '../assets/icons/calendar.svg';
import folderIcon from '../assets/icons/folder.svg';
import archiveIcon from '../assets/icons/archive.svg';
import jaysonGuia from '../assets/images/avatars/d447a9fd5010652f6c0911fbe9c662c6.jpg';
import bobbyBuendia from '../assets/images/avatars/237d3876ef98d5364ed1326813f4ed5b.jpg';
import pennyLumbera from '../assets/images/avatars/237d3876ef98d5364ed1326813f4ed5b.jpg';
import larryFronda from '../assets/images/avatars/237d3876ef98d5364ed1326813f4ed5b.jpg';

const REASON_OPTIONS = ['Consultation', 'Meeting', 'Project', 'Other'];
const reasonIconMap = {
  Consultation: { icon: messageCircleIcon, bg: '#3B82F6' },
  Meeting: { icon: calendarIcon, bg: '#10B981' },
  Project: { icon: folderIcon, bg: '#F59E0B' },
  Other: { icon: archiveIcon, bg: '#6B7280' }
};
function mapReason(reason) {
  if (!reason) return 'Other';
  const found = REASON_OPTIONS.find(opt => reason.trim().toLowerCase().startsWith(opt.toLowerCase()));
  return found || 'Other';
}

const facultyList = [
  { id: 1, name: 'Jayson Guia', department: 'Faculty - SACE', avatar: jaysonGuia },
  { id: 2, name: 'Jei Pastrana', department: 'Faculty - SACE', avatar: jeiPastranaAvatar },
  { id: 3, name: 'Irene Balmes', department: 'Faculty - SACE', avatar: ireneBalmes },
  { id: 4, name: 'Carlo Torres', department: 'Faculty - SACE', avatar: carloTorres },
  { id: 5, name: 'Archie Menisis', department: 'Faculty - SACE', avatar: archieMenisis },
  { id: 6, name: 'Michael Joseph Aramil', department: 'Faculty - SACE', avatar: michaelAramil },
  { id: 7, name: 'Erwin De Castro', department: 'Faculty - SACE', avatar: erwinDeCastro },
  { id: 8, name: 'Joel Enriquez', department: 'Faculty - SACE', avatar: joelEnriquez },
  { id: 9, name: 'Bernie Fabito', department: 'Faculty - SACE', avatar: bernieFabito },
  { id: 10, name: 'Bobby Buendia', department: 'Faculty - SAHS', avatar: bobbyBuendia },
  { id: 11, name: 'Penny Lumbera', department: 'Faculty - SAHS', avatar: pennyLumbera },
  { id: 12, name: 'Larry Fronda', department: 'Faculty - SAHS', avatar: larryFronda }
];

const studentNames = [
  "Kier Kriztopher",
  "Achilles Vonn",
  "Sophia Marie",
  "Beatriz Gail",
  "Prinz Noel",
  "Mark Matthew",
  "Nicole Aermione",
  "Mike Roan",
  "Romeo Paolo"
];

const upcomingAppointments = [
  {
    id: 1,
    name: facultyList[0].name,
    studentName: studentNames[0],
    department: facultyList[0].department,
    time: 'July 29, 2025 • 09:00 - 10:00',
    avatar: facultyList[0].avatar,
    reason: mapReason('Consultation')
  },
  {
    id: 2,
    name: facultyList[1].name,
    studentName: studentNames[1],
    department: facultyList[1].department,
    time: 'July 29, 2025 • 10:00 - 11:00',
    avatar: facultyList[1].avatar,
    reason: mapReason('Meeting')
  },
  {
    id: 3,
    name: facultyList[2].name,
    studentName: studentNames[2],
    department: facultyList[2].department,
    time: 'July 29, 2025 • 11:00 - 12:00',
    avatar: facultyList[2].avatar,
    reason: mapReason('Project')
  },
  {
    id: 4,
    name: facultyList[3].name,
    studentName: studentNames[3],
    department: facultyList[3].department,
    time: 'July 29, 2025 • 13:00 - 14:00',
    avatar: facultyList[3].avatar,
    reason: mapReason('Other')
  },
  {
    id: 5,
    name: facultyList[4].name,
    studentName: studentNames[4],
    department: facultyList[4].department,
    time: 'July 29, 2025 • 14:00 - 15:00',
    avatar: facultyList[4].avatar,
    reason: mapReason('Consultation')
  },
  {
    id: 6,
    name: facultyList[5].name,
    studentName: studentNames[5],
    department: facultyList[5].department,
    time: 'July 29, 2025 • 15:00 - 16:00',
    avatar: facultyList[5].avatar,
    reason: mapReason('Other')
  },
  {
    id: 7,
    name: facultyList[6].name,
    studentName: studentNames[6],
    department: facultyList[6].department,
    time: 'July 29, 2025 • 16:00 - 17:00',
    avatar: facultyList[6].avatar,
    reason: mapReason('Meeting')
  },
  {
    id: 8,
    name: facultyList[7].name,
    studentName: studentNames[7],
    department: facultyList[7].department,
    time: 'July 29, 2025 • 17:00 - 18:00',
    avatar: facultyList[7].avatar,
    reason: mapReason('Consultation')
  },
  {
    id: 9,
    name: facultyList[8].name,
    studentName: studentNames[8],
    department: facultyList[8].department,
    time: 'July 29, 2025 • 18:00 - 19:00',
    avatar: facultyList[8].avatar,
    reason: mapReason('Other')
  }
];

const QUEUE_PER_PAGE = 10;

const CurrentQueue = ({ mainSearch, onViewDetails, onNotifyAppointees, truncateReason }) => {
  const [page, setPage] = useState(1);

  const filteredQueue = upcomingAppointments.filter(a =>
    a.name.toLowerCase().includes(mainSearch.toLowerCase()) ||
    a.studentName.toLowerCase().includes(mainSearch.toLowerCase()) ||
    a.department.toLowerCase().includes(mainSearch.toLowerCase())
  );

  const totalPages = Math.max(1, Math.ceil(filteredQueue.length / QUEUE_PER_PAGE));
  const paginatedQueue = filteredQueue.slice(
    (page - 1) * QUEUE_PER_PAGE,
    page * QUEUE_PER_PAGE
  );

  const handlePrev = () => setPage(prev => Math.max(prev - 1, 1));
  const handleNext = () => setPage(prev => Math.min(prev + 1, totalPages));

  const formatDateWithYear = (dateStr) => {
    // Accepts formats like "July 29 2025 • 09:00 - 10:00"
    if (!dateStr) return '';
    const [datePart, timePart] = dateStr.split('•').map(s => s.trim());
    let d = new Date(datePart);
    if (isNaN(d.getTime())) return dateStr;
    const formattedDate = d.toLocaleString('en-US', { month: 'long', day: 'numeric', year: 'numeric' });
    return `${formattedDate}${timePart ? ' • ' + timePart : ''}`;
  };

  return (
    <div
      className="moderator-home-appointment-section"
      id="moderator-home-upcomingAppointments"
      style={{
        height: '780px',
        display: 'flex',
        flexDirection: 'column'
      }}
    >
      <div className="moderator-home-section-header">
        <h2>Current Queue</h2>
      </div>
      <div
        className="moderator-home-queue-list"
        style={{
          flex: '1 1 auto',
          minHeight: 0,
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'flex-start',
          overflowY: 'auto',
          paddingRight: '8px',
          marginRight: '-8px'
        }}
      >
        {paginatedQueue.length === 0 ? (
          <div style={{ textAlign: 'center', color: '#888', marginTop: '40px', fontSize: '1.2em', fontWeight: 500 }}>
            No queue for today.
          </div>
        ) : (
          paginatedQueue.map(appointment => {
            const reasonLabel = mapReason(appointment.reason);
            const { icon, bg } = reasonIconMap[reasonLabel];
            // Show lorem ipsum if reason is Other
            const fullReasonText =
              reasonLabel === 'Other'
                ? 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam euismod, nunc ut laoreet.'
                : reasonLabel;
            // Limit to 6 words for card
            const words = fullReasonText.split(' ');
            const shortReasonText =
              words.length > 6 ? words.slice(0, 6).join(' ') + '...' : fullReasonText;
            return (
              <div
                key={appointment.id}
                style={{
                  display: 'flex',
                  alignItems: 'stretch',
                  width: '100%',
                  minWidth: 0,
                  boxSizing: 'border-box'
                }}
              >
                {/* container2: vertical icon bar */}
                <div
                  style={{
                    width: '60px',
                    minWidth: '60px',
                    height: '100%',
                    background: bg,
                    borderTopLeftRadius: '15px',
                    borderBottomLeftRadius: '15px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    boxShadow: 'inset 8px 8px 15px rgba(0,0,0,0.10), inset -8px -8px 15px rgba(255,255,255,0.08)',
                    backgroundClip: 'padding-box',
                    marginRight: '-5px'
                  }}
                >
                  <img src={icon} alt={reasonLabel} style={{ width: 20, height: 20, filter: 'brightness(0) invert(1)' }} />
                </div>
                {/* container3: card content */}
                <div style={{ flex: 1 }}>
                  <div
                    className="moderator-home-appointment-item"
                    style={{
                      padding: '18px 22px',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      borderTopLeftRadius: 0,
                      borderBottomLeftRadius: 0,
                    }}
                  >
                    <div style={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                      <div className="moderator-home-appointment-avatar">
                        <img src={appointment.avatar} alt={appointment.name} className="moderator-home-avatar-img" />
                      </div>
                      <div className="moderator-home-appointment-info" style={{ flex: 1 }}>
                        <div className="moderator-home-appointment-name">{appointment.name}</div>
                        <div className="moderator-home-appointment-details">
                          Student: {appointment.studentName}
                        </div>
                        <div className="moderator-home-appointment-time">
                          Date: {formatDateWithYear(appointment.time)}
                        </div>
                        <div className="moderator-home-appointment-details" style={{ marginTop: '2px', marginBottom: '8px' }}>
                          Reason: {shortReasonText}
                        </div>
                      </div>
                    </div>
                    <div
                      style={{
                        display: 'flex',
                        flexDirection: 'column',
                        gap: '10px',
                        alignItems: 'flex-end',
                        minWidth: '140px'
                      }}
                    >
                      <button
                        className="moderator-home-see-more-btn gray details small-btn-text"
                        style={{ width: '130px', fontSize: '12px', padding: '8px 15px' }}
                        onClick={() => onViewDetails({ ...appointment, reason: fullReasonText })}
                      >
                        View Details
                      </button>
                      <button
                        className="moderator-home-notify-btn verify small-btn-text"
                        style={{ width: '130px', fontSize: '12px', padding: '8px 15px' }}
                        onClick={() => onNotifyAppointees(appointment)}
                      >
                        <span style={{ display: 'block', lineHeight: '1.2' }}>Notify<br />Appointees</span>
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            );
          })
        )}
      </div>
      <div style={{ display: 'flex', justifyContent: 'center', marginTop: '12px', gap: '10px' }}>
        <button
          onClick={handlePrev}
          disabled={page === 1}
          style={{
            padding: '6px 14px',
            borderRadius: '8px',
            border: 'none',
            background: '#f0f0f0',
            color: '#7f8c8d',
            cursor: page === 1 ? 'not-allowed' : 'pointer',
            fontWeight: 500,
            boxShadow: '4px 4px 8px #e0e0e0, -4px -4px 8px #fff'
          }}
        >
          Prev
        </button>
        <span style={{
          fontWeight: 500,
          fontSize: '15px',
          color: '#7f8c8d',
          background: '#f0f0f0',
          borderRadius: '8px',
          padding: '6px 14px',
          border: 'none',
          display: 'flex',
          alignItems: 'center',
          boxShadow: '4px 4px 8px #e0e0e0, -4px -4px 8px #fff'
        }}>
          Page {page} of {totalPages}
        </span>
        <button
          onClick={handleNext}
          disabled={page === totalPages}
          style={{
            padding: '6px 14px',
            borderRadius: '8px',
            border: 'none',
            background: '#f0f0f0',
            color: '#7f8c8d',
            cursor: page === totalPages ? 'not-allowed' : 'pointer',
            fontWeight: 500,
            boxShadow: '4px 4px 8px #e0e0e0, -4px -4px 8px #fff'
          }}
        >
          Next
        </button>
      </div>
    </div>
  );
};

export default CurrentQueue;