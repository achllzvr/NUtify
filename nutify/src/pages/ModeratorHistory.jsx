import React, { useState, useEffect } from 'react';
import Sidebar from '../components/Sidebar';
import Header from '../components/Header';
import '../styles/dashboard.css';
import '../styles/moderatorhistory.css'; // changed from studenthistory.css

// Import avatar images
import johnDoeAvatar from '../assets/images/avatars/1c9a4dd0bbd964e3eecbd40caf3b7e37.jpg';
import jeiPastranaAvatar from '../assets/images/avatars/1c9a4dd0bbd964e3eecbd40caf3b7e37.jpg';
import ireneBalmes from '../assets/images/avatars/c33237da3438494d1abc67166196484e.jpg';
import filterIcon from '../assets/icons/filter.svg';

const ModeratorHistory = () => { // changed from StudentHistory
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
      avatar: jeiPastranaAvatar
    },
    {
      id: 2,
      name: 'Irene Balmes',
      details: 'Faculty - SACE',
      time: 'June 14 - 09:00 am',
      status: 'accepted',
      avatar: ireneBalmes
    },
    {
      id: 3,
      name: 'Jei Pastrana',
      details: 'Faculty - SACE',
      time: 'June 13 - 09:00 am',
      status: 'completed',
      avatar: jeiPastranaAvatar
    },
    {
      id: 4,
      name: 'Irene Balmes',
      details: 'Faculty - SACE',
      time: 'June 12 - 09:00 am',
      status: 'missed',
      avatar: ireneBalmes
    },
    {
      id: 5,
      name: 'Jei Pastrana',
      details: 'Faculty - SACE',
      time: 'June 11 - 09:00 am',
      status: 'cancelled',
      avatar: jeiPastranaAvatar
    },
    {
      id: 6,
      name: 'Irene Balmes',
      details: 'Faculty - SACE',
      time: 'June 10 - 09:00 am',
      status: 'declined',
      avatar: ireneBalmes
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

  // Set document title
  useEffect(() => {
    document.title = "Inbox - NUtify";
  }, []);

  return (
    <div>
      <Sidebar 
        userType="moderator"
        userName="John Doe"
        userRole="Moderator - SACE"
        userAvatar={johnDoeAvatar}
      />
      
      <Header 
        title="Hello, John Doe"
        subtitle="View your appointment history and status"
        searchPlaceholder="Search History"
        onSearch={handleSearch}
      />

      <div className="moderator-history-main-content">
        <div className="moderator-history-content-container">
          <div className="moderator-history-left-column">
            {/* History Section */}
            <div className="moderator-history-section">
              {/* Desktop Filter Tabs */}
              <div className="moderator-history-filter-tabs" data-active={activeFilter}>
                {filterOptions.map(option => (
                  // changed from student-history-filter-btn
                  <button
                    key={option.value}
                    className={`moderator-history-filter-btn ${activeFilter === option.value ? 'active' : ''}`}
                    data-filter={option.value}
                    onClick={() => handleFilterChange(option.value)}
                  >
                    {option.label}
                  </button>
                ))}
              </div>

              {/* Mobile Filter Button */}
              {/* changed from student-history-filter-mobile-btn */}
              <button
                className="moderator-history-filter-mobile-btn"
                onClick={() => setShowFilterModal(true)}
              >
                <img src={filterIcon} alt="Filter" className="moderator-history-filter-icon" />
                <span>{filterOptions.find(opt => opt.value === activeFilter)?.label || 'All'}</span>
              </button>

              <div className="moderator-history-card-list">
                {filteredItems.map(item => (
                  // changed from student-history-item
                  <div key={item.id} className="moderator-history-item" data-status={item.status}>
                    <div className="moderator-history-appointment-avatar">
                      <img src={item.avatar} alt={item.name} className="moderator-history-avatar-img" />
                    </div>
                    <div className="moderator-history-appointment-info">
                      {/* changed from student-history-appointment-name student-history-name */}
                      <div className="moderator-history-appointment-name moderator-history-name">{item.name}</div>
                      {/* changed from student-history-appointment-details student-history-details */}
                      <div className="moderator-history-appointment-details moderator-history-details">{item.details}</div>
                      <div className="moderator-history-appointment-time">{item.time}</div>
                      {/* changed from student-history-see-more-btn */}
                      <button
                        className="moderator-history-see-more-btn"
                        onClick={() => handleSeeMore(item)}
                      >
                        See More
                      </button>
                    </div>
                    {/* changed from student-history-status student-history-status-${item.status} */}
                    <div className={`moderator-history-status moderator-history-status-${item.status}`}>
                      {item.status.charAt(0).toUpperCase() + item.status.slice(1)}
                    </div>
                    {/* changed from student-history-status-mobile student-history-status-${item.status} */}
                    <div className={`moderator-history-status-mobile moderator-history-status-${item.status}`}>
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
                <div className="moderator-history-filter-modal-options">
                  {filterOptions.map(option => (
                    // changed from student-history-filter-option
                    <div
                      key={option.value}
                      className={`moderator-history-filter-option ${activeFilter === option.value ? 'selected' : ''}`}
                      data-filter={option.value}
                      onClick={() => handleFilterChange(option.value)}
                    >
                      <img src={option.icon} alt={option.label} className="moderator-history-filter-option-icon" />
                      <span>{option.label}</span>
                    </div>
                  ))}
                </div>
              </div>
              <div className="modal-footer">
                {/* changed from student-history-filterModalBtn */}
                <button
                  type="button"
                  className="btn btn-primary"
                  id="moderator-history-filterModalBtn"
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
            {/* changed from student-history-details-modal-content */}
            <div className="modal-content moderator-history-details-modal-content">
              <div className="modal-header">
                <h5 className="modal-title">Appointment Status</h5>
                <button
                  type="button"
                  className="btn-close"
                  onClick={() => setShowDetailsModal(false)}
                ></button>
              </div>
              <div className="modal-body">
                {/* changed from student-history-details-modal-body */}
                <div className="moderator-history-details-modal-body">
                  {/* changed from student-history-details-modal-title */}
                  <div className="moderator-history-details-modal-title">{selectedItem.name}</div>
                  {/* changed from student-history-details-modal-time */}
                  <div className="moderator-history-details-modal-time">{selectedItem.time}</div>
                  
                  {statusModalMap[selectedItem.status] && (
                    <>
                      {/* changed from student-history-details-modal-status */}
                      <div className={`moderator-history-details-modal-status ${statusModalMap[selectedItem.status].main.class}`}>
                        {statusModalMap[selectedItem.status].main.text}
                      </div>
                      {statusModalMap[selectedItem.status].secondary?.map((sec, index) => (
                        <div key={index} className={`moderator-history-details-modal-status ${sec.class}`}>
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

export default ModeratorHistory;