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
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
          }}
        >
          <div className="moderator-history-appointment-info" style={{ flex: 1 }}>
            <div
              className="moderator-history-appointment-name moderator-history-name"
              style={{ fontSize: "1.25em" }} // slightly bigger name
            >
              {item.name}
            </div>
            <div
              className="moderator-history-appointment-details moderator-history-details"
              style={{ fontSize: "1.08em", color: "#424A57" }} // slightly bigger student
            >
              Student: {item.studentName}
            </div>
            <div
              className="moderator-history-appointment-details moderator-history-details"
              style={{ fontSize: "1.08em", color: "#424A57" }} // slightly bigger status
            >
              Status: Pending
            </div>
            <div
              className="moderator-history-appointment-time"
              style={{ fontSize: "1.08em", color: "#424A57" }} // slightly bigger time
            >
              Timestamp: {formatDateMMDDYYYY(item.time)} •{" "}
              {item.time.split(" ")[1] ||
                item.time.split(" - ")[1] ||
                "00:00 am"}
            </div>
            <div
              className="moderator-history-appointment-details moderator-history-details"
              style={{ fontSize: "1.08em", color: "#424A57" }} // slightly bigger reason
            >
              Reason: {item.reason}
            </div>
          </div>
          <div style={{ display: "flex", gap: "10px", marginLeft: "18px" }}>
            <button
              className="moderator-history-see-more-btn gray details"
              onClick={() => onViewDetails(item)}
            >
              View Details
            </button>
          </div>
        </div>
      ))}
    </div>
  );
};

export default RequestHistory;