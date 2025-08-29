import React, { useState, useMemo } from 'react';

// Dummy data for approval history cards
const approvedHistory = [
  {
    id: 1,
    name: 'Second Test',
    accountType: 'Faculty',
    department: 'SAHS',
    yearLevel: '2',
    academicYear: '2024-2025',
    avatar: '',
    status: 'approved'
  }
];

const ITEMS_PER_PAGE = 10;

const holdStatuses = ['Hold', 'Unhold'];

const ModeratorApprovedHistory = () => {
  const [holdStatus, setHoldStatus] = useState(
    approvedHistory.map(() => true) // true = Hold, false = Unhold
  );

  const handleToggleHold = idx => {
    setHoldStatus(prev =>
      prev.map((status, i) => (i === idx ? !status : status))
    );
  };

  // Dropdown state
  const [filters, setFilters] = useState({
    accountType: '',
    department: '',
    yearLevel: '',
    academicYear: '',
    holdStatus: ''
  });

  // Dropdown options (dummy, replace with real if needed)
  const accountTypes = ['Faculty', 'Student', 'Staff'];
  const departments = ['SAHS', 'SACE', 'SABM', 'SCS'];
  const yearLevels = ['1', '2', '3', '4'];
  const academicYears = ['2023-2024', '2024-2025', '2025-2026'];

  // Pagination state
  const [page, setPage] = useState(1);

  // Filtered/paginated items (if you add filters, apply them here)
  const paginatedItems = useMemo(() => {
    // No filters applied, just paginate
    return approvedHistory.slice(
      (page - 1) * ITEMS_PER_PAGE,
      page * ITEMS_PER_PAGE
    );
  }, [page]);

  const totalPages = Math.max(1, Math.ceil(approvedHistory.length / ITEMS_PER_PAGE));

  return (
    <div className="moderator-history-main-content">
      {/* Neumorphic filter row */}
      <style>
        {`
          .mod-approved-filters-row {
            display: flex;
            gap: 18px;
            margin-bottom: 2.2em;
            flex-wrap: wrap;
          }
          .mod-approved-filter-group {
            display: flex;
            flex-direction: column;
            min-width: 160px;
            flex: 1 1 160px;
            position: relative;
          }
          .mod-approved-filter-select {
            border: none;
            border-radius: 15px;
            background: #f0f0f0;
            box-shadow: 8px 8px 20px #e0e0e0, -8px -8px 20px #fff;
            padding: 12px 38px 12px 18px;
            font-size: 1em;
            color: #424A57;
            outline: none;
            transition: box-shadow 0.2s;
            appearance: none;
            cursor: pointer;
            width: 100%;
          }
          .mod-approved-filter-select:focus {
            box-shadow: 4px 4px 12px #e0e0e0, -4px -4px 12px #fff, 0 0 0 0px #ffd36b;
          }
          .mod-approved-filter-arrow {
            position: absolute;
            right: 16px;
            top: 50%;
            transform: translateY(-50%);
            pointer-events: none;
            width: 18px;
            height: 18px;
            fill: #b0b0b0;
          }
          .moderator-history-btn {
            font-weight: 700;
            border: none;
            border-radius: 15px;
            font-size: 1rem;
            padding: 0.5rem 1.5rem;
            cursor: pointer;
            min-width: 120px;
          }
          .moderator-history-btn.primary {
            background: #ffd36b;
            color: #7a5c00;
          }
          .moderator-history-btn.primary:active {
            box-shadow: inset 10px 10px 22px rgba(44,62,80,0.22), inset -10px -10px 22px rgba(255,255,255,0);
            background: #ffd36b;
            filter: none;
          }
          .moderator-history-btn.secondary {
            background: #e0e0e0;
            color: #424a57;
          }
          .moderator-history-btn.secondary:active {
            background: #e0e0e0;
            box-shadow: inset 20px 20px 60px #cccccc, inset -20px -20px 60px #fff;
          }
          .moderator-history-section {
            background: #f0f0f0;
            border-radius: 20px;
            padding: 15px 25px 25px 25px;
            box-shadow: 20px 20px 40px rgba(0, 0, 0, 0.1),
              -20px -20px 40px rgba(255, 255, 255, 0.8);
            transition: all 0.3s ease;
            height: 697px; /* lowered from 780px */
            display: flex;
            flex-direction: column;
            width: 100%;
          }
          @media (max-width: 768px) {
            .mod-approved-filters-row {
              flex-direction: column;
              gap: 12px;
            }
            .mod-approved-filter-group {
              min-width: 0;
              width: 100%;
              flex: unset;
            }
          }
        `}
      </style>
      <div className="moderator-history-content-container">
        {/* Filter dropdowns */}
        <div className="mod-approved-filters-row">
          {/* Account Type */}
          <div className="mod-approved-filter-group">
            <select
              className="mod-approved-filter-select"
              value={filters.accountType}
              onChange={e => setFilters(f => ({ ...f, accountType: e.target.value }))}
            >
              <option value="" disabled>Select Account Type</option>
              {accountTypes.map(type => (
                <option key={type} value={type}>{type}</option>
              ))}
            </select>
            <svg className="mod-approved-filter-arrow" viewBox="0 0 20 20">
              <path d="M6 8l4 4 4-4" stroke="#b0b0b0" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
          </div>
          {/* Academic Year */}
          <div className="mod-approved-filter-group">
            <select
              className="mod-approved-filter-select"
              value={filters.academicYear}
              onChange={e => setFilters(f => ({ ...f, academicYear: e.target.value }))}
            >
              <option value="" disabled>Select Academic Year</option>
              {academicYears.map(ay => (
                <option key={ay} value={ay}>{ay}</option>
              ))}
            </select>
            <svg className="mod-approved-filter-arrow" viewBox="0 0 20 20">
              <path d="M6 8l4 4 4-4" stroke="#b0b0b0" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
          </div>
          {/* Department */}
          <div className="mod-approved-filter-group">
            <select
              className="mod-approved-filter-select"
              value={filters.department}
              onChange={e => setFilters(f => ({ ...f, department: e.target.value }))}
            >
              <option value="" disabled>Select Department</option>
              {departments.map(dept => (
                <option key={dept} value={dept}>{dept}</option>
              ))}
            </select>
            <svg className="mod-approved-filter-arrow" viewBox="0 0 20 20">
              <path d="M6 8l4 4 4-4" stroke="#b0b0b0" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
          </div>
          {/* Year Level */}
          <div className="mod-approved-filter-group">
            <select
              className="mod-approved-filter-select"
              value={filters.yearLevel}
              onChange={e => setFilters(f => ({ ...f, yearLevel: e.target.value }))}
            >
              <option value="" disabled>Select Year Level</option>
              {yearLevels.map(yl => (
                <option key={yl} value={yl}>{yl}</option>
              ))}
            </select>
            <svg className="mod-approved-filter-arrow" viewBox="0 0 20 20">
              <path d="M6 8l4 4 4-4" stroke="#b0b0b0" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
          </div>
          {/* Hold Status */}
          <div className="mod-approved-filter-group">
            <select
              className="mod-approved-filter-select"
              value={filters.holdStatus}
              onChange={e => setFilters(f => ({ ...f, holdStatus: e.target.value }))}
            >
              <option value="" disabled>Select Hold Status</option>
              {holdStatuses.map(status => (
                <option key={status} value={status}>{status}</option>
              ))}
            </select>
            <svg className="mod-approved-filter-arrow" viewBox="0 0 20 20">
              <path d="M6 8l4 4 4-4" stroke="#b0b0b0" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
          </div>
        </div>
        <div className="moderator-history-left-column">
          <div className="moderator-history-section">
            <div className="moderator-history-card-list">
              {paginatedItems.map((item, idx) => (
                <div key={item.id} className="moderator-history-item">
                  <div className="moderator-history-appointment-avatar">
                    {item.avatar ? (
                      <img src={item.avatar} alt={item.name} className="moderator-history-avatar-img" />
                    ) : (
                      <div className="moderator-history-avatar-img" style={{
                        background: '#e0e0e0',
                        width: '70px',
                        height: '70px',
                        borderRadius: '50%',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        fontWeight: 'bold',
                        color: '#666'
                      }}>
                        {item.name.split(' ').map(n => n[0]).join('').substring(0, 2)}
                      </div>
                    )}
                  </div>
                  <div className="moderator-history-appointment-info">
                    <div
                      className="moderator-history-appointment-name"
                      style={{ color: '#424A57', fontSize: '1.5rem', fontWeight: 950 }}
                    >
                      {item.name}
                    </div>
                    {item.id === 1 ? (
                      <>
                        <div className="moderator-history-appointment-details" style={{ fontSize: '0.95rem' }}>
                          <span style={{ color: '#424A57', fontWeight: 600 }}>Account Type:</span>
                          <span style={{ color: '#757575', marginLeft: 8 }}>{item.accountType}</span>
                        </div>
                        <div className="moderator-history-appointment-details" style={{ fontSize: '0.95rem' }}>
                          <span style={{ color: '#424A57', fontWeight: 600 }}>Department:</span>
                          <span style={{ color: '#757575', marginLeft: 8 }}>{item.department}</span>
                        </div>
                        <div className="moderator-history-appointment-details" style={{ fontSize: '0.95rem' }}>
                          <span style={{ color: '#424A57', fontWeight: 600 }}>Year Level:</span>
                          <span style={{ color: '#757575', marginLeft: 8 }}>{item.yearLevel}</span>
                        </div>
                        <div className="moderator-history-appointment-details" style={{ fontSize: '0.95rem' }}>
                          <span style={{ color: '#424A57', fontWeight: 600 }}>Academic Year:</span>
                          <span style={{ color: '#757575', marginLeft: 8 }}>{item.academicYear}</span>
                        </div>
                      </>
                    ) : (
                      <>
                        <div className="moderator-history-appointment-details">{item.details}</div>
                        <div className="moderator-history-appointment-time">{item.time}</div>
                      </>
                    )}
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'flex-end' }}>
                    <button
                      onClick={() => handleToggleHold(idx + (page - 1) * ITEMS_PER_PAGE)}
                      className={`moderator-history-btn ${holdStatus[idx + (page - 1) * ITEMS_PER_PAGE] ? 'primary' : 'secondary'}`}
                    >
                      {holdStatus[idx + (page - 1) * ITEMS_PER_PAGE] ? 'Hold' : 'Unhold'}
                    </button>
                  </div>
                </div>
              ))}
            </div>
            {/* Pagination controls */}
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
          </div>
        </div>
      </div>
    </div>
  );
};

export default ModeratorApprovedHistory;
