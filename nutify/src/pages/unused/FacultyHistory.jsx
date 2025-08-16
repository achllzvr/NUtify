import React, { useState, useEffect } from 'react';
import Sidebar from '../components/Sidebar';
import Header from '../components/Header';
import '../styles/dashboard.css';
import '../styles/facultyhistory.css';

import filterIcon from '../assets/icons/filter.svg';

const FacultyHistory = () => {
  const [activeFilter, setActiveFilter] = useState('all');
  const [searchTerm, setSearchTerm] = useState('');
  const [showFilterModal, setShowFilterModal] = useState(false);
  const [showDetailsModal, setShowDetailsModal] = useState(false);
  const [selectedItem, setSelectedItem] = useState(null);

  // Sample history data for faculty
  const historyItems = [
    {
      id: 1,
      name: 'Beatriz Solis',
      details: 'Student - SACE',
      time: 'June 15 - 00:00 am',
      status: 'pending',
      avatar: null
    },
    {
      id: 2,
      name: 'John Clarenz Dimazana',
      details: 'Student - SACE',
      time: 'June 16 - 10:00 am',
      status: 'accepted',
      avatar: null
    },
    {
      id: 3,
      name: 'Kriztopher Kier Estioco',
      details: 'Student - SACE',
      time: 'June 18 - 02:00 pm',
      status: 'completed',
      avatar: null
    },
    {
      id: 4,
      name: 'Niel Cerezo',
      details: 'Student - SACE',
      time: 'June 19 - 11:00 am',
      status: 'missed',
      avatar: null
    },
    {
      id: 5,
      name: 'Beatriz Solis',
      details: 'Student - SACE',
      time: 'June 20 - 09:00 am',
      status: 'cancelled',
      avatar: null
    },
    {
      id: 6,
      name: 'John Clarenz Dimazana',
      details: 'Student - SACE',
      time: 'June 21 - 02:00 pm',
      status: 'declined',
      avatar: null
    }
  ];

  const filterOptions = [
    { value: 'all', label: 'All', icon: filterIcon },
    { value: 'pending', label: 'Pending', icon: filterIcon },
    { value: 'accepted', label: 'Accepted', icon: filterIcon },
    { value: 'completed', label: 'Completed', icon: filterIcon },
    { value: 'missed', label: 'Missed', icon: filterIcon },
    { value: 'cancelled', label: 'Cancelled', icon: filterIcon },
    { value: 'declined', label: 'Declined', icon: filterIcon }
  ];

  const statusModalMap = {
    pending: {
      main: { text: "-", class: "pending" },
      secondary: [
        { text: "Accept Appointment?", class: "secondary pending-badge" },
        { text: "Pending - June 11; 6:00 pm", class: "secondary" }
      ]
    },
    completed: {
      main: { text: "Completed - June 13; 9:23 am", class: "completed" },
      secondary: [
        { text: "Accepted - June 12; 12:00 am", class: "secondary" },
        { text: "Pending - June 11; 6:00 pm", class: "secondary" }
      ]
    },
    accepted: {
      main: { text: "-", class: "pending" },
      secondary: [
        { text: "Accepted - June 13; 9:23 am", class: "accepted" },
        { text: "Pending - June 11; 6:00 pm", class: "secondary" }
      ]
    },
    missed: {
      main: { text: "Missed - June 13; 9:23 am", class: "missed" },
      secondary: [
        { text: "Accepted - June 12; 12:00 am", class: "secondary" },
        { text: "Pending - June 11; 6:00 pm", class: "secondary" }
      ]
    },
    declined: {
      main: { text: "-", class: "pending" },
      secondary: [
        { text: "Declined - June 13; 9:23 am", class: "declined" },
        { text: "Pending - June 11; 6:00 pm", class: "secondary" }
      ]
    },
    cancelled: {
      main: { text: "Cancelled - June 13; 9:23 am", class: "cancelled" },
      secondary: [
        { text: "Accepted - June 12; 12:00 am", class: "secondary" },
        { text: "Pending - June 11; 6:00 pm", class: "secondary" }
      ]
    }
  };

  // Filter items based on active filter and search term
  const filteredItems = historyItems.filter(item => {
    const matchesFilter = activeFilter === 'all' || item.status === activeFilter;
    const matchesSearch = !searchTerm || 
      item.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.details.toLowerCase().includes(searchTerm.toLowerCase());
    return matchesFilter && matchesSearch;
  });

  const ITEMS_PER_PAGE = 10;
  const [page, setPage] = useState(1);
  const totalPages = Math.max(1, Math.ceil(filteredItems.length / ITEMS_PER_PAGE));
  const paginatedItems = filteredItems.slice(
    (page - 1) * ITEMS_PER_PAGE,
    page * ITEMS_PER_PAGE
  );
  const handlePrev = () => setPage(prev => Math.max(prev - 1, 1));
  const handleNext = () => setPage(prev => Math.min(prev + 1, totalPages));

  const handleFilterChange = (filter) => {
    setActiveFilter(filter);
  };

  const handleSearch = (term) => {
    setSearchTerm(term);
  };

  const handleSeeMore = (item) => {
    setSelectedItem(item);
    setShowDetailsModal(true);
  };

  const handleMobileFilterApply = () => {
    setShowFilterModal(false);
  };

  // Check for URL parameters on component mount
  useEffect(() => {
    const urlParams = new URLSearchParams(window.location.search);
    const filterParam = urlParams.get('filter');
    if (filterParam && filterOptions.some(opt => opt.value === filterParam)) {
      setActiveFilter(filterParam);
    }
  }, []);

  return (
    <div>
      <Sidebar
        userType="faculty"
        userName="Not John Doe"
        userRole="Faculty - SACE"
        userAvatar={null}
      />
      
      <Header
        title="Consultation History"
        subtitle="View and manage all your past and upcoming student consultation appointments"
        searchPlaceholder="Search History"
        onSearch={handleSearch}
      />

      <div className="faculty-history-main-content">
        <div className="faculty-history-content-container">
          <div className="faculty-history-left-column">
            {/* History Section */}
            <div className="faculty-history-section">
              {/* Desktop Filter Tabs */}
              <div className="faculty-history-filter-tabs" data-active={activeFilter}>
                {filterOptions.map(option => (
                  <button
                    key={option.value}
                    className={`faculty-history-filter-btn ${activeFilter === option.value ? 'active' : ''}`}
                    data-filter={option.value}
                    onClick={() => handleFilterChange(option.value)}
                  >
                    {option.label}
                  </button>
                ))}
              </div>

              {/* Mobile Filter Button */}
              <button
                className="faculty-history-filter-mobile-btn"
                onClick={() => setShowFilterModal(true)}
              >
                <img src={filterIcon} alt="Filter" className="faculty-history-filter-icon" />
                <span>{filterOptions.find(opt => opt.value === activeFilter)?.label || 'All'}</span>
              </button>

              <div className="faculty-history-card-list">
                {paginatedItems.map(item => (
                  <div key={item.id} className="faculty-history-item" data-status={item.status}>
                    <div className="faculty-history-appointment-avatar">
                      <div
                        className="faculty-history-avatar-img"
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
                        {item.name.split(' ').map(n => n[0]).join('').substring(0, 2)}
                      </div>
                    </div>
                    <div className="faculty-history-appointment-info">
                      <div className="faculty-history-appointment-name faculty-history-name">{item.name}</div>
                      <div className="faculty-history-appointment-details faculty-history-details">{item.details}</div>
                      <div className="faculty-history-appointment-time">{item.time}</div>
                      <button
                        className="faculty-history-see-more-btn"
                        onClick={() => handleSeeMore(item)}
                      >
                        See More
                      </button>
                    </div>
                    <div className={`faculty-history-status faculty-history-status-${item.status}`}>
                      {item.status.charAt(0).toUpperCase() + item.status.slice(1)}
                    </div>
                    <div className={`faculty-history-status-mobile faculty-history-status-${item.status}`}>
                      {item.status.charAt(0).toUpperCase() + item.status.slice(1)}
                    </div>
                  </div>
                ))}
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
                      fontWeight: 500
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
                    alignItems: 'center'
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
                      fontWeight: 500
                    }}
                  >
                    Next
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Mobile Filter Modal */}
      {showFilterModal && (
        <div className="modal fade show" style={{ display: 'block' }}>
          <div className="modal-dialog modal-dialog-centered">
            <div className="modal-content">
              <div className="modal-header">
                <h5 className="modal-title">Filter History</h5>
                <button
                  type="button"
                  className="btn-close"
                  onClick={() => setShowFilterModal(false)}
                ></button>
              </div>
              <div className="modal-body">
                <div className="faculty-history-filter-modal-options">
                  {filterOptions.map(option => (
                    <div
                      key={option.value}
                      className={`faculty-history-filter-option ${activeFilter === option.value ? 'selected' : ''}`}
                      data-filter={option.value}
                      onClick={() => handleFilterChange(option.value)}
                    >
                      <img src={option.icon} alt={option.label} className="faculty-history-filter-option-icon" />
                      <span>{option.label}</span>
                    </div>
                  ))}
                </div>
              </div>
              <div className="modal-footer">
                <button
                  type="button"
                  className="btn btn-primary"
                  id="faculty-history-filterModalBtn"
                  onClick={handleMobileFilterApply}
                >
                  Apply Filter
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* History Details Modal */}
      {showDetailsModal && selectedItem && (
        <div className="modal fade show" style={{ display: 'block' }}>
          <div className="modal-dialog modal-dialog-centered">
            <div className="modal-content faculty-history-details-modal-content">
              <div className="modal-header">
                <h5 className="modal-title">Appointment Status</h5>
                <button
                  type="button"
                  className="btn-close"
                  onClick={() => setShowDetailsModal(false)}
                ></button>
              </div>
              <div className="modal-body">
                <div className="faculty-history-details-modal-body">
                  <div className="faculty-history-details-modal-title">{selectedItem.name}</div>
                  <div className="faculty-history-details-modal-time">{selectedItem.time}</div>
                  
                  {statusModalMap[selectedItem.status] && (
                    <>
                      <div className={`faculty-history-details-modal-status ${statusModalMap[selectedItem.status].main.class}`}>
                        {statusModalMap[selectedItem.status].main.text}
                      </div>
                      {statusModalMap[selectedItem.status].secondary?.map((sec, index) => (
                        <div
                          key={index}
                          className={`faculty-history-details-modal-status ${sec.class} ${sec.text === "Accept Appointment?" ? "faculty-history-pending-badge" : ""}`}
                        >
                          {sec.text}
                        </div>
                      ))}
                    </>
                  )}
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Modal backdrop */}
      {(showFilterModal || showDetailsModal) && (
        <div className="modal-backdrop fade show"></div>
      )}
    </div>
  );
};

export default FacultyHistory;