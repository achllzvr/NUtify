// Approval history list UI
import React, { useEffect, useMemo, useState } from "react";
import { getPendingUsers, updateUserVerification } from "../../api/moderator";

const facultyList = [
  { id: 1, name: 'Jayson Guia', type: 'Professor', details: 'Faculty - SACE', avatar: null },
  { id: 2, name: 'Jei Pastrana', type: 'Professor', details: 'Faculty - SACE', avatar: null },
  { id: 3, name: 'Irene Balmes', type: 'Professor', details: 'Faculty - SACE', avatar: null },
  { id: 4, name: 'Carlo Torres', type: 'Professor', details: 'Faculty - SACE', avatar: null },
  { id: 5, name: 'Archie Menisis', type: 'Professor', details: 'Faculty - SACE', avatar: null },
  { id: 6, name: 'Michael Joseph Aramil', type: 'Professor', details: 'Faculty - SACE', avatar: null }
];

const studentNames = [
  "Kier Kriztopher",
  "Achilles Vonn",
  "Sophia Marie",
  "Beatriz Gail",
  "Prinz Noel",
  "Mark Matthew",
  "Nicole Aermione",
  "Mike Roan"
];

const initialApprovalItems = [];

const ITEMS_PER_PAGE = 10;

const ApprovalHistory = ({ onVerify, searchTerm }) => {
  const [approvalItems, setApprovalItems] = useState(initialApprovalItems);
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    let mounted = true;
    (async () => {
      try {
        setLoading(true);
        setError("");
        const data = await getPendingUsers();
        // Expect { users: [...] } or array
        const list = Array.isArray(data) ? data : (data.users || []);
        const mapped = list.map(u => ({
          id: u.user_id || u.id,
          name: [u.user_fn, u.user_ln].filter(Boolean).join(' ') || u.name || '',
          type: u.user_type || u.type || 'User',
          details: u.department ? `Faculty - ${u.department}` : (u.details || ''),
          studentName: u.studentName || '',
        }));
        if (mounted) setApprovalItems(mapped);
      } catch (e) {
        if (mounted) setError(e.message || 'Failed to load pending approvals');
      } finally {
        if (mounted) setLoading(false);
      }
    })();
    return () => { mounted = false; };
  }, []);

  // Remove item
  const handleHold = async (id) => {
    // is_verified = 2 means hold
    try {
      await updateUserVerification(id, 2);
      setApprovalItems((items) => items.filter((item) => item.id !== id));
    } catch (e) {
      console.error(e);
    }
  };

  // Verify item
  const handleVerify = async (item) => {
    try {
      // is_verified = 1 means verified
      await updateUserVerification(item.id, 1);
      setApprovalItems((items) => items.filter((i) => i.id !== item.id));
      if (onVerify) onVerify(item);
    } catch (e) {
      console.error(e);
    }
  };

  // Filter items by search
  const filteredItems = useMemo(() => approvalItems.filter(
    (item) =>
      !searchTerm ||
      item.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.details.toLowerCase().includes(searchTerm.toLowerCase())
  ), [approvalItems, searchTerm]);

  const totalPages = Math.max(1, Math.ceil(filteredItems.length / ITEMS_PER_PAGE));
  const paginatedItems = filteredItems.slice(
    (page - 1) * ITEMS_PER_PAGE,
    page * ITEMS_PER_PAGE
  );

  if (loading) {
    return (
      <div style={{ textAlign: "center", color: "#888", marginTop: "40px", fontSize: '1.2em', fontWeight: 500 }}>
        Loading approvals...
      </div>
    );
  }

  if (error) {
    return (
      <div style={{ textAlign: "center", color: "#d9534f", marginTop: "40px", fontSize: '1.0em', fontWeight: 500 }}>
        {error}
      </div>
    );
  }

  if (filteredItems.length === 0) {
    return (
      <div style={{ textAlign: "center", color: "#888", marginTop: "40px", fontSize: '1.2em', fontWeight: 500 }}>
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
                style={{ fontSize: "1.6em", color: "#424A57" }} 
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