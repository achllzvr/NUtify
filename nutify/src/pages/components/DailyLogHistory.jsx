// Daily log history list UI
import React, { useState } from "react";

// Format date for header
const formatDateHeader = (dateStr) => {
  const d = new Date(dateStr);
  return isNaN(d.getTime())
    ? dateStr
    : d.toLocaleString("en-US", { month: "long", day: "numeric" });
};

// Group dailylog items by date
const getDailyLogGroups = (items) => {
  const groups = {};
  items.forEach((item) => {
    if (item.status === "dailylog") {
      const dateKey =
        item.time.includes("-") && item.time.includes(":")
          ? item.time.split(" ")[0]
          : item.time.split(" - ")[0];
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

// Example daily log items
const dailyLogHistoryItems = [
  {
    id: 1,
    studentName: "Beatriz Solis",
    name: "Jei Pastrana",
    details: "Faculty - SACE",
    time: "2024-07-29 09:00",
    status: "dailylog",
    reason: "Consultation about thesis",
  },
  {
    id: 2,
    studentName: "John Clarenz Dimazana",
    name: "Irene Balmes",
    details: "Faculty - SACE",
    time: "2024-07-29 10:00",
    status: "dailylog",
    reason: "Grade inquiry",
  },
  {
    id: 3,
    studentName: "Kriztopher Kier Estioco",
    name: "Jei Pastrana",
    details: "Faculty - SACE",
    time: "2024-07-29 11:00",
    status: "dailylog",
    reason: "Follow-up on project",
  },
  {
    id: 4,
    studentName: "Niel Cerezo",
    name: "Irene Balmes",
    details: "Faculty - SACE",
    time: "2024-07-28 09:00",
    status: "dailylog",
    reason: "Request for extension",
  },
  {
    id: 5,
    studentName: "Ella Ramos",
    name: "Jei Pastrana",
    details: "Faculty - SACE",
    time: "2024-07-28 10:00",
    status: "dailylog",
    reason: "Consultation about requirements",
  },
  {
    id: 6,
    studentName: "Francis Lee",
    name: "Carlo Torres",
    details: "Faculty - SACE",
    time: "2024-07-28 11:00",
    status: "dailylog",
    reason: "Feedback on assignment",
  },
];

const DAILYLOG_PER_PAGE = 10;

const DailyLogHistory = ({
  historyItems = dailyLogHistoryItems,
  onViewDetails,
  searchTerm,
}) => {
  const [page, setPage] = useState(1);

  const filteredItems = historyItems.filter(
    (item) =>
      item.status === "dailylog" &&
      (!searchTerm ||
        (item.studentName &&
          item.studentName.toLowerCase().includes(searchTerm.toLowerCase())) ||
        (item.name &&
          item.name.toLowerCase().includes(searchTerm.toLowerCase())) ||
        (item.reason &&
          item.reason.toLowerCase().includes(searchTerm.toLowerCase())))
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

  const totalPages = Math.max(1, Math.ceil(flatItems.length / DAILYLOG_PER_PAGE));
  const paginatedFlatItems = flatItems.slice(
    (page - 1) * DAILYLOG_PER_PAGE,
    page * DAILYLOG_PER_PAGE
  );

  const handlePrev = () => setPage((prev) => Math.max(prev - 1, 1));
  const handleNext = () => setPage((prev) => Math.min(prev + 1, totalPages));

  return (
    <div className="moderator-history-card-list">
      {paginatedFlatItems.map((entry, idx) =>
        entry.type === "header" ? (
          <div
            key={"header-" + entry.date}
            style={{
              fontWeight: "900",
              fontSize: "1.4em",
              margin: "-.7em 0 8px 0",
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
              <div className="moderator-history-appointment-name moderator-history-name">
                {entry.studentName}
              </div>
              <div className="moderator-history-appointment-details moderator-history-details">
                Faculty: {entry.name}
              </div>
              <div className="moderator-history-appointment-time">
                Date • Time: {formatDateHeader(entry.groupDate)} •{" "}
                {entry.time.split(" ")[1] || entry.time.split(" - ")[1]}
              </div>
              <div className="moderator-history-appointment-details moderator-history-details">
                Reason: {entry.reason}
              </div>
            </div>
            <div style={{ display: "flex", gap: "10px", marginLeft: "18px" }}>
              <button
                className="moderator-home-see-more-btn small-btn-text"
                onClick={() => onViewDetails(entry)}
              >
                View Details
              </button>
            </div>
          </div>
        )
      )}
      <div
        style={{
          display: "flex",
          justifyContent: "center",
          marginTop: "12px",
          gap: "10px",
        }}
      >
        <button
          onClick={handlePrev}
          disabled={page === 1}
          style={{
            padding: "6px 14px",
            borderRadius: "8px",
            border: "none",
            background: "#f0f0f0",
            color: "#7f8c8d",
            cursor: page === 1 ? "not-allowed" : "pointer",
            fontWeight: 500,
          }}
        >
          Prev
        </button>
        <span
          style={{
            fontWeight: 500,
            fontSize: "15px",
            color: "#7f8c8d",
            background: "#f0f0f0",
            borderRadius: "8px",
            padding: "6px 14px",
            border: "none",
            display: "flex",
            alignItems: "center",
          }}
        >
          Page {page} of {totalPages}
        </span>
        <button
          onClick={handleNext}
          disabled={page === totalPages}
          style={{
            padding: "6px 14px",
            borderRadius: "8px",
            border: "none",
            background: "#f0f0f0",
            color: "#7f8c8d",
            cursor: page === totalPages ? "not-allowed" : "pointer",
            fontWeight: 500,
          }}
        >
          Next
        </button>
      </div>
    </div>
  );
};

export default DailyLogHistory;
