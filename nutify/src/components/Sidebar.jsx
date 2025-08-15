import React, { useState, useEffect } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import logo from '../assets/images/NUtifywhite.png';
import chevronLeftIcon from '../assets/icons/chevron-left.svg';
import menuIcon from '../assets/icons/menu.svg';
import homeIcon from '../assets/icons/home.svg';
import inboxIcon from '../assets/icons/inbox.svg';
import settingsIcon from '../assets/icons/settings.svg';

const getInitialSidebarState = () => {
  if (typeof window !== 'undefined') {
    const savedState = localStorage.getItem('sidebarExpanded');
    return savedState === 'true';
  }
  return false;
};

const Sidebar = ({ userType, userName, userRole, userAvatar }) => {
  // Load sidebar state BEFORE first render
  const [isExpanded, setIsExpanded] = useState(getInitialSidebarState);
  const [showSettingsDropdown, setShowSettingsDropdown] = useState(false);
  const [shouldAnimate, setShouldAnimate] = useState(false); // controls CSS transition
  const navigate = useNavigate();
  const location = useLocation();

  // After first mount, enable animation for subsequent toggles
  useEffect(() => {
    setShouldAnimate(true);
  }, []);

  // Save sidebar state to localStorage
  const saveSidebarState = (expanded) => {
    localStorage.setItem('sidebarExpanded', expanded);
  };

  const toggleSidebar = () => {
    setIsExpanded((prev) => {
      saveSidebarState(!prev);
      return !prev;
    });
  };

  const toggleSettingsDropdown = (e) => {
    e.stopPropagation();
    setShowSettingsDropdown(!showSettingsDropdown);
  };

  const handleNavigation = (path) => {
    navigate(path);
  };

  const handleSettingsAction = (action) => {
    setShowSettingsDropdown(false);
    switch (action) {
      case 'profile':
        // Handle profile edit
        break;
      case 'password':
        navigate('/forgot-password');
        break;
      case 'logout':
        navigate('/login');
        break;
      default:
        break;
    }
  };

  useEffect(() => {
    const handleClickOutside = (e) => {
      if (
        showSettingsDropdown &&
        !e.target.closest('.settings-dropdown') &&
        !e.target.closest('.settings-icon')
      ) {
        setShowSettingsDropdown(false);
      }
    };

    document.addEventListener('click', handleClickOutside);
    return () => document.removeEventListener('click', handleClickOutside);
  }, [showSettingsDropdown]);

  useEffect(() => {
    const handleMobileClickOutside = (e) => {
      if (
        window.innerWidth <= 768 &&
        isExpanded &&
        !e.target.closest('.sidebar')
      ) {
        setIsExpanded(false);
        saveSidebarState(false);
      }
    };

    document.addEventListener('click', handleMobileClickOutside);
    return () => document.removeEventListener('click', handleMobileClickOutside);
  }, [isExpanded]);

  const isActive = (path) => location.pathname === path;

  const getSidebarIconClass = (path) => {
    let base = 'sidebar-icon';
    if (isActive(path)) {
      base += ' active active-animate';
    }
    return base;
  };

  return (
    <div
      className={`sidebar${isExpanded ? ' expanded' : ''}${shouldAnimate ? ' animate' : ''}`}
    >
      <div className="sidebar-content">
        <div className="sidebar-header">
          <div className="sidebar-logo">
            <img src={logo} alt="NUtify" className="logo" />
            <div className="chevron-icon" onClick={toggleSidebar}>
              <img src={chevronLeftIcon} alt="Collapse" className="icon" />
            </div>
          </div>
          <div className="sidebar-icon menu-burger" onClick={toggleSidebar}>
            <img src={menuIcon} alt="Menu" className="icon" />
          </div>
        </div>

        <div className="sidebar-nav">
          <div
            key={`home-${isActive(`/${userType}/home`)}`}
            className={getSidebarIconClass(`/${userType}/home`)}
            onClick={() => handleNavigation(`/${userType}/home`)}
          >
            <img src={homeIcon} alt="Home" className="icon" />
            <span className="nav-text">Home</span>
          </div>
          <div
            key={`history-${isActive(`/${userType}/history`)}`}
            className={getSidebarIconClass(`/${userType}/history`)}
            onClick={() => handleNavigation(`/${userType}/history`)}
          >
            <img src={inboxIcon} alt={userType === 'moderator' ? 'Inbox' : 'History'} className="icon" />
            <span className="nav-text">
              {userType === 'moderator' ? 'Inbox' : 'History'}
            </span>
          </div>
        </div>

        <div className="sidebar-bottom">
          <div className="user-info">
            <div className="sidebar-avatar">
              <img src={userAvatar} alt="Avatar" className="avatar" />
            </div>
            <div className="user-details">
              <div className="user-name">{userName}</div>
              <div className="user-role">{userRole}</div>
            </div>
            <div className="settings-icon" onClick={toggleSettingsDropdown}>
              <img src={settingsIcon} alt="Settings" className="icon" />
            </div>
          </div>
        </div>
      </div>

      <div className={`settings-dropdown${showSettingsDropdown ? ' show' : ''}`}>
        <div className="dropdown-item" onClick={() => handleSettingsAction('profile')}>
          Edit Profile Details
        </div>
        <div className="dropdown-item" onClick={() => handleSettingsAction('password')}>
          Forgot Password
        </div>
        <div className="dropdown-item" onClick={() => handleSettingsAction('logout')}>
          Logout
        </div>
      </div>
    </div>
  );
};

export default Sidebar;

// Add the following CSS to your sidebar stylesheet:
/*
.sidebar-icon {
  transition: background 0.3s, transform 0.3s;
}
.sidebar-icon.active {
  background: #2d3748; // example highlight
  transform: scale(1.05);
}
.sidebar-icon.active-animate {
  animation: pop-in 0.25s;
}
@keyframes pop-in {
  0% { transform: scale(0.9); opacity: 0.7; }
  60% { transform: scale(1.08); opacity: 1; }
  100% { transform: scale(1.05); opacity: 1; }
}
*/