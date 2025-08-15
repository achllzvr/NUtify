// Approval history list UI
import React, { useState } from "react";

// Example approval items
const initialApprovalItems = [
  {
    id: 1,
    name: "Dr. Samantha Cruz",
    type: "Professor",
    details: "Faculty - SACE",
  },
  { id: 2, name: "Miguel Tan", type: "Student", details: "" },
  {
    id: 3,
    name: "Prof. Liza Mendoza",
    type: "Professor",
    details: "Faculty - SAHS",
  },
  {
    id: 4,
    name: "Dr. Carlo Reyes",
    type: "Professor",
    details: "Faculty - SACE",
  },
  { id: 5, name: "Anna Santos", type: "Student", details: "" },
  {
    id: 6, name: "Prof. Maria Lopez", type: "Professor", details: "Faculty - SACE",
  },
  { id: 7, name: "James Lim", type: "Student", details: "" },
  {
    id: 8,
    name: "Prof. Daniel Cruz",
    type: "Professor",
    details: "Faculty - SAHS",
  },
];

const ITEMS_PER_PAGE = 10;

const ApprovalHistory = ({ onVerify, searchTerm }) => {
  const [approvalItems, setApprovalItems] = useState(initialApprovalItems);
  const [page, setPage] = useState(1);

  // Remove item
  const handleHold = (id) => {
    setApprovalItems((items) => items.filter((item) => item.id !== id));
  };

  // Verify item
  const handleVerify = (item) => {
    setApprovalItems((items) => items.filter((i) => i.id !== item.id));
    if (onVerify) onVerify(item);
  };

  // Filter items by search
  const filteredItems = approvalItems.filter(
    (item) =>
      !searchTerm ||
      item.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.details.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const totalPages = Math.max(1, Math.ceil(filteredItems.length / ITEMS_PER_PAGE));
  const paginatedItems = filteredItems.slice(
    (page - 1) * ITEMS_PER_PAGE,
    page * ITEMS_PER_PAGE
  );

  if (filteredItems.length === 0) {
    return (
      <div style={{ textAlign: "center", color: "#888", marginTop: "40px" }}>
        No approvals pending.
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
        {paginatedItems.map((item) => (
          <div
            key={item.id}
            className="moderator-history-item"
            style={{
              minHeight: 100,
              marginBottom: 24,
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
                style={{ fontSize: "1.25em", color: "#424A57" }} // slightly bigger name
              >
                {item.name}
              </div>
            </div>
            {/* Action buttons - moved to right */}
            <div style={{ display: "flex", gap: "12px", marginLeft: "18px" }}>
              <button
                className="moderator-history-see-more-btn gray hold"
                onClick={() => handleHold(item.id)}
              >
                Hold
              </button>
              <button
                className="moderator-history-see-more-btn verify"
                onClick={() => handleVerify(item)}
              >
                Verify
              </button>
            </div>
          </div>
        ))}
      </div>
      <div style={{ display: 'flex', justifyContent: 'center', marginTop: '12px', gap: '10px' }}>
        <button
          onClick={() => setPage(prev => Math.max(prev - 1, 1))}
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
          onClick={() => setPage(prev => Math.min(prev + 1, totalPages))}
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

export default ApprovalHistory;