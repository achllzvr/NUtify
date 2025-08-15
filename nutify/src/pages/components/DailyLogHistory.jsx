// Daily log history list UI
import React from "react";

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

const DailyLogHistory = ({
  historyItems = dailyLogHistoryItems,
  onViewDetails,
  searchTerm,
}) => {
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

  return (
    <div className="moderator-history-card-list">
      {flatItems.map((entry, idx) =>
        entry.type === "header" ? (
          <div
            key={"header-" + entry.date}
            style={{
              fontWeight: "900",
              fontSize: "1.4em",
              margin: "1px 0 8px 0", // changed: marginTop is now 1px
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
                style={{ fontSize: "1.25em" }} // slightly bigger student name
              >
                {entry.studentName}
              </div>
              <div
                className="moderator-history-appointment-details moderator-history-details"
                style={{ fontSize: "1.08em", color: "#424A57" }} // slightly bigger faculty
              >
                Faculty: {entry.name}
              </div>
              <div
                className="moderator-history-appointment-time"
                style={{ fontSize: "1.08em", color: "#424A57" }} // slightly bigger time
              >
                Date: {formatDateTime(entry.time)}
              </div>
              <div
                className="moderator-history-appointment-details moderator-history-details"
                style={{ fontSize: "1.08em", color: "#424A57" }} // slightly bigger reason
              >
                Reason: {entry.reason}
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
      )}
    </div>
  );
};

export default DailyLogHistory;