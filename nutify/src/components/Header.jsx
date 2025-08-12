import React, { useState } from 'react';
import menuIcon from '../assets/icons/menu.svg';
import searchIcon from '../assets/icons/search.svg';

const Header = ({ title, subtitle, searchPlaceholder, onSearch }) => {
  const [searchTerm, setSearchTerm] = useState('');

  const handleSearchChange = (e) => {
    const value = e.target.value;
    setSearchTerm(value);
    if (onSearch) {
      onSearch(value);
    }
  };

  const handleSearchSubmit = (e) => {
    if (e.key === 'Enter') {
      e.preventDefault();
      if (onSearch) {
        onSearch(searchTerm);
      }
    }
  };

  const handleSearchClick = () => {
    if (onSearch) {
      onSearch(searchTerm);
    }
  };

  return (
    <div className="top-header">
      <div className="header-left">
        <h1 className="header-title">{title}</h1>
        <p className="header-subtitle">{subtitle}</p>
      </div>
      <div className="header-right">
        <div className="search-container">
          <div className="search-input-wrapper">
            <img src={menuIcon} alt="Menu" className="menu-icon" />
            <input
              type="text"
              className="search-input"
              placeholder={searchPlaceholder}
              value={searchTerm}
              onChange={handleSearchChange}
              onKeyPress={handleSearchSubmit}
            />
            <img
              src={searchIcon}
              alt="Search"
              className="search-icon-end"
              onClick={handleSearchClick}
            />
          </div>
        </div>
      </div>
    </div>
  );
};

export default Header;