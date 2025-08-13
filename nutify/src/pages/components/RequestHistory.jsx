// Request history list UI
import React from "react";

// Format date as MM/DD/YYYY
const formatDateMMDDYYYY = (dateStr) => {
  const d = new Date(dateStr);
  return isNaN(d.getTime())
    ? dateStr
    : `${(d.getMonth() + 1).toString().padStart(2, "0")}/${d
        .getDate()
        .toString()
        .padStart(2, "0")}/${d.getFullYear()}`;
};

// Example request items
export const requestHistoryItems = [
  {
    id: 101,
    name: "Jei Pastrana",
    studentName: "Beatriz Solis",
    status: "pending",
    time: "2024-07-27 09:00",
    reason: "Request for thesis consultation",
  },
  {
    id: 102,
    name: "Irene Balmes",
    studentName: "John Clarenz Dimazana",
    status: "pending",
    time: "2024-07-27 10:00",
    reason: "Request for grade review",
  },
  {
    id: 103,
    name: "Carlo Torres",
    studentName: "Ella Ramos",
    status: "pending",
    time: "2024-07-27 11:00",
    reason: "Request for project feedback",
  },
  {
    id: 104,
    name: "Archie Menisis",
    studentName: "Francis Lee",
    status: "pending",
    time: "2024-07-27 13:00",
    reason: "Request for consultation slot",
  },
  {
    id: 105,
    name: "Michael Joseph Aramil",
    studentName: "Grace Uy",
    status: "pending",
    time: "2024-07-27 14:00",
    reason: "Request for extension on assignment",
  },
];

const RequestHistory = ({ onViewDetails, searchTerm }) => {
  // Filter by search
  const filteredRequests = requestHistoryItems.filter(
    (item) =>
      !searchTerm ||
      (item.name &&
        item.name.toLowerCase().includes(searchTerm.toLowerCase())) ||
      (item.studentName &&
        item.studentName.toLowerCase().includes(searchTerm.toLowerCase())) ||
      (item.reason &&
        item.reason.toLowerCase().includes(searchTerm.toLowerCase()))
  );

  return (
    <div className="moderator-history-card-list">
      {filteredRequests.map((item) => (
        <div
          key={item.id}
          className="moderator-history-item"
          data-status="pending"
        >
          <div className="moderator-history-appointment-info">
            <div className="moderator-history-appointment-name moderator-history-name">
              Name: {item.name}
            </div>
            <div
              className="moderator-history-appointment-details moderator-history-details"
              style={{ fontSize: "13px", color: "#888", marginBottom: "2px" }}
            >
              Student: {item.studentName}
            </div>
            <div className="moderator-history-appointment-details moderator-history-details">
              Status: Pending
            </div>
            <div className="moderator-history-appointment-time">
              Timestamp: {formatDateMMDDYYYY(item.time)} •{" "}
              {item.time.split(" ")[1] ||
                item.time.split(" - ")[1] ||
                "00:00 am"}
            </div>
            <div className="moderator-history-appointment-details moderator-history-details">
              Reason: {item.reason}
            </div>
            {/* Details button */}
            <div style={{ display: "flex", gap: "10px", marginTop: "6px" }}>
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
    </div>
  );
};

export default RequestHistory;
