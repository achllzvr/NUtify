import React, { useState } from 'react';

const facultyList = [
  { id: 1, name: 'Jayson Guia', department: 'Faculty - SACE', status: 'online', avatar: null },
  { id: 2, name: 'Jei Pastrana', department: 'Faculty - SACE', status: 'offline', avatar: null },
  { id: 3, name: 'Irene Balmes', department: 'Faculty - SACE', status: 'online', avatar: null },
  { id: 4, name: 'Carlo Torres', department: 'Faculty - SACE', status: 'offline', avatar: null },
  { id: 5, name: 'Archie Menisis', department: 'Faculty - SACE', status: 'online', avatar: null },
  { id: 6, name: 'Michael Joseph Aramil', department: 'Faculty - SACE', status: 'offline', avatar: null },
  { id: 7, name: 'Erwin De Castro', department: 'Faculty - SACE', status: 'online', avatar: null },
  { id: 8, name: 'Joel Enriquez', department: 'Faculty - SACE', status: 'offline', avatar: null },
  { id: 9, name: 'Bernie Fabito', department: 'Faculty - SACE', status: 'online', avatar: null },
  { id: 10, name: 'Bobby Buendia', department: 'Faculty - SAHS', status: 'online', avatar: null },
  { id: 11, name: 'Penny Lumbera', department: 'Faculty - SAHS', status: 'offline', avatar: null },
  { id: 12, name: 'Larry Fronda', department: 'Faculty - SAHS', status: 'offline', avatar: null }
];

const FACULTY_PER_PAGE = 10;

const FacultyList = ({ mainSearch, facultyStatusFilter, setFacultyStatusFilter }) => {
  const [page, setPage] = useState(1);

  const filteredFacultyList = facultyList.filter(f =>
    (facultyStatusFilter === 'all' || f.status === facultyStatusFilter) &&
    (f.name.toLowerCase().includes(mainSearch.toLowerCase()) ||
      f.department.toLowerCase().includes(mainSearch.toLowerCase()))
  );

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
        {paginatedFaculty.length === 0 ? (
          <div style={{ textAlign: 'center', color: '#888', marginTop: '40px', fontSize: '1.2em', fontWeight: 500 }}>
            No faculty users found.
          </div>
        ) : (
          paginatedFaculty.map(faculty => (
            <div
              key={faculty.id}
              className="moderator-home-faculty-item"
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
              <div className={`moderator-home-faculty-status ${faculty.status}`}></div>
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