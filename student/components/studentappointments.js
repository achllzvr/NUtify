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

function createHomeAppointments() {
  const upcomingAppointments = appointmentData.upcoming.map(app => createAppointmentItem(app)).join('');
  const recentAppointments = appointmentData.recent.map(app => createAppointmentItem(app, true)).join('');

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
        <div id="faculty-container"></div>
      </div>
    </div>
  `;
}

document.addEventListener('DOMContentLoaded', function() {
  document.getElementById('main-content-container').innerHTML = createHomeAppointments();
});
