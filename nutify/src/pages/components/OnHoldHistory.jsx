// On hold history list UI
import React, { useState } from "react";

// Example on hold items
const initialOnHoldItems = [
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
    id: 6,
    name: "Prof. Maria Lopez",
    type: "Professor",
    details: "Faculty - SACE",
  },
  { id: 7, name: "James Lim", type: "Student", details: "" },
  {
    id: 8,
    name: "Prof. Daniel Cruz",
    type: "Professor",
    details: "Faculty - SAHS",
  },
];

const OnHoldHistory = ({ onVerify, searchTerm }) => {
  const [onHoldItems, setOnHoldItems] = useState(initialOnHoldItems);

  const handleVerify = (item) => {
    setOnHoldItems((items) => items.filter((i) => i.id !== item.id));
    if (onVerify) onVerify(item);
  };

  const filteredItems = onHoldItems.filter(
    (item) =>
      !searchTerm ||
      item.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.details.toLowerCase().includes(searchTerm.toLowerCase())
  );

  if (filteredItems.length === 0) {
    return (
      <div style={{ textAlign: "center", color: "#888", marginTop: "40px" }}>
        No on hold items.
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
              style={{ fontSize: "1.25em", color: "#424A57" }}
            >
              {item.name}
            </div>
          </div>
          {/* Action button - moved to right */}
          <div style={{ display: "flex", gap: "12px", marginLeft: "18px" }}>
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

export default OnHoldHistory;