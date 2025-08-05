const appointmentData = {
  upcoming: [
    { name: "Jei Pastrana", department: "Faculty - SACE", time: "June 15 - 09:00 am", avatar: "../tabler-avatars-1.0.0/jpg/1c9a4dd0bbd964e3eecbd40caf3b7e37.jpg" },
    { name: "Irene Balmes", department: "Faculty - SACE", time: "June 14 - 09:00 am", avatar: "../tabler-avatars-1.0.0/jpg/c33237da3438494d1abc67166196484e.jpg" },
    { name: "Jei Pastrana", department: "Faculty - SACE", time: "June 15 - 09:00 am", avatar: "../tabler-avatars-1.0.0/jpg/1c9a4dd0bbd964e3eecbd40caf3b7e37.jpg" }
  ],
  recent: [
    { title: "Appointment done - June 24, 2025 - 00:00", details: "Jei Pastrana - Faculty - SACE", avatar: "../tabler-avatars-1.0.0/jpg/1c9a4dd0bbd964e3eecbd40caf3b7e37.jpg" },
    { title: "Appointment done - June 18, 2025 - 00:00", details: "Irene Balmes - Faculty - SACE", avatar: "../tabler-avatars-1.0.0/jpg/c33237da3438494d1abc67166196484e.jpg" },
    { title: "Appointment done - June 13, 2025 - 00:00", details: "Jei Pastrana - Faculty - SACE", avatar: "../tabler-avatars-1.0.0/jpg/1c9a4dd0bbd964e3eecbd40caf3b7e37.jpg" }
  ]
};

const facultyData = [
  { name: "Jayson Guia", department: "Faculty - SACE", status: "online", avatar: "../tabler-avatars-1.0.0/jpg/d447a9fd5010652f6c0911fbe9c662c6.jpg" },
  { name: "Jei Pastrana", department: "Faculty - SACE", status: "offline", avatar: "../tabler-avatars-1.0.0/jpg/1c9a4dd0bbd964e3eecbd40caf3b7e37.jpg" },
  { name: "Irene Balmes", department: "Faculty - SACE", status: "online", avatar: "../tabler-avatars-1.0.0/jpg/c33237da3438494d1abc67166196484e.jpg" },
  { name: "Carlo Torres", department: "Faculty - SACE", status: "offline", avatar: "../tabler-avatars-1.0.0/jpg/8940e8ea369def14e82f05a5fee994b9.jpg" },
  { name: "Archie Menisis", department: "Faculty - SACE", status: "online", avatar: "../tabler-avatars-1.0.0/jpg/78529e2ec8eb4a2eb2fb961e04915b0a.jpg" },
  { name: "Michael Joseph Aramil", department: "Faculty - SACE", status: "offline", avatar: "../tabler-avatars-1.0.0/jpg/869f67a992bb6ca4cb657fb9fc634893.jpg" },
  { name: "Erwin De Castro", department: "Faculty - SACE", status: "online", avatar: "../tabler-avatars-1.0.0/jpg/92770c61168481c94e1ba43df7615fd8.jpg" },
  { name: "Joel Enriquez", department: "Faculty - SACE", status: "offline", avatar: "../tabler-avatars-1.0.0/jpg/944c5ba154e0489274504f38d01bcfaf.jpg" },
  { name: "Bernie Fabito", department: "Faculty - SACE", status: "online", avatar: "../tabler-avatars-1.0.0/jpg/78529e2ec8eb4a2eb2fb961e04915b0a.jpg" }
];

function createSidebar() {
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
          <div class="sidebar-icon active">
            <img src="../feather/home.svg" alt="Home" class="icon" />
            <span class="nav-text">Home</span>
          </div>
          <div class="sidebar-icon">
            <img src="../feather/mail.svg" alt="History" class="icon" />
            <span class="nav-text">History</span>
          </div>
        </div>

        <div class="sidebar-bottom">
          <div class="user-info">
            <div class="sidebar-avatar">
              <img src="../tabler-avatars-1.0.0/jpg/1c9a4dd0bbd964e3eecbd40caf3b7e37.jpg" alt="Avatar" class="avatar" />
            </div>
            <div class="user-details">
              <div class="user-name">John Doe</div>
              <div class="user-role">Student - SACE</div>
            </div>
            <div class="settings-icon" id="settingsToggle">
              <img src="../feather/settings.svg" alt="Settings" class="icon" />
            </div>
          </div>
        </div>
      </div>

      <div class="settings-dropdown" id="settingsDropdown">
        <a href="#" class="dropdown-item">Edit Profile Details</a>
        <a href="../auth/forgot.html" class="dropdown-item">Forgot Password</a>
        <a href="#" class="dropdown-item">Logout</a>
      </div>
    </div>
  `;
}

function createHeader() {
  return `
    <div class="top-header">
      <div class="header-left">
        <h1 class="header-title">Hello, John Doe</h1>
        <p class="header-subtitle">Manage your appointments and consultations in one place</p>
      </div>
      <div class="header-right">
        <div class="search-container">
          <div class="search-input-wrapper">
            <img src="../feather/menu.svg" alt="Menu" class="menu-icon" />
            <input type="text" class="search-input" placeholder="Search Faculty" />
            <img src="../feather/search.svg" alt="Search" class="search-icon-end" />
          </div>
        </div>
      </div>
    </div>
  `;
}

function createAppointmentItem(appointment, isRecent = false) {
  if (isRecent) {
    return `
      <div class="appointment-item">
        <div class="appointment-avatar">
          <img src="${appointment.avatar}" alt="${appointment.details}" class="avatar-img" />
        </div>
        <div class="appointment-info">
          <div class="appointment-name">${appointment.title}</div>
          <div class="appointment-details">${appointment.details}</div>
        </div>
      </div>
    `;
  }
  
  return `
    <div class="appointment-item">
      <div class="appointment-avatar">
        <img src="${appointment.avatar}" alt="${appointment.name}" class="avatar-img" />
      </div>
      <div class="appointment-info">
        <div class="appointment-name">${appointment.name}</div>
        <div class="appointment-details">${appointment.department}</div>
        <div class="appointment-time">${appointment.time}</div>
      </div>
    </div>
  `;
}

function createFacultyItem(faculty) {
  return `
    <div class="faculty-item">
      <div class="faculty-avatar">
        <img src="${faculty.avatar}" alt="${faculty.name}" class="avatar-img" />
      </div>
      <div class="faculty-info">
        <div class="faculty-name">${faculty.name}</div>
        <div class="faculty-department">${faculty.department}</div>
      </div>
      <div class="faculty-status ${faculty.status}"></div>
    </div>
  `;
}

function createMainContent() {
  const upcomingAppointments = appointmentData.upcoming.map(app => createAppointmentItem(app)).join('');
  const recentAppointments = appointmentData.recent.map(app => createAppointmentItem(app, true)).join('');
  const facultyList = facultyData.map(faculty => createFacultyItem(faculty)).join('');

  return `
    <div class="main-content">
      <div class="content-container">
        <div class="left-column">
          <div class="appointment-section" id="upcomingAppointments">
            <div class="section-header">
              <h2>Your Upcoming Appointments</h2>
              <button class="see-more-btn" id="seeMoreUpcomingBtn">See More</button>
            </div>
            <div class="appointment-list">
              ${upcomingAppointments}
            </div>
          </div>

          <div class="appointment-section">
            <div class="section-header">
              <h2>Your Most Recent</h2>
              <button class="see-more-btn" id="seeMoreCompletedBtn">See More</button>
            </div>
            <div class="appointment-list">
              ${recentAppointments}
            </div>
          </div>
        </div>

        <div class="right-column">
          <div class="faculty-section">
            <div class="section-header">
              <h2>All Faculty List</h2>
            </div>
            <div class="faculty-list">
              ${facultyList}
            </div>
          </div>
        </div>
      </div>
    </div>
  `;
}

function createModals() {
  return `
    <div class="modal fade" id="profileEditModal" tabindex="-1" aria-labelledby="profileEditModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="profileEditModalLabel">Edit Profile Details</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <div class="profile-edit-form">
              <div class="mb-3">
                <label for="username" class="form-label">Username</label>
                <div class="input-group">
                  <img src="../feather/user.svg" alt="User" class="input-icon" />
                  <input type="text" class="form-control" id="username" value="John Doe" />
                </div>
              </div>
              <div class="department-notice">
                <p class="notice-text">If you wish to change your department, first name, or last name. Please go to the nearest admin.</p>
                <p class="notice-link"><a href="#" class="text-primary">See Moderator/ Admin List.</a></p>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-primary" id="saveProfileBtn">Save</button>
          </div>
        </div>
      </div>
    </div>

    <div class="modal fade" id="scheduleModal" tabindex="-1" aria-labelledby="scheduleModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header" style="border-bottom: none">
            <h5 class="modal-title" id="scheduleModalLabel">
              <span id="scheduleFacultyName">Faculty's available times...</span>
            </h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body" style="padding-bottom: 0">
            <div class="schedule-times-container">
              <div class="row g-3" id="scheduleTimesRow"></div>
            </div>
          </div>
          <div class="modal-footer" style="border-top: none">
            <button type="button" class="btn btn-primary schedule-btn" id="scheduleBtn" style="width: 100%; border-radius: 30px; font-size: 18px" disabled>Schedule</button>
          </div>
        </div>
      </div>
    </div>

    <div class="modal fade" id="successModal" tabindex="-1" aria-labelledby="successModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius: 20px">
          <div class="modal-body text-center" style="padding: 40px 30px 30px 30px">
            <h4 style="font-weight: 700; margin-bottom: 18px">Requested Appointment Schedule!</h4>
            <div style="font-size: 16px; margin-bottom: 32px">Please check your History for the Confirmation of your scheduled appointment.</div>
            <button type="button" class="btn btn-primary w-100" id="goBackBtn" style="border-radius: 30px; font-size: 20px; padding: 12px 0">Go Back</button>
          </div>
        </div>
      </div>
    </div>
  `;
}

document.addEventListener('DOMContentLoaded', function() {
  document.getElementById('sidebar-container').innerHTML = createSidebar();
  document.getElementById('header-container').innerHTML = createHeader();
  document.getElementById('main-content-container').innerHTML = createMainContent();
  document.getElementById('modals-container').innerHTML = createModals();
});
  document.getElementById('main-content-container').innerHTML = createMainContent();
  document.getElementById('modals-container').innerHTML = createModals();
