function createFacultyHeader() {
  return `
    <div class="top-header">
      <div class="header-left">
        <h1 class="header-title">Hello, Not John Doe</h1>
        <p class="header-subtitle">Manage all your student appointments and consultations in one place</p>
      </div>
      <div class="header-right">
        <div class="search-container">
          <div class="search-input-wrapper">
            <img src="../feather/menu.svg" alt="Menu" class="menu-icon" />
            <input type="text" class="search-input" placeholder="Search Students" />
            <img src="../feather/search.svg" alt="Search" class="search-icon-end" />
          </div>
        </div>
      </div>
    </div>
  `;
}

document.addEventListener('DOMContentLoaded', function() {
  document.getElementById('faculty-header-container').innerHTML = createFacultyHeader();
});

