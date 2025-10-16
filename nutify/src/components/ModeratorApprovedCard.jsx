import React, { useState, useMemo, useEffect } from 'react';
import { getApprovedUsers, toggleUserHold } from '../api/moderator';

const ITEMS_PER_PAGE = 10;

// Tabs: Student, Teacher, Moderator
const TABS = ['Student', 'Teacher', 'Moderator'];

const ModeratorApprovedHistory = ({ searchValue }) => {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [holdMap, setHoldMap] = useState({}); // user_id -> boolean (true=Hold)

  // Tabs and filter panel state
  const [activeTab, setActiveTab] = useState('Student');
  const [filtersOpen, setFiltersOpen] = useState(false);
  const [verifiedFilter, setVerifiedFilter] = useState('all'); // 'all' | 'unhold' | 'hold'
  const [deptFilter, setDeptFilter] = useState(''); // department string or '' for all

  // Fetch approved users from backend
  useEffect(() => {
    let mounted = true;
    (async () => {
      try {
  console.log('[Approved] Fetch start');
        setLoading(true);
        setError('');
        const resp = await getApprovedUsers();
  console.log('[Approved] API response:', resp);
  const list = Array.isArray(resp) ? resp : (resp.users || resp.data || []);
  console.log('[Approved] Parsed list length:', Array.isArray(list) ? list.length : 'n/a');
        const mapped = list.map(u => {
          // Normalize user type to label (Teacher instead of Faculty)
          const rawType = (u.user_type_id ?? u.user_type ?? u.type ?? '').toString();
          let accountType = '';
          const numType = Number(rawType);
          if (!Number.isNaN(numType) && rawType !== '') {
            accountType = numType === 1 ? 'Student' : numType === 2 ? 'Teacher' : numType === 3 ? 'Moderator' : '';
          } else if (rawType) {
            const lt = rawType.toLowerCase();
            accountType = lt.includes('student') ? 'Student' : (lt.includes('teacher') || lt.includes('faculty')) ? 'Teacher' : (lt.includes('moderator') || lt.includes('staff')) ? 'Moderator' : '';
          }

          // Name fallbacks
          const name = [u.user_fn ?? u.first_name ?? u.firstname, u.user_ln ?? u.last_name ?? u.lastname]
            .filter(Boolean)
            .join(' ') || u.name || '';

          // Verification mapping: 0 = pending approval, 1 = verified, 2 = on hold
          const isVerified = u.is_verified ?? u.verified ?? u.status_code;
          const onHold = Number(isVerified) === 2 || (typeof isVerified === 'string' && isVerified.toLowerCase() === 'hold') || !!(u.hold || u.on_hold || u.is_hold);

          return {
            id: u.user_id || u.id,
            name,
            accountType,
            department: u.department || u.dept || u.department_name || u.college || '',
            yearLevel: u.year_level || u.yearLevel || u.year || '',
            academicYear: u.academic_year || u.academicYear || u.acad_year || '',
            avatar: u.avatar || u.photo_url || '',
            onHold,
            // Preserve 0 explicitly (Number(0) || ... would incorrectly coerce to default)
            // If isVerified is undefined/null/NaN, default using onHold flag; else use the numeric value
            isVerified: (() => {
              const n = Number(isVerified);
              return Number.isNaN(n) || isVerified === undefined || isVerified === null
                ? (onHold ? 2 : 1)
                : n;
            })()
          };
        }).filter(u => u.id);
        console.log('[Approved] Mapped items length:', mapped.length);
        if (mounted) {
          setItems(mapped);
          const initialHold = {};
          mapped.forEach(u => { initialHold[u.id] = !!u.onHold; });
          setHoldMap(initialHold);
          console.log('[Approved] State set: items:', mapped.length, 'holdMap keys:', Object.keys(initialHold).length);
        }
      } catch (e) {
        console.error('[Approved] Fetch error:', e);
        if (mounted) setError(e.message || 'Failed to load approved users');
      } finally {
        if (mounted) {
          setLoading(false);
          console.log('[Approved] Fetch end');
        }
      }
    })();
    return () => { mounted = false; };
  }, []);

  // Derived departments for filter options
  const deptOptions = useMemo(() => {
    const set = new Set();
    items.forEach(it => { if (it.department) set.add(it.department); });
    return Array.from(set).sort();
  }, [items]);

  // Pagination state
  const [page, setPage] = useState(1);

  // If searchValue matches a person, optionally switch to their tab
  useEffect(() => {
    if (searchValue) {
      const match = items.find(item =>
        (item.name || '').toLowerCase().includes(searchValue.toLowerCase())
      );
      if (match && match.accountType && TABS.includes(match.accountType)) {
        setActiveTab(match.accountType);
        setPage(1);
      }
    }
  }, [searchValue, items]);

  // Filtered items based on tab + filters + search
  const filteredItems = useMemo(() => {
    const q = (searchValue || '').trim().toLowerCase();
    return items.filter(item => {
      // Tab filter by account type
      if (item.accountType !== activeTab) return false;
      // Search by name
      if (q && !(item.name || '').toLowerCase().includes(q)) return false;
      // Verified filter - check the current hold status from holdMap
      const currentlyOnHold = holdMap[item.id];
      if (verifiedFilter === 'unhold' && currentlyOnHold) return false;
      if (verifiedFilter === 'hold' && !currentlyOnHold) return false;
      // Department filter
      if (deptFilter && item.department !== deptFilter) return false;
      return true;
    });
  }, [items, activeTab, verifiedFilter, deptFilter, searchValue, holdMap]);

  const paginatedItems = useMemo(() => filteredItems.slice(
    (page - 1) * ITEMS_PER_PAGE,
    page * ITEMS_PER_PAGE
  ), [filteredItems, page]);

  const totalPages = Math.max(1, Math.ceil(filteredItems.length / ITEMS_PER_PAGE));

  const handleToggleHold = async (user) => {
    const current = !!holdMap[user.id];
    const next = !current;
    console.log('[Approved] Toggle hold click:', { userId: user.id, current, next });
    setHoldMap(m => ({ ...m, [user.id]: next }));
    try {
      await toggleUserHold(user.id, next);
      console.log('[Approved] Toggle hold success:', { userId: user.id, hold: next });
      // reflect change in isVerified as well
      setItems(list => list.map(it => it.id === user.id ? { ...it, onHold: next, isVerified: next ? 2 : 1 } : it));
    } catch (e) {
      setHoldMap(m => ({ ...m, [user.id]: current }));
      console.error('[Approved] Toggle hold error:', e);
      setError(e.message || 'Failed to update hold');
    }
  };

  return (
    <div className="moderator-history-main-content">
      <style>{`
        .tabs { display: flex; gap: 10px; margin: 8px 0 18px; }
        .tab { padding: 10px 16px; border-radius: 12px; cursor: pointer; font-weight: 700; color: #424A57; background: #f0f0f0; box-shadow: 8px 8px 20px #e0e0e0, -8px -8px 20px #fff; border: none; }
        .tab.active { background: #ffd36b; color: #7a5c00; }
        .filters-bar { display: flex; align-items: center; justify-content: space-between; gap: 12px; margin-bottom: 12px; flex-wrap: wrap; }
        .filter-btn { font-weight: 700; border: none; border-radius: 12px; padding: 8px 14px; background: #f0f0f0; color: #424A57; box-shadow: 6px 6px 16px #e0e0e0, -6px -6px 16px #fff; cursor: pointer; }
        .indicator { display: inline-flex; align-items: center; gap: 8px; background: #f7f7f7; padding: 8px 12px; border-radius: 10px; color: #7f8c8d; box-shadow: 4px 4px 8px #e0e0e0, -4px -4px 8px #fff; }
        .filters-panel { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; background: #f5f5f5; padding: 12px; border-radius: 14px; box-shadow: 8px 8px 16px #e0e0e0, -8px -8px 16px #fff; margin-bottom: 10px; }
        .filters-select { border: none; border-radius: 10px; background: #fff; padding: 10px 12px; color: #424A57; box-shadow: inset 3px 3px 6px #e6e6e6, inset -3px -3px 6px #fff; }
        .moderator-history-btn { font-weight: 700; border: none; border-radius: 15px; font-size: 1rem; padding: 0.5rem 1.5rem; cursor: pointer; min-width: 120px; }
        .moderator-history-btn.primary { background: #ffd36b; color: #7a5c00; }
        .moderator-history-btn.secondary { background: #e0e0e0; color: #424a57; }
        .moderator-history-section { background: #f0f0f0; border-radius: 20px; padding: 15px 25px 25px 25px; box-shadow: 20px 20px 40px rgba(0, 0, 0, 0.1), -20px -20px 40px rgba(255, 255, 255, 0.8); transition: all 0.3s ease; height: 697px; display: flex; flex-direction: column; width: 100%; }
      `}</style>
      <div className="moderator-history-content-container">
        {/* Tabs */}
        <div className="tabs">
          {TABS.map(tab => (
            <button key={tab} className={`tab ${activeTab === tab ? 'active' : ''}`} onClick={() => { setActiveTab(tab); setPage(1); }}>
              {tab}
            </button>
          ))}
        </div>

        {/* Filters + Indicator */}
        <div className="filters-bar">
          <button className="filter-btn" onClick={() => setFiltersOpen(v => !v)}>
            {filtersOpen ? 'Hide Filters' : 'Filter'}
          </button>
          <div className="indicator">
            <span>Showing:</span>
            <strong>{verifiedFilter === 'unhold' ? 'Unhold' : verifiedFilter === 'hold' ? 'Hold' : 'All'}</strong>
            {deptFilter ? <span>• {deptFilter}</span> : null}
          </div>
        </div>

        {filtersOpen && (
          <div className="filters-panel">
            <label style={{ display: 'grid', gap: 6 }}>
              <span style={{ fontWeight: 600, color: '#47505B', fontSize: 14 }}>Status</span>
              <select className="filters-select" value={verifiedFilter} onChange={e => { setVerifiedFilter(e.target.value); setPage(1); }}>
                <option value="all">All</option>
                <option value="unhold">Can be unheld</option>
                <option value="hold">Can be on hold</option>
              </select>
            </label>
            <label style={{ display: 'grid', gap: 6 }}>
              <span style={{ fontWeight: 600, color: '#47505B', fontSize: 14 }}>Department</span>
              <select className="filters-select" value={deptFilter} onChange={e => { setDeptFilter(e.target.value); setPage(1); }}>
                <option value="">All</option>
                {deptOptions.map(d => <option key={d} value={d}>{d}</option>)}
              </select>
            </label>
          </div>
        )}

        <div className="moderator-history-left-column">
          <div className="moderator-history-section">
            <div className="moderator-history-card-list">
              {loading ? (
                <div style={{ textAlign: 'center', color: '#888', marginTop: '40px', fontSize: '1.2em', fontWeight: 500 }}>Loading approved users...</div>
              ) : error ? (
                <div style={{ textAlign: 'center', color: '#d9534f', marginTop: '40px', fontSize: '1.0em', fontWeight: 500 }}>{error}</div>
              ) : paginatedItems.length === 0 ? (
                <div style={{ textAlign: 'center', color: '#888', marginTop: '40px', fontSize: '1.2em', fontWeight: 500 }}>No approved users found.</div>
              ) : (
                paginatedItems.map(item => (
                  <div key={item.id} className="moderator-history-item">
                    <div className="moderator-history-appointment-avatar">
                      {item.avatar ? (
                        <img src={item.avatar} alt={item.name} className="moderator-history-avatar-img" />
                      ) : (
                        <div className="moderator-history-avatar-img" style={{ background: '#e0e0e0', width: '70px', height: '70px', borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 'bold', color: '#666' }}>
                          {(item.name || '').split(' ').map(n => n[0]).join('').substring(0, 2)}
                        </div>
                      )}
                    </div>
                    <div className="moderator-history-appointment-info">
                      <div className="moderator-history-appointment-name" style={{ color: '#424A57', fontSize: '1.5rem', fontWeight: 950 }}>
                        {item.name}
                      </div>
                      <div className="moderator-history-appointment-details" style={{ fontSize: '0.95rem' }}>
                        <span style={{ color: '#424A57', fontWeight: 600 }}>Account Type:</span>
                        <span style={{ color: '#757575', marginLeft: 8 }}>{item.accountType}</span>
                      </div>
                      {item.department && (
                        <div className="moderator-history-appointment-details" style={{ fontSize: '0.95rem' }}>
                          <span style={{ color: '#424A57', fontWeight: 600 }}>Department:</span>
                          <span style={{ color: '#757575', marginLeft: 8 }}>{item.department}</span>
                        </div>
                      )}
                      {item.accountType === 'Student' && (
                        <>
                          {item.yearLevel && (
                            <div className="moderator-history-appointment-details" style={{ fontSize: '0.95rem' }}>
                              <span style={{ color: '#424A57', fontWeight: 600 }}>Year Level:</span>
                              <span style={{ color: '#757575', marginLeft: 8 }}>{item.yearLevel}</span>
                            </div>
                          )}
                          {item.academicYear && (
                            <div className="moderator-history-appointment-details" style={{ fontSize: '0.95rem' }}>
                              <span style={{ color: '#424A57', fontWeight: 600 }}>Academic Year:</span>
                              <span style={{ color: '#757575', marginLeft: 8 }}>{item.academicYear}</span>
                            </div>
                          )}
                        </>
                      )}
                    </div>
                    <div style={{ display: 'flex', justifyContent: 'flex-end' }}>
                      <button onClick={() => handleToggleHold(item)} className={`moderator-history-btn ${holdMap[item.id] ? 'primary' : 'secondary'}`}>
                        {holdMap[item.id] ? 'Hold' : 'Unhold'}
                      </button>
                    </div>
                  </div>
                ))
              )}
            </div>
            <div style={{ display: 'flex', justifyContent: 'center', marginTop: '12px', gap: '10px' }}>
              <button
                onClick={() => setPage(prev => Math.max(prev - 1, 1))}
                disabled={page === 1}
                style={{ padding: '6px 14px', borderRadius: '8px', border: 'none', background: '#f0f0f0', color: '#7f8c8d', cursor: page === 1 ? 'not-allowed' : 'pointer', fontWeight: 500, boxShadow: '4px 4px 8px #e0e0e0, -4px -4px 8px #fff' }}
              >
                Prev
              </button>
              <span style={{ fontWeight: 500, fontSize: '15px', color: '#7f8c8d', background: '#f0f0f0', borderRadius: '8px', padding: '6px 14px', border: 'none', display: 'flex', alignItems: 'center', boxShadow: '4px 4px 8px #e0e0e0, -4px -4px 8px #fff' }}>
                Page {page} of {totalPages}
              </span>
              <button
                onClick={() => setPage(prev => Math.min(prev + 1, totalPages))}
                disabled={page === totalPages}
                style={{ padding: '6px 14px', borderRadius: '8px', border: 'none', background: '#f0f0f0', color: '#7f8c8d', cursor: page === totalPages ? 'not-allowed' : 'pointer', fontWeight: 500, boxShadow: '4px 4px 8px #e0e0e0, -4px -4px 8px #fff' }}
              >
                Next
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ModeratorApprovedHistory;
