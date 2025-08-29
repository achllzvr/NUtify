import React, { useState } from 'react';
import Header from '../components/Header';
import Sidebar from '../components/Sidebar';
import ModeratorApprovedHistory from '../components/ModeratorApprovedCard';

const ModeratorApproved = () => {
  const [searchValue, setSearchValue] = useState('');
  const [activeSearch, setActiveSearch] = useState('');

  const handleSearchChange = value => setSearchValue(value);

  // Only update activeSearch when search is triggered
  const handleSearch = () => setActiveSearch(searchValue);

  return (
    <div style={{ display: 'flex' }}>
      <Sidebar userType="moderator" userName="Moderator" userRole="Moderator" />
      <div style={{ flex: 1 }}>
        <Header
          title="Hello, Moderator!"
          subtitle="Manage your appointments and consultations in one place"
          searchPlaceholder="Search User"
          searchValue={searchValue}
          onSearchChange={handleSearchChange}
          onSearch={handleSearch}
        />
        {/* Card Section */}
        <div style={{ marginBottom: '5em' }}>
          <ModeratorApprovedHistory searchValue={activeSearch} />
        </div>
      </div>
    </div>
  );
};

export default ModeratorApproved;
