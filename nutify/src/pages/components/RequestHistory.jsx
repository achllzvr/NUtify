// Request history list UI
import React, { useState } from "react";

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

const REQUESTS_PER_PAGE = 10;

const RequestHistory = ({ onViewDetails, searchTerm }) => {
  const [page, setPage] = useState(1);

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

  const totalPages = Math.max(1, Math.ceil(filteredRequests.length / REQUESTS_PER_PAGE));
  const paginatedRequests = filteredRequests.slice(
    (page - 1) * REQUESTS_PER_PAGE,
    page * REQUESTS_PER_PAGE
  );

  const handlePrev = () => setPage((prev) => Math.max(prev - 1, 1));
  const handleNext = () => setPage((prev) => Math.min(prev + 1, totalPages));

  return (
    <div className="moderator-history-card-list">
      {paginatedRequests.map((item) => (
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
            <div className="moderator-history-appointment-name moderator-history-name">
              {item.name}
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
          </div>
          <div style={{ display: "flex", gap: "10px", marginLeft: "18px" }}>
            <button
              className="moderator-home-see-more-btn small-btn-text"
              onClick={() => onViewDetails(item)}
            >
              View Details
            </button>
          </div>
        </div>
      ))}
      <div style={{ display: "flex", justifyContent: "center", marginTop: "12px", gap: "10px" }}>
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
            fontWeight: 500
          }}
        >
          Prev
        </button>
        <span style={{
          fontWeight: 500,
          fontSize: "15px",
          color: "#7f8c8d",
          background: "#f0f0f0",
          borderRadius: "8px",
          padding: "6px 14px",
          border: "none",
          display: "flex",
          alignItems: "center"
        }}>
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
            fontWeight: 500
          }}
        >
          Next
        </button>
      </div>
    </div>
  );
};

export default RequestHistory;
