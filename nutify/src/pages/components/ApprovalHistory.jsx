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

const ApprovalHistory = ({ onVerify, searchTerm }) => {
  const [approvalItems, setApprovalItems] = useState(initialApprovalItems);

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

  if (filteredItems.length === 0) {
    return (
      <div style={{ textAlign: "center", color: "#888", marginTop: "40px" }}>
        No approvals pending.
      </div>
    );
  }

  return (
    <div>
      {filteredItems.map((item) => (
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
  );
};

export default ApprovalHistory;