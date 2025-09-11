import React, { useState } from 'react';
import Header from '../components/Header';
import Sidebar from '../components/Sidebar';
import ModeratorApprovedHistory from '../components/ModeratorApprovedCard';

const ModeratorApproved = () => {
  const [searchValue, setSearchValue] = useState('');
  const [activeSearch, setActiveSearch] = useState('');

  const handleSearchChange = value => setSearchValue(value);
  
  const handleSearch = () => setActiveSearch(searchValue);

  return (
    <div>
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
        searchValue={searchValue}
        onSearchChange={handleSearchChange}
        onSearch={handleSearch}
      />

      <div>
        {/* Card Section */}
        <div style={{ marginBottom: '5em' }}>
          <ModeratorApprovedHistory searchValue={activeSearch} />
        </div>
      </div>
    </div>
  );
};

export default ModeratorApproved;
