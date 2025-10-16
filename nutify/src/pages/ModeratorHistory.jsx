// Page: Moderator History
import React, { useState, useEffect } from "react";
import Sidebar from "../components/Sidebar";
import Header from "../components/Header";
import DailyLogHistory from "../pages/components/DailyLogHistory";
import RequestHistory, {
  requestHistoryItems,
} from "../pages/components/RequestHistory";
import ApprovalHistory from "../pages/components/ApprovalHistory";
import "../styles/dashboard.css";
import "../styles/moderatorhistory.css";

import filterIcon from "../assets/icons/filter.svg";
import checkIcon from "../assets/icons/check.svg";

// Date formatting
const formatDateMMDDYYYY = (dateStr) => {
  const d = new Date(dateStr);
  return isNaN(d.getTime())
    ? dateStr
    : `${(d.getMonth() + 1).toString().padStart(2, "0")}/${d
        .getDate()
        .toString()
        .padStart(2, "0")}/${d.getFullYear()}`;
};

const ModeratorHistory = () => {
  // State variables
  const [activeFilter, setActiveFilter] = useState("dailylog");
  const [searchTerm, setSearchTerm] = useState("");
  const [searchInput, setSearchInput] = useState("");
  const [selectedItem, setSelectedItem] = useState(null);
  const [verifyAlertVisible, setVerifyAlertVisible] = useState(false);
  const [verifyAlertTransition, setVerifyAlertTransition] = useState(false);
  const [filterModalOpen, setFilterModalOpen] = useState(false);

  // Filter tab options
  const filterOptions = React.useMemo(() => ([
    { value: "dailylog", label: "Daily Log", icon: filterIcon },
    { value: "request", label: "Today's Requests", icon: filterIcon },
    { value: "approval", label: "Approval", icon: filterIcon },
  ]), []);

  // Filter tab change handler
  const handleFilterChange = (filter) => {
    setActiveFilter(filter);
  };

  // Search input handler
  const handleSearchChange = (value) => {
    setSearchInput(value);
  };

  // Search handler
  const handleSearch = () => {
    setSearchTerm(searchInput);
  };

  // Details modal handler
  const handleViewDetails = (item) => {
    setSelectedItem(item);
  };

  // Verify handler
  const handleVerify = () => {
    const audio = new window.Audio("/nutified.wav");
    audio.play();
    setVerifyAlertVisible(true);
    setTimeout(() => setVerifyAlertTransition(true), 10);
    setTimeout(() => {
      setVerifyAlertTransition(false);
      setTimeout(() => setVerifyAlertVisible(false), 350);
    }, 2500);
  };

  // Verify alert close handler
  const handleVerifyAlertClose = () => {
    setVerifyAlertTransition(false);
    setTimeout(() => setVerifyAlertVisible(false), 350);
  };

  // Mobile filter modal open/close handler
  const handleMobileFilterBtnClick = () => {
    setFilterModalOpen(true);
  };
  const handleFilterModalClose = () => {
    setFilterModalOpen(false);
  };
  const handleFilterSelect = (filter) => {
    setActiveFilter(filter);
    setFilterModalOpen(false);
  };

  // Check for URL parameters on mount
  useEffect(() => {
    const urlParams = new URLSearchParams(window.location.search);
    const filterParam = urlParams.get("filter");
    if (filterParam && filterOptions.some((opt) => opt.value === filterParam)) {
      setActiveFilter(filterParam);
    }
  }, [filterOptions]);

  // Set document title
  useEffect(() => {
    document.title = "Inbox - NUtify";
  }, []);

  // Escape handler for modal
  useEffect(() => {
    if (!selectedItem) return;
    const handleEsc = (e) => {
      if (e.key === "Escape") setSelectedItem(null);
    };
    window.addEventListener("keydown", handleEsc);
    return () => window.removeEventListener("keydown", handleEsc);
  }, [selectedItem]);

  // Main render
  return (
    <div>
      {/* Verified notification */}
      {verifyAlertVisible && (
        <div
          style={{
            position: "fixed",
            top: "32px",
            left: "50%",
            minWidth: "320px",
            maxWidth: "90vw",
            background: "#D4F7DC",
            color: "#1c1d1e",
            borderRadius: "8px",
            boxShadow: "0 2px 8px rgba(0,0,0,0.12)",
            padding: "10px 18px",
            display: "flex",
            alignItems: "center",
            gap: "10px",
            zIndex: 3000,
            fontFamily: "Arimo, Arial, sans-serif",
            fontSize: "15px",
            fontWeight: 500,
            opacity: verifyAlertTransition ? 1 : 0,
            transform: `translateX(-50%) ${verifyAlertTransition ? 'translateY(0)' : 'translateY(-12px)'}`,
            transition: "opacity 0.35s, transform 0.35s",
          }}
        >
          <span
            style={{
              display: "flex",
              alignItems: "center",
              marginRight: "2px",
            }}
          >
            <img src={checkIcon} alt="Check" width="22" height="22" />
          </span>
          <span style={{ fontWeight: 600, marginRight: "2px" }}>Verified:</span>
          <span style={{ marginRight: "8px" }}>Successfully Verified!</span>
          <span
            style={{
              marginLeft: "auto",
              cursor: "pointer",
              fontSize: "18px",
              color: "#1c1d1e",
              fontWeight: 700,
              lineHeight: "1",
              paddingLeft: "8px",
            }}
            onClick={handleVerifyAlertClose}
            aria-label="Close"
            title="Close"
          >
            &#10005;
          </span>
        </div>
      )}

      {/* Sidebar */}
      <Sidebar
        userType="moderator"
        userName="Moderator"
        userRole="Moderator"
        userAvatar={null}
      />

      {/* Header */}
      <Header
        title="Hello, Moderator!"
        subtitle="Manage your appointments and consultations in one place"
        searchPlaceholder="Search Entries"
        searchValue={searchInput}
        onSearchChange={handleSearchChange}
        onSearch={handleSearch}
      />

      {/* Main content area */}
      <div className="moderator-history-main-content">
        <div className="moderator-history-content-container">
          <div className="moderator-history-left-column">
            <div className="moderator-history-section">
              {/* Filter tabs (desktop) */}
              <div
                className="moderator-history-filter-tabs"
                data-active={activeFilter}
              >
                {filterOptions.map((option) => (
                  <button
                    key={option.value}
                    className={`moderator-history-filter-btn ${
                      activeFilter === option.value ? "active" : ""
                    }`}
                    data-filter={option.value}
                    onClick={() => handleFilterChange(option.value)}
                  >
                    {option.label}
                  </button>
                ))}
              </div>
              {/* Filter button (mobile) */}
              <button
                className="moderator-history-filter-mobile-btn"
                onClick={handleMobileFilterBtnClick}
                style={{ opacity: 1, cursor: "pointer" }}
              >
                <img
                  src={filterIcon}
                  alt="Filter"
                  className="moderator-history-filter-icon"
                />
                <span>
                  {filterOptions.find((opt) => opt.value === activeFilter)
                    ?.label || "Daily Log"}
                </span>
              </button>
              {/* Mobile filter modal */}
              {filterModalOpen && (
                <div
                  className="modal fade show"
                  style={{
                    display: "block",
                    position: "fixed",
                    top: 0,
                    left: 0,
                    width: "100vw",
                    height: "100vh",
                    background: "rgba(0,0,0,0.18)",
                    zIndex: 4000,
                  }}
                >
                  <div
                    className="modal-dialog"
                    style={{
                      maxWidth: "340px",
                      margin: "80px auto",
                      borderRadius: "18px",
                      background: "#fff",
                      boxShadow: "0 2px 16px rgba(0,0,0,0.12)",
                      padding: "18px 0",
                    }}
                  >
                    <div className="modal-content" style={{ borderRadius: "18px" }}>
                      <div
                        className="modal-header"
                        style={{
                          borderBottom: "none",
                          padding: "0 18px 8px 18px",
                          fontWeight: 700,
                          fontSize: "18px",
                        }}
                      >
                        <span>Choose Filter</span>
                        <span
                          style={{
                            position: "absolute",
                            right: "18px",
                            top: "18px",
                            fontSize: "22px",
                            cursor: "pointer",
                            color: "#888",
                          }}
                          onClick={handleFilterModalClose}
                          aria-label="Close"
                          title="Close"
                        >
                          &#10005;
                        </span>
                      </div>
                      <div className="modal-body" style={{ padding: "0 18px" }}>
                        <div className="moderator-history-filter-modal-options">
                          {filterOptions.map((option) => (
                            <button
                              key={option.value}
                              className={`moderator-history-filter-option${
                                activeFilter === option.value ? " selected" : ""
                              }`}
                              onClick={() => handleFilterSelect(option.value)}
                              style={{
                                display: "flex",
                                alignItems: "center",
                                width: "100%",
                                marginBottom: "8px",
                                fontSize: "16px",
                                fontWeight: activeFilter === option.value ? 600 : 500,
                                color: activeFilter === option.value ? "#35408e" : "#2c3e50",
                                cursor: "pointer",
                                padding: "12px 0",
                                borderRadius: "12px",
                                background: activeFilter === option.value
                                  ? "rgba(53,64,142,0.08)"
                                  : "#f8f8f8",
                                border: activeFilter === option.value
                                  ? "2px solid #35408e"
                                  : "2px solid transparent",
                                transition: "all 0.2s",
                              }}
                            >
                              <img
                                src={option.icon}
                                alt=""
                                className="moderator-history-filter-option-icon"
                                style={{
                                  width: "20px",
                                  height: "20px",
                                  marginRight: "15px",
                                  filter:
                                    activeFilter === option.value
                                      ? "brightness(0) saturate(100%) invert(28%) sepia(80%) saturate(1000%) hue-rotate(215deg) brightness(95%) contrast(90%)"
                                      : "brightness(0) saturate(100%) invert(25%) sepia(15%) saturate(1000%) hue-rotate(200deg) brightness(95%) contrast(90%)",
                                }}
                              />
                              {option.label}
                            </button>
                          ))}
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              )}
              {filterModalOpen && (
                <div
                  className="modal-backdrop fade show"
                  style={{
                    position: "fixed",
                    top: 0,
                    left: 0,
                    width: "100vw",
                    height: "100vh",
                    background: "rgba(0,0,0,0.18)",
                    zIndex: 3999,
                  }}
                ></div>
              )}

              {/* History list section */}
              <div
                className="moderator-history-card-list"
                style={{
                  flex: '1 1 auto',
                  minHeight: 0,
                  display: 'flex',
                  flexDirection: 'column',
                  justifyContent: 'flex-start',
                  overflowY: 'auto',
                  padding: '10px 12px 10px 0',
                  marginRight: '-12px'
                }}
              >
                {activeFilter === "dailylog" ? (
                  <DailyLogHistory
                    onViewDetails={handleViewDetails}
                    searchTerm={searchTerm}
                  />
                ) : activeFilter === "request" ? (
                  <RequestHistory
                    onViewDetails={handleViewDetails}
                    searchTerm={searchTerm}
                  />
                ) : activeFilter === "approval" ? (
                  <ApprovalHistory
                    onVerify={handleVerify}
                    searchTerm={searchTerm}
                  />
                ) : null}
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Details modal */}
      {selectedItem && (
        <div className="modal fade show" style={{ display: "block" }}>
          <div className="modal-dialog modal-dialog-centered">
            <div className="modal-content" style={{ borderRadius: "20px" }}>
              <div
                className="modal-header"
                style={{ borderBottom: "none", position: "relative" }}
              >
                <h5 className="modal-title" style={{ fontWeight: 700 }}>
                  {selectedItem.studentName || selectedItem.name}
                </h5>
                <span
                  style={{
                    position: "absolute",
                    right: "18px",
                    top: "18px",
                    fontSize: "22px",
                    cursor: "pointer",
                    color: "#888",
                  }}
                  onClick={() => setSelectedItem(null)}
                  aria-label="Close"
                  title="Close"
                >
                  &#10005;
                </span>
              </div>
              <div className="modal-body" style={{ paddingBottom: 0 }}>
                {selectedItem.name && (
                  <div style={{ fontSize: "16px", marginBottom: "10px" }}>
                    <strong>Faculty:</strong> {selectedItem.name}
                  </div>
                )}
                {selectedItem.time && (
                  <>
                    <div style={{ fontSize: "16px", marginBottom: "10px" }}>
                      <strong>Date:</strong>{" "}
                      {formatDateMMDDYYYY(selectedItem.time)}
                    </div>
                    <div style={{ fontSize: "16px", marginBottom: "10px" }}>
                      <strong>Time:</strong>{" "}
                      {selectedItem.time.split(" ")[1] ||
                        selectedItem.time.split(" - ")[1] ||
                        "00:00 am"}
                    </div>
                  </>
                )}
                {selectedItem.reason && (
                  <div style={{ fontSize: "16px", marginBottom: "10px" }}>
                    <strong>Reason:</strong> {selectedItem.reason}
                  </div>
                )}
                {activeFilter === "request" && (
                  <div style={{ fontSize: "16px", marginBottom: "10px" }}>
                    <strong>Status:</strong> {selectedItem.status ? selectedItem.status.charAt(0).toUpperCase() + selectedItem.status.slice(1).toLowerCase() : ""}
                  </div>
                )}
              </div>
              <div className="modal-footer" style={{ borderTop: "none" }}></div>
            </div>
          </div>
        </div>
      )}
      {selectedItem && <div className="modal-backdrop fade show"></div>}
    </div>
  );
};

export default ModeratorHistory;