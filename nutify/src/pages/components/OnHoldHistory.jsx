// On hold history list UI
import React, { useEffect, useMemo, useState } from "react";
import { getAccountsOnHold, updateUserVerification } from "../../api/moderator";

const initialOnHoldItems = [];

const ITEMS_PER_PAGE = 10;

// Reuse a lightweight modal similar to ApprovalHistory
const VerifyModal = ({ open, onClose, onSubmit, user }) => {
  const [idNumber, setIdNumber] = useState(user?.idNumber || "");
  const [department, setDepartment] = useState(user?.department || "");
  const [email, setEmail] = useState(user?.email || "");
  const [checks, setChecks] = useState({ c1: false, c2: false, c3: false });

  useEffect(() => {
    if (open) {
      setIdNumber(user?.idNumber || "");
      setDepartment(user?.department || "");
      setEmail(user?.email || "");
      setChecks({ c1: false, c2: false, c3: false });
    }
  }, [open, user]);

  const valid = idNumber.trim() && department.trim() && email.trim() && checks.c1 && checks.c2 && checks.c3;
  if (!open) return null;
  return (
    <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.3)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000 }}>
      <div style={{ width: 'min(560px, 92vw)', background: '#f8f8f8', borderRadius: 16, boxShadow: '0 10px 40px rgba(0,0,0,0.2)', padding: 24 }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 }}>
          <h3 style={{ margin: 0, fontSize: 20, color: '#2c3e50', fontWeight: 700 }}>Verify Account</h3>
          <button onClick={onClose} aria-label="Close" style={{ background: 'transparent', border: 'none', fontSize: 24, cursor: 'pointer', color: '#666', lineHeight: 1 }}>×</button>
        </div>
        <div style={{ color: '#47505B', fontSize: 15, marginBottom: 10 }}>Please confirm the details for <strong style={{ color: '#2c3e50' }}>{user?.name}</strong>.</div>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: 12 }}>
          <label style={{ display: 'grid', gap: 6 }}>
            <span style={{ fontWeight: 600, color: '#47505B', fontSize: 14 }}>NU ID</span>
            <input value={idNumber} onChange={e => setIdNumber(e.target.value)} placeholder="e.g., 20XX-XXXXX" className="login-input" style={{ padding: '12px 14px', borderRadius: 10, border: '1px solid #ddd', background: '#fff', color: '#000', fontSize: 15 }} />
          </label>
          <label style={{ display: 'grid', gap: 6 }}>
            <span style={{ fontWeight: 600, color: '#47505B', fontSize: 14 }}>Department</span>
            <input value={department} onChange={e => setDepartment(e.target.value)} placeholder="e.g., SACE" className="login-input" style={{ padding: '12px 14px', borderRadius: 10, border: '1px solid #ddd', background: '#fff', color: '#000', fontSize: 15 }} />
          </label>
          <label style={{ display: 'grid', gap: 6 }}>
            <span style={{ fontWeight: 600, color: '#47505B', fontSize: 14 }}>Email</span>
            <input type="email" value={email} onChange={e => setEmail(e.target.value)} placeholder="name@students.national-u.edu.ph" className="login-input" style={{ padding: '12px 14px', borderRadius: 10, border: '1px solid #ddd', background: '#fff', color: '#000', fontSize: 15 }} />
          </label>
        </div>
        <div style={{ marginTop: 14, display: 'grid', gap: 10, color: '#47505B' }}>
          <label style={{ display: 'flex', gap: 10, alignItems: 'center' }}>
            <input type="checkbox" checked={checks.c1} onChange={e => setChecks({ ...checks, c1: e.target.checked })} style={{ accentColor: '#3B82F6', width: 16, height: 16 }} />
            <span style={{ fontSize: 14 }}>I have double-checked the NU ID matches the user's record.</span>
          </label>
          <label style={{ display: 'flex', gap: 10, alignItems: 'center' }}>
            <input type="checkbox" checked={checks.c2} onChange={e => setChecks({ ...checks, c2: e.target.checked })} style={{ accentColor: '#3B82F6', width: 16, height: 16 }} />
            <span style={{ fontSize: 14 }}>The department entered is accurate and up to date.</span>
          </label>
          <label style={{ display: 'flex', gap: 10, alignItems: 'center' }}>
            <input type="checkbox" checked={checks.c3} onChange={e => setChecks({ ...checks, c3: e.target.checked })} style={{ accentColor: '#3B82F6', width: 16, height: 16 }} />
            <span style={{ fontSize: 14 }}>The email belongs to this user and has been verified.</span>
          </label>
        </div>
        <div style={{ marginTop: 18, display: 'flex', justifyContent: 'center' }}>
          <button disabled={!valid} onClick={() => onSubmit({ id_number: idNumber.trim(), department: department.trim(), email: email.trim() })} className="moderator-home-notify-btn verify" style={{ padding: '10px 18px', borderRadius: 12, border: 'none', fontSize: 15, fontWeight: 600, opacity: valid ? 1 : 0.6, cursor: valid ? 'pointer' : 'not-allowed' }}>Verify</button>
        </div>
      </div>
    </div>
  );
};

const OnHoldHistory = ({ onVerify, searchTerm }) => {
  const [onHoldItems, setOnHoldItems] = useState(initialOnHoldItems);
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [modalOpen, setModalOpen] = useState(false);
  const [selected, setSelected] = useState(null);

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

  const handleOpenVerify = (item) => {
    setSelected(item);
    setModalOpen(true);
  };

  const handleSubmitVerify = async (extra) => {
    if (!selected) return;
    try {
      await updateUserVerification(selected.id, 1, extra);
      setOnHoldItems((items) => items.filter((i) => i.id !== selected.id));
      if (onVerify) onVerify(selected);
    } catch (e) {
      setError(e.message || 'Failed to verify account');
    } finally {
      setModalOpen(false);
      setSelected(null);
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
                onClick={() => handleOpenVerify(item)}
              >
                Verify
              </button>
            </div>
          </div>
        ))}
      </div>
      <VerifyModal
        open={modalOpen}
        onClose={() => { setModalOpen(false); setSelected(null); }}
        onSubmit={handleSubmitVerify}
        user={selected}
      />
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