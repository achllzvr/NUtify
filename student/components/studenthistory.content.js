window.renderStudentHistoryPage = function(container) {
  container.innerHTML = `
    <div class="main-content">
      <div class="content-container">
        <!-- History List -->
        <div class="history-section">
          <!-- Filter Tabs -->
          <div class="filter-tabs" data-active="all">
            <button class="filter-btn active" data-filter="all">All</button>
            <button class="filter-btn" data-filter="pending">Pending</button>
            <button class="filter-btn" data-filter="accepted">Accepted</button>
            <button class="filter-btn" data-filter="completed">Completed</button>
            <button class="filter-btn" data-filter="missed">Missed</button>
            <button class="filter-btn" data-filter="cancelled">Cancelled</button>
            <button class="filter-btn" data-filter="declined">Declined</button>
          </div>
          <!-- You can add the rest of the history list here, or load dynamically -->
        </div>
      </div>
    </div>
  `;
};
