function createFacultyHistorySidebar() {
  return `
    <div class="sidebar" id="sidebar">
      <div class="sidebar-content">
        <div class="sidebar-header">
          <div class="sidebar-logo">
            <img src="../img/NUtifywhite.png" alt="NUtify" class="logo" />
            <div class="chevron-icon" id="menuToggle">
              <img src="../feather/chevron-left.svg" alt="Collapse" class="icon" />
            </div>
          </div>
          <div class="sidebar-icon menu-burger" id="menuToggleBurger">
            <img src="../feather/menu.svg" alt="Menu" class="icon" />
          </div>
        </div>

        <div class="sidebar-nav">
          <div class="sidebar-icon">
            <img src="../feather/home.svg" alt="Home" class="icon" />
            <span class="nav-text">Home</span>
          </div>
          <div class="sidebar-icon active">
            <img src="../feather/mail.svg" alt="History" class="icon" />
            <span class="nav-text">History</span>
          </div>
        </div>

        <div class="sidebar-bottom">
          <div class="user-info">
            <div class="sidebar-avatar">
              <img src="../tabler-avatars-1.0.0/jpg/237d3876ef98d5364ed1326813f4ed5b.jpg" alt="Avatar" class="avatar" />
            </div>
            <div class="user-details">
              <div class="user-name">Not John Doe</div>
              <div class="user-role">Faculty - SACE</div>
            </div>
            <div class="settings-icon" id="settingsToggle">
              <img src="../feather/settings.svg" alt="Settings" class="icon" />
            </div>
          </div>
        </div>
      </div>

      <div class="settings-dropdown" id="settingsDropdown">
        <a href="#" class="dropdown-item">Edit Profile Details</a>
        <a href="forgot.html" class="dropdown-item">Edit Available Times</a>
        <a href="../auth/forgot.html" class="dropdown-item">Forgot Password</a>
        <a href="#" class="dropdown-item">Logout</a>
      </div>
    </div>
  `;
}

document.addEventListener('DOMContentLoaded', function() {
  document.getElementById('faculty-history-sidebar-container').innerHTML = createFacultyHistorySidebar();
  // Remove sidebar transition for initial load and navigation
  const sidebar = document.getElementById('sidebar');
  sidebar.classList.add('no-transition');
  const isExpanded = localStorage.getItem('sidebarExpanded') === 'true';
  if (isExpanded) {
    sidebar.classList.add('expanded');
  }
  // No sliding animation at all
  const chevron = document.getElementById('menuToggle');
  if (chevron) {
    chevron.onclick = function () {
      sidebar.classList.toggle('expanded');
      localStorage.setItem('sidebarExpanded', sidebar.classList.contains('expanded'));
    };
  }
});
