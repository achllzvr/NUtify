import React, { useState } from 'react';
import searchIcon from '../assets/icons/search.svg';

const Header = ({ title, subtitle, searchPlaceholder, searchValue, onSearchChange, onSearch }) => (
  <div className="top-header">
    <div className="header-left">
      <h1 className="header-title">{title}</h1>
      <p className="header-subtitle">{subtitle}</p>
    </div>
    <div className="header-right">
      <div className="search-container">
        <div className="search-input-wrapper" style={{ position: 'relative' }}>
          <input
            type="text"
            className="search-input"
            placeholder={searchPlaceholder}
            value={searchValue}
            onChange={e => onSearchChange(e.target.value)}
            style={{ paddingLeft: '55px', borderRadius: '15px' }}
            onKeyDown={e => {
              if (e.key === 'Enter') {
                onSearch();
              }
            }}
          />
          <img
            src={searchIcon}
            alt="Search"
            className="search-icon-end"
            style={{ left: 18, width: 22, height: 22, cursor: 'pointer', position: 'absolute', top: '50%', transform: 'translateY(-50%)' }}
            onClick={onSearch}
          />
        </div>
      </div>
    </div>
  </div>
);

export default Header;