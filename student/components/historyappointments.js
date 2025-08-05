const historyData = [
  { name: "Jei Pastrana", department: "Faculty - SACE", time: "June 13 - 00:00 am", status: "pending", avatar: "../tabler-avatars-1.0.0/jpg/1c9a4dd0bbd964e3eecbd40caf3b7e37.jpg" },
  { name: "Jayson Guia", department: "Faculty - SACE", time: "June 7 - 00:00 am", status: "missed", avatar: "../tabler-avatars-1.0.0/jpg/d447a9fd5010652f6c0911fbe9c662c6.jpg" },
  { name: "Irene Balmes", department: "Faculty - SACE", time: "May 22 - 00:00 am", status: "completed", avatar: "../tabler-avatars-1.0.0/jpg/c33237da3438494d1abc67166196484e.jpg" },
  { name: "Carlo Torres", department: "Faculty - SACE", time: "May 4 - 00:00 am", status: "cancelled", avatar: "../tabler-avatars-1.0.0/jpg/8940e8ea369def14e82f05a5fee994b9.jpg" },
  { name: "Carlo Torres", department: "Faculty - SACE", time: "May 1 - 00:00 am", status: "declined", avatar: "../tabler-avatars-1.0.0/jpg/8940e8ea369def14e82f05a5fee994b9.jpg" },
  { name: "Jei Pastrana", department: "Faculty - SACE", time: "June 15 - 00:00 am", status: "accepted", avatar: "../tabler-avatars-1.0.0/jpg/1c9a4dd0bbd964e3eecbd40caf3b7e37.jpg" }
];

function createHistoryItem(item) {
  return `
    <div class="appointment-item history-item" data-status="${item.status}">
      <div class="appointment-avatar">
        <img src="${item.avatar}" alt="${item.name}" class="avatar-img" />
      </div>
      <div class="appointment-info">
        <div class="appointment-name history-name">${item.name}</div>
        <div class="appointment-details history-details">${item.department}</div>
        <div class="appointment-time">${item.time}</div>
        <span class="history-status-mobile status-${item.status}">${item.status.charAt(0).toUpperCase() + item.status.slice(1)}</span>
        <button class="see-more-btn">See More</button>
      </div>
      <div class="status">
        <span class="history-status status-${item.status}">${item.status.charAt(0).toUpperCase() + item.status.slice(1)}</span>
      </div>
    </div>
  `;
}

function createHistoryAppointments() {
  const historyItems = historyData.map(item => createHistoryItem(item)).join('');

  return `
    <div class="main-content">
      <div class="content-container">
        <div class="history-section">
          <div class="filter-tabs" data-active="all">
            <button class="filter-btn active" data-filter="all">All</button>
            <button class="filter-btn" data-filter="pending">Pending</button>
            <button class="filter-btn" data-filter="accepted">Accepted</button>
            <button class="filter-btn" data-filter="completed">Completed</button>
            <button class="filter-btn" data-filter="missed">Missed</button>
            <button class="filter-btn" data-filter="cancelled">Cancelled</button>
            <button class="filter-btn" data-filter="declined">Declined</button>
          </div>

          <button class="filter-mobile-btn" id="filterMobileBtn" data-bs-toggle="modal" data-bs-target="#filterModal">
            <img src="../feather/filter.svg" alt="Filter" class="filter-icon" />
            <span>Filter</span>
          </button>

          <div class="history-card-list appointment-list">
            ${historyItems}
          </div>
        </div>
      </div>
    </div>
  `;
}

document.addEventListener('DOMContentLoaded', function() {
  document.getElementById('history-main-content-container').innerHTML = createHistoryAppointments();
});
