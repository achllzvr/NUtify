// Request history list UI
import React, { useState } from "react";

// Format date as MM/DD/YYYY
const formatDateMMDDYYYY = (dateStr) => {
  // Accepts "July 29, 2025 09:00"
  const [datePart, timePart] = dateStr.split(' ');
  let d = new Date(datePart.replace(',', '') + ' ' + timePart);
  return isNaN(d.getTime())
    ? dateStr
    : `${d.toLocaleString("en-US", { month: "long", day: "numeric", year: "numeric" })}`;
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
  "Prinz Noel"
];

// Example request items
export const requestHistoryItems = [
  {
    id: 101,
    name: facultyList[0].name,
    studentName: studentNames[0],
    status: "pending",
    time: "July 29, 2025 09:00",
    reason: "Request for thesis consultation",
  },
  {
    id: 102,
    name: facultyList[1].name,
    studentName: studentNames[1],
    status: "pending",
    time: "July 29, 2025 10:00",
    reason: "Request for grade review",
  },
  {
    id: 103,
    name: facultyList[2].name,
    studentName: studentNames[2],
    status: "pending",
    time: "July 29, 2025 11:00",
    reason: "Request for project feedback",
  },
  {
    id: 104,
    name: facultyList[3].name,
    studentName: studentNames[3],
    status: "pending",
    time: "July 29, 2025 13:00",
    reason: "Request for consultation slot",
  },
  {
    id: 105,
    name: facultyList[4].name,
    studentName: studentNames[4],
    status: "pending",
    time: "July 29, 2025 14:00",
    reason: "Request for extension on assignment",
  },
];

const ITEMS_PER_PAGE = 10;

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

  const totalPages = Math.max(1, Math.ceil(filteredRequests.length / ITEMS_PER_PAGE));
  const paginatedRequests = filteredRequests.slice(
    (page - 1) * ITEMS_PER_PAGE,
    page * ITEMS_PER_PAGE
  );

  const handlePrev = () => setPage(prev => Math.max(prev - 1, 1));
  const handleNext = () => setPage(prev => Math.min(prev + 1, totalPages));

  // Helper to truncate reason to max 6 words
  const truncateReason = (reason) => {
    if (!reason) return "";
    const words = reason.split(" ");
    if (words.length <= 6) return reason;
    return words.slice(0, 6).join(" ") + "...";
  };

  return (
    <>
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
        {paginatedRequests.length === 0 ? (
          <div style={{ textAlign: 'center', color: '#888', marginTop: '40px', fontSize: '1.2em', fontWeight: 500 }}>
            No requests for today.
          </div>
        ) : (
          paginatedRequests.map((item) => (
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
                  Reason: {truncateReason(item.reason)}
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
          ))
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

export default RequestHistory;