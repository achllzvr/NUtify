import React, { useState } from 'react';
import jeiPastranaAvatar from '../assets/images/avatars/1c9a4dd0bbd964e3eecbd40caf3b7e37.jpg';
import ireneBalmes from '../assets/images/avatars/c33237da3438494d1abc67166196484e.jpg';
import carloTorres from '../assets/images/avatars/8940e8ea369def14e82f05a5fee994b9.jpg';
import archieMenisis from '../assets/images/avatars/78529e2ec8eb4a2eb2fb961e04915b0a.jpg';
import michaelAramil from '../assets/images/avatars/869f67a992bb6ca4cb657fb9fc634893.jpg';
import erwinDeCastro from '../assets/images/avatars/92770c61168481c94e1ba43df7615fd8.jpg';
import joelEnriquez from '../assets/images/avatars/944c5ba154e0489274504f38d01bcfaf.jpg';
import bernieFabito from '../assets/images/avatars/78529e2ec8eb4a2eb2fb961e04915b0a.jpg';

const upcomingAppointments = [
  { id: 1, name: 'Jei Pastrana', studentName: 'Beatriz Solis', department: 'Faculty - SACE', time: 'June 15 • 09:00 - 10:00', avatar: jeiPastranaAvatar, reason: 'Consultation about thesis proposal and research direction.' },
  { id: 2, name: 'Irene Balmes', studentName: 'John Clarenz Dimazana', department: 'Faculty - SACE', time: 'June 14 • 09:00 - 10:00', avatar: ireneBalmes, reason: 'Grade inquiry for last semester.' },
  { id: 3, name: 'Jei Pastrana', studentName: 'Kriztopher Kier Estioco', department: 'Faculty - SACE', time: 'June 15 • 09:00 - 10:00', avatar: jeiPastranaAvatar, reason: 'Requesting recommendation letter for scholarship application.' },
  { id: 4, name: 'Carlo Torres', studentName: 'Niel Cerezo', department: 'Faculty - SACE', time: 'June 16 • 10:00 - 11:00', avatar: carloTorres, reason: 'Follow-up on project feedback.' },
  { id: 5, name: 'Archie Menisis', studentName: 'Ella Ramos', department: 'Faculty - SACE', time: 'June 17 • 11:00 - 12:00', avatar: archieMenisis, reason: 'Consultation regarding course requirements and deadlines.' },
  { id: 6, name: 'Michael Joseph Aramil', studentName: 'Francis Lee', department: 'Faculty - SACE', time: 'June 18 • 12:00 - 01:00', avatar: michaelAramil, reason: 'Request for extension on assignment submission.' },
  { id: 7, name: 'Erwin De Castro', studentName: 'Grace Uy', department: 'Faculty - SACE', time: 'June 19 • 01:00 - 02:00', avatar: erwinDeCastro, reason: 'Discussion about internship opportunities.' },
  { id: 8, name: 'Joel Enriquez', studentName: 'Henry Sy', department: 'Faculty - SACE', time: 'June 20 • 02:00 - 03:00', avatar: joelEnriquez, reason: 'Clarification on exam coverage.' },
  { id: 9, name: 'Bernie Fabito', studentName: 'Ivy Dela Cruz', department: 'Faculty - SACE', time: 'June 21 • 03:00 - 04:00', avatar: bernieFabito, reason: 'Request for additional consultation slot due to schedule conflict.' }
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

  return (
    <div
      className="moderator-home-appointment-section"
      id="moderator-home-upcomingAppointments"
      style={{
        height: '780px', // fixed height
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
        {paginatedQueue.map(appointment => (
          <div
            key={appointment.id}
            className="moderator-home-appointment-item"
            style={{
              padding: '18px 22px', // add padding
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between'
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
                  {appointment.time}
                </div>
                <div className="moderator-home-appointment-details" style={{ marginTop: '2px', marginBottom: '8px' }}>
                  Reason: {truncateReason(appointment.reason)}
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
                onClick={() => onViewDetails(appointment)}
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
        ))}
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