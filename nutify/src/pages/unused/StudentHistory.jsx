import React, { useState, useEffect } from 'react';
import Sidebar from '../../components/Sidebar';
import Header from '../../components/Header';
import '../styles/dashboard.css';
import '../styles/studenthistory.css';

import filterIcon from '../assets/icons/filter.svg';

const StudentHistory = () => {
  const [activeFilter, setActiveFilter] = useState('all');
  const [searchTerm, setSearchTerm] = useState('');
  const [showFilterModal, setShowFilterModal] = useState(false);
  const [showDetailsModal, setShowDetailsModal] = useState(false);
  const [selectedItem, setSelectedItem] = useState(null);

  // Sample history data
  const historyItems = [
    {
      id: 1,
      name: 'Jei Pastrana',
      details: 'Faculty - SACE',
      time: 'June 15 - 09:00 am',
      status: 'pending',
      avatar: null
    },
    {
      id: 2,
      name: 'Irene Balmes',
      details: 'Faculty - SACE',
      time: 'June 14 - 09:00 am',
      status: 'accepted',
      avatar: null
    },
    {
      id: 3,
      name: 'Jei Pastrana',
      details: 'Faculty - SACE',
      time: 'June 13 - 09:00 am',
      status: 'completed',
      avatar: null
    },
    {
      id: 4,
      name: 'Irene Balmes',
      details: 'Faculty - SACE',
      time: 'June 12 - 09:00 am',
      status: 'missed',
      avatar: null
    },
    {
      id: 5,
      name: 'Jei Pastrana',
      details: 'Faculty - SACE',
      time: 'June 11 - 09:00 am',
      status: 'cancelled',
      avatar: null
    },
    {
      id: 6,
      name: 'Irene Balmes',
      details: 'Faculty - SACE',
      time: 'June 10 - 09:00 am',
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
        { text: "-", class: "secondary" },
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
        userType="student"
        userName="John Doe"
        userRole="Student - SACE"
        userAvatar={null}
      />
      
      <Header 
        title="Hello, John Doe"
        subtitle="View your appointment history and status"
        searchPlaceholder="Search History"
        onSearch={handleSearch}
      />

      <div className="student-history-main-content">
        <div className="student-history-content-container">
          <div className="student-history-left-column">
            {/* History Section */}
            <div className="student-history-section">
              {/* Desktop Filter Tabs */}
              <div className="student-history-filter-tabs" data-active={activeFilter}>
                {filterOptions.map(option => (
                  <button
                    key={option.value}
                    className={`student-history-filter-btn ${activeFilter === option.value ? 'active' : ''}`}
                    data-filter={option.value}
                    onClick={() => handleFilterChange(option.value)}
                  >
                    {option.label}
                  </button>
                ))}
              </div>

              {/* Mobile Filter Button */}
              <button
                className="student-history-filter-mobile-btn"
                onClick={() => setShowFilterModal(true)}
              >
                <img src={filterIcon} alt="Filter" className="student-history-filter-icon" />
                <span>{filterOptions.find(opt => opt.value === activeFilter)?.label || 'All'}</span>
              </button>

              <div className="student-history-card-list">
                {filteredItems.map(item => (
                  <div key={item.id} className="student-history-item" data-status={item.status}>
                    <div className="student-history-appointment-avatar">
                      <div
                        className="student-history-avatar-img"
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
                    <div className="student-history-appointment-info">
                      <div className="student-history-appointment-name student-history-name">{item.name}</div>
                      <div className="student-history-appointment-details student-history-details">{item.details}</div>
                      <div className="student-history-appointment-time">{item.time}</div>
                      <button
                        className="student-history-see-more-btn"
                        onClick={() => handleSeeMore(item)}
                      >
                        See More
                      </button>
                    </div>
                    <div className={`student-history-status student-history-status-${item.status}`}>
                      {item.status.charAt(0).toUpperCase() + item.status.slice(1)}
                    </div>
                    <div className={`student-history-status-mobile student-history-status-${item.status}`}>
                      {item.status.charAt(0).toUpperCase() + item.status.slice(1)}
                    </div>
                  </div>
                ))}
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
                <div className="student-history-filter-modal-options">
                  {filterOptions.map(option => (
                    <div
                      key={option.value}
                      className={`student-history-filter-option ${activeFilter === option.value ? 'selected' : ''}`}
                      data-filter={option.value}
                      onClick={() => handleFilterChange(option.value)}
                    >
                      <img src={option.icon} alt={option.label} className="student-history-filter-option-icon" />
                      <span>{option.label}</span>
                    </div>
                  ))}
                </div>
              </div>
              <div className="modal-footer">
                <button
                  type="button"
                  className="btn btn-primary"
                  id="student-history-filterModalBtn"
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
            <div className="modal-content student-history-details-modal-content">
              <div className="modal-header">
                <h5 className="modal-title">Appointment Status</h5>
                <button
                  type="button"
                  className="btn-close"
                  onClick={() => setShowDetailsModal(false)}
                ></button>
              </div>
              <div className="modal-body">
                <div className="student-history-details-modal-body">
                  <div className="student-history-details-modal-title">{selectedItem.name}</div>
                  <div className="student-history-details-modal-time">{selectedItem.time}</div>
                  
                  {statusModalMap[selectedItem.status] && (
                    <>
                      <div className={`student-history-details-modal-status ${statusModalMap[selectedItem.status].main.class}`}>
                        {statusModalMap[selectedItem.status].main.text}
                      </div>
                      {statusModalMap[selectedItem.status].secondary?.map((sec, index) => (
                        <div key={index} className={`student-history-details-modal-status ${sec.class}`}>
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

export default StudentHistory;