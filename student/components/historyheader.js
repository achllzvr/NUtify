function createHistoryHeader() {
  return `
    <div class="top-header">
      <div class="header-left">
        <h1 class="header-title">Consultation History</h1>
        <p class="header-subtitle">Track all your past and pending consultations appointments</p>
      </div>
      <div class="header-right">
        <div class="search-container">
          <div class="search-input-wrapper">
            <img src="../feather/menu.svg" alt="Menu" class="menu-icon" />
            <input type="text" class="search-input" placeholder="Search History" />
            <img src="../feather/search.svg" alt="Search" class="search-icon-end" />
          </div>
        </div>
      </div>
    </div>
  `;
}

// Initialize history header when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
  document.getElementById('history-header-container').innerHTML = createHistoryHeader();
});
