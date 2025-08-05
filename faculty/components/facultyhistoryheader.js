function createFacultyHistoryHeader() {
  return `
    <div class="top-header">
      <div class="header-left">
        <h1 class="header-title">Consultation History</h1>
        <p class="header-subtitle">View and manage all your past and upcoming student consultation appointments</p>
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

document.addEventListener('DOMContentLoaded', function() {
  document.getElementById('faculty-history-header-container').innerHTML = createFacultyHistoryHeader();
});

