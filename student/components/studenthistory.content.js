window.renderStudentHistoryPage = function(container) {
  container.innerHTML = `
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
        </div>
      </div>
    </div>
  `;
};
