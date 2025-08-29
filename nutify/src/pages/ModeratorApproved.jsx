import React, { useState } from 'react';
import Header from '../components/Header';
import Sidebar from '../components/Sidebar';
import ModeratorApprovedHistory from '../components/ModeratorApprovedCard';

const ModeratorApproved = () => {
  // Add search state
  const [searchValue, setSearchValue] = useState('');

  // Handler for search input change
  const handleSearchChange = value => setSearchValue(value);

  // Handler for search action (optional: could trigger filtering, but filtering will be live)
  const handleSearch = () => {};

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
          <ModeratorApprovedHistory searchValue={searchValue} />
        </div>
      </div>
    </div>
  );
};

export default ModeratorApproved;
