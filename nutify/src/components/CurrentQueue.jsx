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

const upcomingAppointments = [
  { id: 1, name: 'Jei Pastrana', studentName: 'Beatriz Solis', department: 'Faculty - SACE', time: 'June 15 • 09:00 - 10:00', avatar: jeiPastranaAvatar, reason: mapReason('Consultation') },
  { id: 2, name: 'Irene Balmes', studentName: 'John Clarenz Dimazana', department: 'Faculty - SACE', time: 'June 14 • 09:00 - 10:00', avatar: ireneBalmes, reason: mapReason('Meeting') },
  { id: 3, name: 'Jei Pastrana', studentName: 'Kriztopher Kier Estioco', department: 'Faculty - SACE', time: 'June 15 • 09:00 - 10:00', avatar: jeiPastranaAvatar, reason: mapReason('Project') },
  { id: 4, name: 'Carlo Torres', studentName: 'Niel Cerezo', department: 'Faculty - SACE', time: 'June 16 • 10:00 - 11:00', avatar: carloTorres, reason: mapReason('Other') },
  { id: 5, name: 'Archie Menisis', studentName: 'Ella Ramos', department: 'Faculty - SACE', time: 'June 17 • 11:00 - 12:00', avatar: archieMenisis, reason: mapReason('Consultation') },
  { id: 6, name: 'Michael Joseph Aramil', studentName: 'Francis Lee', department: 'Faculty - SACE', time: 'June 18 • 12:00 - 01:00', avatar: michaelAramil, reason: mapReason('Other') },
  { id: 7, name: 'Erwin De Castro', studentName: 'Grace Uy', department: 'Faculty - SACE', time: 'June 19 • 01:00 - 02:00', avatar: erwinDeCastro, reason: mapReason('Meeting') },
  { id: 8, name: 'Joel Enriquez', studentName: 'Henry Sy', department: 'Faculty - SACE', time: 'June 20 • 02:00 - 03:00', avatar: joelEnriquez, reason: mapReason('Consultation') },
  { id: 9, name: 'Bernie Fabito', studentName: 'Ivy Dela Cruz', department: 'Faculty - SACE', time: 'June 21 • 03:00 - 04:00', avatar: bernieFabito, reason: mapReason('Other') }
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
    // Accepts formats like "June 15 • 09:00 - 10:00"
    if (!dateStr) return '';
    const [datePart, timePart] = dateStr.split('•').map(s => s.trim());
    // Try to parse the date part and add current year if missing
    let d = new Date(datePart + ' ' + new Date().getFullYear());
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
        {paginatedQueue.map(appointment => {
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
        })}
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