// Request history list UI
import React, { useEffect, useMemo, useState } from "react";
import { getModeratorRequests } from "../../api/moderator";

// Format date as "Month Day, Year • hh:mm am/pm"
const formatDateWithTime = (dateStr) => {
  // Accepts "July 29, 2025 09:00"
  const d = new Date(dateStr);
  if (isNaN(d.getTime())) return dateStr;
  const datePart = d.toLocaleString("en-US", { month: "long", day: "numeric", year: "numeric" });
  let hours = d.getHours();
  let minutes = d.getMinutes();
  let ampm = hours >= 12 ? "pm" : "am";
  hours = hours % 12;
  hours = hours === 0 ? 12 : hours;
  const timePart = `${hours.toString().padStart(2, "0")}:${minutes.toString().padStart(2, "0")} ${ampm}`;
  return `${datePart} • ${timePart}`;
};

const facultyList = [
  { id: 1, name: 'Prof. Alex Carter', avatar: null },
  { id: 2, name: 'Prof. Sam Rivers', avatar: null },
  { id: 3, name: 'Prof. Morgan Lee', avatar: null },
  { id: 4, name: 'Prof. Charlie Lane', avatar: null },
  { id: 5, name: 'Prof. Taylor Brooks', avatar: null },
  { id: 6, name: 'Prof. Avery West', avatar: null }
];

const studentNames = [
  "Stud. Jordan Smith",
  "Stud. Morgan Fox",
  "Stud. Taylor Brooks",
  "Stud. Avery West",
  "Stud. Charlie Lane"
];

// Placeholder removed; will fetch from backend
export const requestHistoryItems = [];

const ITEMS_PER_PAGE = 10;

const RequestHistory = ({ onViewDetails, searchTerm, moderatorId }) => {
  const [page, setPage] = useState(1);
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    let mounted = true;
    (async () => {
      try {
        setLoading(true);
        setError("");
  const data = await getModeratorRequests();
        // Expecting shape { error:false, requests:[...] } or a plain array
        const list = Array.isArray(data) ? data : (data.requests || []);
        // Map to UI shape
        const mapped = list.map((r) => ({
          id: r.appointment_id || r.id || Math.random(),
          name: r.teacher_name || r.faculty_name || r.teacher || r.name || "",
          studentName: r.student_name || r.student || r.studentName || "",
          status: (r.status || "pending").toLowerCase(),
          time: r.appointment_date || r.time || r.created_at || "",
          reason: r.appointment_reason || r.reason || "",
        }));
        if (mounted) setItems(mapped);
      } catch (e) {
        if (mounted) setError(e.message || "Failed to load requests");
      } finally {
        if (mounted) setLoading(false);
      }
    })();
    return () => { mounted = false; };
  }, [moderatorId]);

  // Filter by search
  const filteredRequests = useMemo(() => (items || []).filter(
    (item) =>
      !searchTerm ||
      (item.name &&
        item.name.toLowerCase().includes(searchTerm.toLowerCase())) ||
      (item.studentName &&
        item.studentName.toLowerCase().includes(searchTerm.toLowerCase())) ||
      (item.reason &&
    item.reason.toLowerCase().includes(searchTerm.toLowerCase()))
  ), [items, searchTerm]);

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

  if (loading) {
    return (
      <div style={{ textAlign: 'center', color: '#888', marginTop: '40px', fontSize: '1.2em', fontWeight: 500 }}>
        Loading requests...
      </div>
    );
  }

  if (error) {
    return (
      <div style={{ textAlign: 'center', color: '#d9534f', marginTop: '40px', fontSize: '1.0em', fontWeight: 500 }}>
        {error}
      </div>
    );
  }

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
                  Timestamp: {formatDateWithTime(item.time)}
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