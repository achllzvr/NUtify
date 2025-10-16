import React, { useEffect, useMemo, useState } from 'react';
import { apiPost } from '../api/http';
import { getUserStatus, getUserStatuses } from '../api/moderator';

// We'll fetch teachers from backend; status kept 'offline' to gray indicators for now
const initialFaculty = [];

const FACULTY_PER_PAGE = 10;

const FacultyList = ({ mainSearch, facultyStatusFilter, setFacultyStatusFilter, onFacultyClick }) => {
  const [page, setPage] = useState(1);
  const [items, setItems] = useState(initialFaculty);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    let mounted = true;
    (async () => {
      try {
        setLoading(true); setError('');
        // Use searchUsers; if mainSearch empty, seed with 'a' to get some results
        const q = mainSearch && mainSearch.trim() ? mainSearch.trim() : 'a';
  const data = await apiPost('findFacultyDirectory', { q });
        const list = Array.isArray(data) ? data : (data.results || []);
        const mapped = list.map(u => ({
          id: u.user_id || u.id,
          name: [u.user_fn, u.user_ln].filter(Boolean).join(' ') || u.name || '',
          department: u.department ? `Faculty - ${u.department}` : (u.department_label || 'Faculty'),
          status: (u.status || u.user_status || 'offline').toString().toLowerCase(),
          avatar: null,
        }));

        // Try batch status fetch first for performance
        let withStatus = mapped;
        try {
          const ids = mapped.map(m => m.id).filter(Boolean);
          if (ids.length) {
            const resp = await getUserStatuses(ids);
            // Normalize response into a map { id: status }
            let map = {};
            if (resp) {
              if (Array.isArray(resp.statuses)) {
                resp.statuses.forEach(s => { if (s && s.user_id != null) map[s.user_id] = s.status || s.user_status; });
              } else if (resp.statuses && typeof resp.statuses === 'object') {
                map = resp.statuses;
              } else if (typeof resp === 'object') {
                map = resp; // accept a plain map
              }
            }
            const normStatus = (raw) => {
              const s = (raw || '').toString().trim().toLowerCase().replace(/[_\s]+/g, '-');
              if (s === 'online') return 'online';
              if (s === 'busy' || s === 'away' || s === 'engaged') return 'busy';
              if (s === 'in-class' || s === 'class') return 'in-class';
              if (s === 'in-meeting' || s === 'meeting') return 'in-meeting';
              return 'offline';
            };
            withStatus = mapped.map(f => ({ ...f, status: normStatus(map[f.id] ?? f.status) }));
          }
        } catch {
          // Fallback to per-user fetch if batch is unavailable
          withStatus = await Promise.all(mapped.map(async (f) => {
            try {
              const r = await getUserStatus(f.id);
              const raw = (r && (r.status || r.user_status)) || f.status;
              const s = (raw || '').toString().trim().toLowerCase().replace(/[_\s]+/g, '-');
              if (s === 'online') return { ...f, status: 'online' };
              if (s === 'busy' || s === 'away' || s === 'engaged') return { ...f, status: 'busy' };
              if (s === 'in-class' || s === 'class') return { ...f, status: 'in-class' };
              if (s === 'in-meeting' || s === 'meeting') return { ...f, status: 'in-meeting' };
              return { ...f, status: 'offline' };
            } catch {
              return f;
            }
          }));
        }

        if (mounted) setItems(withStatus);
      } catch (e) {
        if (mounted) setError(e.message || 'Failed to load faculty list');
      } finally {
        if (mounted) setLoading(false);
      }
    })();
    return () => { mounted = false; };
  }, [mainSearch]);

  // Normalize various backend status strings to online|busy|offline
  const normalizeStatus = (raw) => {
    const s = (raw || '').toString().trim().toLowerCase().replace(/[_\s]+/g, '-');
    if (s === 'online') return 'online';
    if (s === 'busy' || s === 'away' || s === 'engaged') return 'busy';
    if (s === 'in-class' || s === 'class') return 'in-class';
    if (s === 'in-meeting' || s === 'meeting') return 'in-meeting';
    return 'offline';
  };

  // Poll statuses every 5 seconds for current faculty list
  const itemIds = useMemo(() => items.map(i => i.id).join(','), [items]);
  useEffect(() => {
    if (!items || items.length === 0) return; // nothing to poll
    let mounted = true;
    const ids = items.map(i => i.id).filter(Boolean);
    const tick = async () => {
      try {
        if (!ids.length) return;
        const resp = await getUserStatuses(ids);
        // Build a map of id -> status from possible response shapes
        let map = {};
        if (resp) {
          if (Array.isArray(resp.statuses)) {
            resp.statuses.forEach(s => { if (s && s.user_id != null) map[s.user_id] = s.status || s.user_status; });
          } else if (resp.statuses && typeof resp.statuses === 'object') {
            map = resp.statuses;
          } else if (typeof resp === 'object') {
            map = resp;
          }
        }
        if (!mounted) return;
        setItems(prev => prev.map(f => ({ ...f, status: normalizeStatus(map[f.id] ?? f.status) })));
      } catch {
        // ignore polling errors; next tick will retry
      }
    };
    // Prime immediately then poll
    tick();
    const handle = setInterval(tick, 5000);
    return () => {
      mounted = false;
      clearInterval(handle);
    };
  }, [itemIds, items]);

  const filteredFacultyList = useMemo(() => items.filter(f =>
    (facultyStatusFilter === 'all' || f.status === facultyStatusFilter) &&
    (f.name.toLowerCase().includes(mainSearch.toLowerCase()) ||
      f.department.toLowerCase().includes(mainSearch.toLowerCase()))
  ), [items, facultyStatusFilter, mainSearch]);

  const totalPages = Math.max(1, Math.ceil(filteredFacultyList.length / FACULTY_PER_PAGE));
  const paginatedFaculty = filteredFacultyList.slice(
    (page - 1) * FACULTY_PER_PAGE,
    page * FACULTY_PER_PAGE
  );

  const handlePrev = () => setPage(prev => Math.max(prev - 1, 1));
  const handleNext = () => setPage(prev => Math.min(prev + 1, totalPages));

  return (
    <div
      className="moderator-home-faculty-section"
      style={{
        height: '780px', // fixed height
        display: 'flex',
        flexDirection: 'column'
      }}
    >
      <div className="moderator-home-section-header" style={{ justifyContent: 'space-between', alignItems: 'center' }}>
        <h2 style={{ margin: 0 }}>All Faculty List</h2>
        <select
          id="faculty-status-filter"
          value={facultyStatusFilter}
          onChange={e => setFacultyStatusFilter(e.target.value)}
          className="moderator-home-faculty-filter-dropdown"
        >
          <option value="all">All</option>
          <option value="online">Online</option>
          <option value="offline">Offline</option>
        </select>
      </div>
      <div
        className="moderator-home-faculty-list"
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
        {loading ? (
          <div style={{ textAlign: 'center', color: '#888', marginTop: '40px', fontSize: '1.2em', fontWeight: 500 }}>
            Loading faculty...
          </div>
        ) : error ? (
          <div style={{ textAlign: 'center', color: '#d9534f', marginTop: '40px', fontSize: '1.0em', fontWeight: 500 }}>
            {error}
          </div>
        ) : paginatedFaculty.length === 0 ? (
          <div style={{ textAlign: 'center', color: '#888', marginTop: '40px', fontSize: '1.2em', fontWeight: 500 }}>
            No faculty users found.
          </div>
        ) : (
          paginatedFaculty.map(faculty => (
            <div
              key={faculty.id}
              className="moderator-home-faculty-item"
              onClick={() => onFacultyClick && onFacultyClick(faculty)}
              role={onFacultyClick ? 'button' : undefined}
              tabIndex={onFacultyClick ? 0 : undefined}
              onKeyDown={e => {
                if (!onFacultyClick) return;
                if (e.key === 'Enter' || e.key === ' ') {
                  e.preventDefault();
                  onFacultyClick(faculty);
                }
              }}
            >
              <div className="moderator-home-faculty-avatar">
                <div
                  className="moderator-home-avatar-img"
                  style={{
                    width: '40px',
                    height: '40px',
                    borderRadius: '50%',
                    backgroundColor: '#e0e0e0',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: '16px',
                    fontWeight: 'bold',
                    color: '#666'
                  }}
                >
                  {faculty.name.split(' ').map(n => n[0]).join('').substring(0, 2)}
                </div>
              </div>
              <div className="moderator-home-faculty-info">
                <div className="moderator-home-faculty-name">{faculty.name}</div>
                <div className="moderator-home-faculty-department">{faculty.department}</div>
              </div>
              <span
                className={`status-badge ${faculty.status}`}
                aria-label={`Status: ${faculty.status}`}
              >
                {faculty.status === 'online' && 'Online'}
                {faculty.status === 'busy' && 'Busy'}
                {faculty.status === 'in-class' && 'In class'}
                {faculty.status === 'in-meeting' && 'In meeting'}
                {faculty.status === 'offline' && 'Offline'}
              </span>
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
    </div>
  );
};

export default FacultyList;