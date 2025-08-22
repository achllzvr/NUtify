// On hold history list UI
import React, { useEffect, useMemo, useState } from "react";
import { getAccountsOnHold, updateUserVerification } from "../../api/moderator";

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

const initialOnHoldItems = [];

const ITEMS_PER_PAGE = 10;

const OnHoldHistory = ({ onVerify, searchTerm }) => {
  const [onHoldItems, setOnHoldItems] = useState(initialOnHoldItems);
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    let mounted = true;
    (async () => {
      try {
        setLoading(true);
        setError("");
        const data = await getAccountsOnHold();
        // Expect { users: [...] } or array
        const list = Array.isArray(data) ? data : (data.users || []);
        const mapped = list.map((u) => ({
          id: u.user_id || u.id,
          name: [u.user_fn, u.user_ln].filter(Boolean).join(' ') || u.name || '',
          type: u.user_type || u.type || 'User',
          // Newly fetched fields
          idNumber: u.id_number || u.student_id || u.employee_id || '',
          email: u.email || u.user_email || '',
          department: u.department || u.dept || u.department_name || (u.user_dept && (u.user_dept.department || u.user_dept.dept || u.user_dept.name)) || '',
        }));
        if (mounted) setOnHoldItems(mapped);
      } catch (e) {
        if (mounted) setError(e.message || 'Failed to load on-hold accounts');
      } finally {
        if (mounted) setLoading(false);
      }
    })();
    return () => { mounted = false; };
  }, []);

  const handleVerify = async (item) => {
    try {
      // is_verified = 1 means verified
      await updateUserVerification(item.id, 1);
      setOnHoldItems((items) => items.filter((i) => i.id !== item.id));
      if (onVerify) onVerify(item);
    } catch (e) {
      setError(e.message || 'Failed to verify account');
    }
  };

  const filteredItems = useMemo(() => onHoldItems.filter(
    (item) => {
      if (!searchTerm) return true;
      const q = searchTerm.toLowerCase();
      return (
        (item.name || '').toLowerCase().includes(q) ||
        (item.idNumber || '').toLowerCase().includes(q) ||
        (item.email || '').toLowerCase().includes(q) ||
        (item.department || '').toLowerCase().includes(q) ||
        (item.type || '').toLowerCase().includes(q)
      );
    }
  ), [onHoldItems, searchTerm]);

  const totalPages = Math.max(1, Math.ceil(filteredItems.length / ITEMS_PER_PAGE));
  const paginatedItems = filteredItems.slice(
    (page - 1) * ITEMS_PER_PAGE,
    page * ITEMS_PER_PAGE
  );

  if (loading) {
    return (
      <div style={{ textAlign: "center", color: "#888", marginTop: "40px", fontSize: '1.2em', fontWeight: 500 }}>
        Loading on-hold accounts...
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
        Nothing on hold.
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
              <div style={{ marginTop: 6, color: '#65727F', fontSize: '0.95em', lineHeight: 1.5 }}>
                <div><strong style={{ color: '#47505B' }}>NU ID:</strong> {item.idNumber || '—'}</div>
                <div>
                  <strong style={{ color: '#47505B' }}>Email:</strong>{' '}
                  {item.email ? (
                    <a href={`mailto:${item.email}`} style={{ color: '#3B82F6', textDecoration: 'none' }}>{item.email}</a>
                  ) : '—'}
                </div>
                <div><strong style={{ color: '#47505B' }}>Department:</strong> {item.department || '—'}</div>
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

export default OnHoldHistory;