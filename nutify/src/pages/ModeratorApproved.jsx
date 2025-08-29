import React from 'react';
import Header from '../components/Header';
import Sidebar from '../components/Sidebar';

const ModeratorApproved = () => (
  <div style={{ display: 'flex' }}>
    <Sidebar userType="moderator" userName="Moderator" userRole="Moderator" />
    <div style={{ flex: 1 }}>
      <Header
        title="Hello, Moderator!"
        subtitle="Manage your appointments and consultations in one place"
        searchPlaceholder="Search User"
        searchValue=""
        onSearchChange={() => {}}
        onSearch={() => {}}
      />
      {/* Page content goes here */}
    </div>
  </div>
);

export default ModeratorApproved;
