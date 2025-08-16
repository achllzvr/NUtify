// Daily log history list UI
import React, { useState } from "react";

// Helper to normalize date string to YYYY-MM-DD
const normalizeDateKey = (dateStr) => {
  const d = new Date(dateStr);
  if (isNaN(d.getTime())) return dateStr;
  // Pad month and day
  const yyyy = d.getFullYear();
  const mm = String(d.getMonth() + 1).padStart(2, '0');
  const dd = String(d.getDate()).padStart(2, '0');
  return `${yyyy}-${mm}-${dd}`;
};

// Format date for header (now includes year)
const formatDateHeader = (dateStr) => {
  const d = new Date(dateStr);
  return isNaN(d.getTime())
    ? dateStr
    : d.toLocaleString("en-US", { month: "long", day: "numeric", year: "numeric" });
};

// Format date and time for item row
const formatDateTime = (dateStr) => {
  const d = new Date(dateStr);
  if (isNaN(d.getTime())) return dateStr;
  const datePart = d.toLocaleString("en-US", { month: "long", day: "numeric", year: "numeric" });
  const timePart = d.toLocaleTimeString("en-US", { hour: "2-digit", minute: "2-digit", hour12: false });
  return `${datePart} • ${timePart}`;
};

// Group dailylog items by normalized date
const getDailyLogGroups = (items) => {
  const groups = {};
  items.forEach((item) => {
    if (item.status === "dailylog") {
      const dateKey = normalizeDateKey(item.time);
      if (!groups[dateKey]) groups[dateKey] = [];
      groups[dateKey].push(item);
    }
  });
  const sortedDates = Object.keys(groups).sort((a, b) => {
    const da = new Date(a),
      db = new Date(b);
    if (!isNaN(da.getTime()) && !isNaN(db.getTime())) return db - da;
    return a < b ? 1 : -1;
  });
  return sortedDates.map((dateKey) => ({
    date: dateKey,
    items: groups[dateKey],
  }));
};

const facultyList = [
  { id: 1, name: 'Jayson Guia', avatar: null },
  { id: 2, name: 'Jei Pastrana', avatar: null },
  { id: 3, name: 'Irene Balmes', avatar: null },
  { id: 4, name: 'Carlo Torres', avatar: null },
  { id: 5, name: 'Archie Menisis', avatar: null },
  { id: 6, name: 'Michael Joseph Aramil', avatar: null }
];

const studentNames = [
  "Kier Kriztopher",
  "Achilles Vonn",
  "Sophia Marie",
  "Beatriz Gail",
  "Prinz Noel",
  "Mark Matthew"
];

const dailyLogHistoryItems = [
  {
    id: 1,
    studentName: studentNames[0],
    name: facultyList[0].name,
    details: "Faculty - SACE",
    time: "July 29, 2025 09:00",
    status: "dailylog",
    reason: "Consultation about thesis",
  },
  {
    id: 2,
    studentName: studentNames[1],
    name: facultyList[1].name,
    details: "Faculty - SACE",
    time: "July 29, 2025 10:00",
    status: "dailylog",
    reason: "Grade inquiry",
  },
  {
    id: 3,
    studentName: studentNames[2],
    name: facultyList[2].name,
    details: "Faculty - SACE",
    time: "July 29, 2025 11:00",
    status: "dailylog",
    reason: "Follow-up on project",
  },
  {
    id: 4,
    studentName: studentNames[3],
    name: facultyList[3].name,
    details: "Faculty - SACE",
    time: "July 29, 2025 13:00",
    status: "dailylog",
    reason: "Request for extension",
  },
  {
    id: 5,
    studentName: studentNames[4],
    name: facultyList[4].name,
    details: "Faculty - SACE",
    time: "July 29, 2025 14:00",
    status: "dailylog",
    reason: "Consultation about requirements",
  },
  {
    id: 6,
    studentName: studentNames[5],
    name: facultyList[5].name,
    details: "Faculty - SACE",
    time: "July 29, 2025 15:00",
    status: "dailylog",
    reason: "Feedback on assignment",
  },
  // --- Added July 30 logs ---
  {
    id: 7,
    studentName: studentNames[0],
    name: facultyList[1].name,
    details: "Faculty - SACE",
    time: "July 30, 2025 09:30",
    status: "dailylog",
    reason: "Schedule consultation",
  },
  {
    id: 8,
    studentName: studentNames[2],
    name: facultyList[2].name,
    details: "Faculty - SACE",
    time: "July 30, 2025 10:30",
    status: "dailylog",
    reason: "Discuss project updates",
  },
  {
    id: 9,
    studentName: studentNames[4],
    name: facultyList[4].name,
    details: "Faculty - SACE",
    time: "July 30, 2025 13:00",
    status: "dailylog",
    reason: "Request for feedback",
  },
];

const ITEMS_PER_PAGE = 10;

// Helper to truncate reason to max 6 words
const truncateReason = (reason) => {
  if (!reason) return "";
  const words = reason.split(" ");
  if (words.length <= 6) return reason;
  return words.slice(0, 6).join(" ") + "...";
};

const DailyLogHistory = ({
  historyItems = dailyLogHistoryItems,
  onViewDetails,
  searchTerm,
}) => {
  const [page, setPage] = useState(1);
  const [selectedDate, setSelectedDate] = useState(""); // new state for date picker

  // Handle date picker change
  const handleDateChange = (e) => {
    setSelectedDate(e.target.value);
    setPage(1); // reset to first page on date change
  };

  // Filter items by search and selected date
  const filteredItems = historyItems.filter(
    (item) =>
      item.status === "dailylog" &&
      (!searchTerm ||
        (item.studentName &&
          item.studentName.toLowerCase().includes(searchTerm.toLowerCase())) ||
        (item.name &&
          item.name.toLowerCase().includes(searchTerm.toLowerCase())) ||
        (item.reason &&
          item.reason.toLowerCase().includes(searchTerm.toLowerCase()))) &&
      (!selectedDate ||
        normalizeDateKey(item.time) === selectedDate) // filter by normalized date
  );

  const groups = getDailyLogGroups(filteredItems).filter(
    (group) =>
      Array.isArray(group.items) &&
      group.items.some((item) => item.studentName && item.name && item.reason)
  );

  const flatItems = [];
  groups.forEach((group) => {
    flatItems.push({ type: "header", date: group.date });
    group.items
      .filter((item) => item.studentName && item.name && item.reason)
      .forEach((item) =>
        flatItems.push({ type: "item", ...item, groupDate: group.date })
      );
  });

  // Pagination logic
  const totalPages = Math.max(1, Math.ceil(flatItems.length / ITEMS_PER_PAGE));
  const paginatedItems = flatItems.slice(
    (page - 1) * ITEMS_PER_PAGE,
    page * ITEMS_PER_PAGE
  );

  const handlePrev = () => setPage(prev => Math.max(prev - 1, 1));
  const handleNext = () => setPage(prev => Math.min(prev + 1, totalPages));

  return (
    <>
      {/* Date Picker */}
      <div style={{ marginBottom: "16px", display: "flex", alignItems: "center", gap: "12px" }}>
        <label htmlFor="dailylog-date-picker" style={{ fontWeight: 500, fontSize: "1.08em", color: "#424A57" }}>
          Filter by Date:
        </label>
        <input
          id="dailylog-date-picker"
          type="date"
          value={selectedDate}
          onChange={handleDateChange}
          style={{
            padding: "6px 12px",
            borderRadius: "8px",
            border: "none",
            fontSize: "1em",
            fontFamily: "inherit",
            background: "#f0f0f0",
            color: "#424A57",
            boxShadow: "inset 4px 4px 8px #e0e0e0, inset -4px -4px 8px #fff",
            outline: "none",
            transition: "box-shadow 0.2s"
          }}
        />
        {selectedDate && (
          <button
            onClick={() => setSelectedDate("")}
            style={{
              marginLeft: "8px",
              padding: "6px 12px",
              borderRadius: "8px",
              border: "none",
              background: "#f0f0f0",
              color: "#424A57",
              cursor: "pointer",
              fontWeight: 500,
              boxShadow: "4px 4px 8px #e0e0e0, -4px -4px 8px #fff",
              transition: "box-shadow 0.2s"
            }}
            onMouseDown={e => e.currentTarget.style.boxShadow = "inset 4px 4px 8px #e0e0e0, inset -4px -4px 8px #fff"}
            onMouseUp={e => e.currentTarget.style.boxShadow = "4px 4px 8px #e0e0e0, -4px -4px 8px #fff"}
            onMouseLeave={e => e.currentTarget.style.boxShadow = "4px 4px 8px #e0e0e0, -4px -4px 8px #fff"}
          >
            Clear
          </button>
        )}
      </div>
      <div
        className="moderator-history-card-list"
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
        {paginatedItems.length === 0 ? (
          <div style={{ textAlign: 'center', color: '#888', marginTop: '40px', fontSize: '1.2em', fontWeight: 500 }}>
            No logs yet.
          </div>
        ) : (
          paginatedItems.map((entry, idx) =>
            entry.type === "header" ? (
              <div
                key={"header-" + entry.date}
                style={{
                  fontWeight: "900",
                  fontSize: "1.4em",
                  margin: "1px 0 8px 0",
                }}
              >
                {formatDateHeader(entry.date)}
              </div>
            ) : (
              <div
                key={entry.id}
                className="moderator-history-item"
                data-status={entry.status}
                style={{
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "space-between",
                }}
              >
                <div
                  className="moderator-history-appointment-info"
                  style={{ flex: 1 }}
                >
                  <div
                    className="moderator-history-appointment-name moderator-history-name"
                    style={{ fontSize: "1.25em" }}
                  >
                    {entry.studentName}
                  </div>
                  <div
                    className="moderator-history-appointment-details moderator-history-details"
                    style={{ fontSize: "1.08em", color: "#424A57" }}
                  >
                    Faculty: {entry.name}
                  </div>
                  <div
                    className="moderator-history-appointment-time"
                    style={{ fontSize: "1.08em", color: "#424A57" }}
                  >
                    Date: {formatDateTime(entry.time)}
                  </div>
                  <div
                    className="moderator-history-appointment-details moderator-history-details"
                    style={{ fontSize: "1.08em", color: "#424A57" }}
                  >
                    Reason: {truncateReason(entry.reason)}
                  </div>
                </div>
                <div style={{ display: "flex", gap: "10px", marginLeft: "18px" }}>
                  <button
                    className="moderator-home-see-more-btn gray details small-btn-text"
                    onClick={() => onViewDetails(entry)}
                  >
                    View Details
                  </button>
                </div>
              </div>
            )
          )
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
    </>
  );
};

export default DailyLogHistory;