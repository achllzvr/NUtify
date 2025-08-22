// Current queue section
import React, { useEffect, useMemo, useState } from 'react';
import { getModeratorHomeAppointments } from '../api/moderator';
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

// Safari-safe Date parser for common backend formats (e.g., "YYYY-MM-DD HH:mm:ss")
function parseDateSafe(input) {
  if (!input) return null;
  if (input instanceof Date) return isNaN(input.getTime()) ? null : input;
  // numeric timestamp
  if (typeof input === 'number') {
    const d = new Date(input);
    return isNaN(d.getTime()) ? null : d;
  }
  if (typeof input !== 'string') return null;
  // Try ISO-like by replacing space with 'T'
  let d = new Date(input.replace(' ', 'T'));
  if (!isNaN(d.getTime())) return d;
  // Fallback: replace '-' with '/' for older WebKit
  d = new Date(input.replace(/-/g, '/'));
  if (!isNaN(d.getTime())) return d;
  return null;
}

// Format a time (Date or HH:mm[:ss] string) to 12-hour with AM/PM
function formatTime12(dateOrString) {
  if (!dateOrString) return '';
  const d = parseDateSafe(dateOrString);
  if (d) return d.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true });
  if (typeof dateOrString === 'string') {
    const m = dateOrString.match(/^(\d{1,2}):(\d{2})(?::(\d{2}))?$/);
    if (m) {
      const hh = m[1].padStart(2, '0');
      const mm = m[2];
      const ss = m[3] ? m[3] : '00';
      const d2 = parseDateSafe(`1970-01-01 ${hh}:${mm}:${ss}`);
      if (d2) return d2.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true });
    }
  }
  return String(dateOrString);
}

function formatDateRange(dateLike, fromTimeLike, toTimeLike) {
  // dateLike can be a full datetime or just a date string.
  const dateObj = parseDateSafe(dateLike);
  const hasSeparateTimes = !!(fromTimeLike || toTimeLike);

  let dateLabel = '';
  if (dateObj) {
    dateLabel = dateObj.toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' });
  } else if (typeof dateLike === 'string' && dateLike.trim()) {
    // Use raw string if we can't parse
    dateLabel = dateLike.trim();
  }

  // Build time labels
  const timeFromLabel = formatTime12(fromTimeLike);
  const timeToLabel = formatTime12(toTimeLike);

  // If dateLike includes time (full datetime) and no separate times provided
  if (!hasSeparateTimes && dateObj && typeof dateLike === 'string' && /\d{2}:\d{2}/.test(dateLike)) {
    const t = dateObj.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true });
    return `${dateLabel}${t ? ' • ' + t : ''}`;
  }

  // If we have separate times
  if (dateLabel && (timeFromLabel || timeToLabel)) {
    return `${dateLabel} • ${timeFromLabel}${timeToLabel ? ' - ' + timeToLabel : ''}`.trim();
  }

  return dateLabel; // may be '' if nothing available
}

const facultyList = [
  { id: 1, name: 'Jayson Guia', department: 'Faculty - SACE', avatar: null },
  { id: 2, name: 'Jei Pastrana', department: 'Faculty - SACE', avatar: null },
  { id: 3, name: 'Irene Balmes', department: 'Faculty - SACE', avatar: null },
  { id: 4, name: 'Carlo Torres', department: 'Faculty - SACE', avatar: null },
  { id: 5, name: 'Archie Menisis', department: 'Faculty - SACE', avatar: null },
  { id: 6, name: 'Michael Joseph Aramil', department: 'Faculty - SACE', avatar: null },
  { id: 7, name: 'Erwin De Castro', department: 'Faculty - SACE', avatar: null },
  { id: 8, name: 'Joel Enriquez', department: 'Faculty - SACE', avatar: null },
  { id: 9, name: 'Bernie Fabito', department: 'Faculty - SACE', avatar: null },
  { id: 10, name: 'Bobby Buendia', department: 'Faculty - SAHS', avatar: null },
  { id: 11, name: 'Penny Lumbera', department: 'Faculty - SAHS', avatar: null },
  { id: 12, name: 'Larry Fronda', department: 'Faculty - SAHS', avatar: null }
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

// state will hold backend appointments
const QUEUE_PER_PAGE = 10;

const CurrentQueue = ({ mainSearch, onViewDetails, onNotifyAppointees, truncateReason, moderatorId = 0 }) => {
  const [page, setPage] = useState(1);
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    let mounted = true;
    (async () => {
      try {
        setLoading(true);
        setError('');
        // Use provided moderatorId or default 0; backend may ignore or use permissions
        const data = await getModeratorHomeAppointments(moderatorId);
        // Expect { appointments: [...] } or an array
        const list = Array.isArray(data) ? data : (data.appointments || []);
        // Map to UI fields
        const mapped = list
          .filter(a => a) // safety
          .map(a => {
            const id = a.appointment_id || a.id;
            const studentName = a.student_name || a.student || [a.student_fn, a.student_ln].filter(Boolean).join(' ');
            const facultyName = a.teacher_name || a.faculty || [a.teacher_fn, a.teacher_ln].filter(Boolean).join(' ');
            const department = a.department ? `Faculty - ${a.department}` : (a.faculty_department || 'Faculty');
            const reason = a.appointment_reason || a.reason || 'Other';
            // Try multiple common backend shapes for date/time
            // 1) Single datetime (appointment_date | appointment_datetime | datetime | created_at)
            const singleDateTime = a.appointment_date || a.appointment_datetime || a.datetime || a.time || a.created_at;
            // 2) Separate date + time fields (schedule_date + schedule_time_from/to OR date + start_time/end_time)
            const dateOnly = a.schedule_date || a.date || a.appointment_day;
            const fromTime = a.schedule_time_from || a.start_time || a.time_from;
            const toTime = a.schedule_time_to || a.end_time || a.time_to;

            let timeStr = '';
            if (singleDateTime) {
              // This will also pick up when backend sends "YYYY-MM-DD HH:mm:ss"
              timeStr = formatDateRange(singleDateTime, null, null);
            }
            if (!timeStr && (dateOnly || fromTime || toTime)) {
              timeStr = formatDateRange(dateOnly || singleDateTime, fromTime, toTime);
            }
            return {
              id,
              name: facultyName || '',
              studentName: studentName || '',
              department,
              time: timeStr,
              avatar: null,
              reason: mapReason(reason)
            };
          });
        if (mounted) setItems(mapped);
      } catch (e) {
        if (mounted) setError(e.message || 'Failed to load current queue');
      } finally {
        if (mounted) setLoading(false);
      }
    })();
    return () => { mounted = false; };
  }, [moderatorId]);

  const filteredQueue = useMemo(() => items.filter(a =>
    a.name.toLowerCase().includes(mainSearch.toLowerCase()) ||
    a.studentName.toLowerCase().includes(mainSearch.toLowerCase()) ||
    a.department.toLowerCase().includes(mainSearch.toLowerCase())
  ), [items, mainSearch]);

  const totalPages = Math.max(1, Math.ceil(filteredQueue.length / QUEUE_PER_PAGE));
  const paginatedQueue = filteredQueue.slice(
    (page - 1) * QUEUE_PER_PAGE,
    page * QUEUE_PER_PAGE
  );

  const handlePrev = () => setPage(prev => Math.max(prev - 1, 1));
  const handleNext = () => setPage(prev => Math.min(prev + 1, totalPages));

  const formatDateWithYear = (dateStr) => {
    if (!dateStr) return '';
    const parts = dateStr.split('•');
    const datePart = parts[0] ? parts[0].trim() : '';
    const timePart = parts[1] ? parts[1].trim() : '';
    const d = parseDateSafe(datePart);
    if (!d) return dateStr; // keep original if we cannot parse
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
    <h2 style={{ display: 'flex', alignItems: 'center', gap: '8px', margin: 0 }}>
          Current Queue
          <span
            aria-label="queued appointments count"
            style={{
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      fontSize: '13px',
      padding: '4px 10px',
              borderRadius: '9999px',
      background: loading ? '#9CA3AF' : (error ? '#EF4444' : '#ffa600ff'),
      color: '#ffffff',
      fontWeight: 700,
      lineHeight: 1,
      boxShadow: '0 1px 3px rgba(0,0,0,0.15)'
            }}
          >
            {loading ? '...' : (error ? '—' : items.length)}
          </span>
        </h2>
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
        {loading ? (
          <div style={{ textAlign: 'center', color: '#888', marginTop: '40px', fontSize: '1.2em', fontWeight: 500 }}>
            Loading queue...
          </div>
        ) : error ? (
          <div style={{ textAlign: 'center', color: '#d9534f', marginTop: '40px', fontSize: '1.0em', fontWeight: 500 }}>
            {error}
          </div>
        ) : paginatedQueue.length === 0 ? (
          <div style={{ textAlign: 'center', color: '#888', marginTop: '40px', fontSize: '1.2em', fontWeight: 500 }}>
            No queue for today.
          </div>
        ) : (
          paginatedQueue.map(appointment => {
            const reasonLabel = mapReason(appointment.reason);
            const { icon, bg } = reasonIconMap[reasonLabel];
            const fullReasonText =
              reasonLabel === 'Other'
                ? '*Unspecified Reason. Please consult with appointee.'
                : reasonLabel;
            const words = fullReasonText.split(' ');
            const shortReasonText =
              words.length > 6 ? words.slice(0, 6).join(' ') + '...' : fullReasonText;
            return (
              <div
                key={appointment.id}
                className="moderator-home-queue-card"
                style={{
                  display: 'flex',
                  alignItems: 'stretch',
                  width: '100%',
                  minWidth: 0,
                  boxSizing: 'border-box',
                  flexDirection: 'row'
                }}
              >
                {/* Icon bar */}
                <div
                  className="moderator-home-queue-icon-bar"
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
                {/* Card content */}
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
                      flexDirection: 'row'
                    }}
                  >
                    <div className="moderator-home-appointment-main" style={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                      <div className="moderator-home-appointment-avatar">
                        <div
                          className="moderator-home-avatar-img"
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
                      className="moderator-home-appointment-actions"
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