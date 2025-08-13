// Daily log history list UI
import React from "react";

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

const DailyLogHistory = ({
  historyItems = dailyLogHistoryItems,
  onViewDetails,
  searchTerm,
}) => {
  // Filter by search
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

  // Group by date
  const groups = getDailyLogGroups(filteredItems).filter(
    (group) =>
      Array.isArray(group.items) &&
      group.items.some((item) => item.studentName && item.name && item.reason)
  );

  return (
    <div className="moderator-history-card-list">
      {groups.map((group) => (
        <React.Fragment key={group.date}>
          <div
            style={{
              fontWeight: "bold",
              fontSize: "1.1em",
              margin: "-.9em 0 8px 0",
            }}
          >
            {formatDateHeader(group.date)}
          </div>
          {group.items
            .filter((item) => item.studentName && item.name && item.reason)
            .map((item) => (
              <div
                key={item.id}
                className="moderator-history-item"
                data-status={item.status}
              >
                <div className="moderator-history-appointment-info">
                  <div className="moderator-history-appointment-name moderator-history-name">
                    Name: {item.studentName}
                  </div>
                  <div className="moderator-history-appointment-details moderator-history-details">
                    Faculty: {item.name}
                  </div>
                  <div className="moderator-history-appointment-time">
                    Date • Time: {formatDateHeader(group.date)} •{" "}
                    {item.time.split(" ")[1] || item.time.split(" - ")[1]}
                  </div>
                  <div className="moderator-history-appointment-details moderator-history-details">
                    Reason: {item.reason}
                  </div>
                  {/* Details button */}
                  <div
                    style={{ display: "flex", gap: "10px", marginTop: "6px" }}
                  >
                    <button
                      className="moderator-home-see-more-btn small-btn-text"
                      onClick={() => onViewDetails(item)}
                    >
                      View Details
                    </button>
                  </div>
                </div>
              </div>
            ))}
        </React.Fragment>
      ))}
    </div>
  );
};

export default DailyLogHistory;
