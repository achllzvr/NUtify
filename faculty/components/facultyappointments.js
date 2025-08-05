const facultyStudentData = [
  { name: "Beatriz Solis", department: "Student - SACE", time: "June 15 - 00:00 am", status: "accepted", avatar: "../tabler-avatars-1.0.0/jpg/1c9a4dd0bbd964e3eecbd40caf3b7e37.jpg" },
  { name: "John Clarenz Dimazana", department: "Student - SACE", time: "June 16 - 10:00 am", status: "accepted", avatar: "../tabler-avatars-1.0.0/jpg/c33237da3438494d1abc67166196484e.jpg" },
  { name: "Kriztopher Kier Estioco", department: "Student - SACE", time: "June 18 - 02:00 pm", status: "accepted", avatar: "../tabler-avatars-1.0.0/jpg/8940e8ea369def14e82f05a5fee994b9.jpg" },
  { name: "Niel Cerezo", department: "Student - SACE", time: "June 19 - 11:00 am", status: "accepted", avatar: "../tabler-avatars-1.0.0/jpg/237d3876ef98d5364ed1326813f4ed5b.jpg" }
];

function createFacultyAppointmentItem(item) {
  return `
    <div class="appointment-item history-item" data-status="${item.status}">
      <div class="appointment-avatar">
        <img src="${item.avatar}" alt="${item.name}" class="avatar-img" />
      </div>
      <div class="appointment-info">
        <div class="appointment-name history-name">${item.name}</div>
        <div class="appointment-details history-details">${item.department}</div>
        <div class="appointment-time">${item.time}</div>
        <button class="see-more-btn">See More</button>
      </div>
    </div>
  `;
}

function createFacultyAppointments() {
  const appointmentItems = facultyStudentData.map(item => createFacultyAppointmentItem(item)).join('');

  return `
    <div class="main-content">
      <div class="content-container">
        <div class="left-column">
          <div class="history-section" style="margin-top:2.5em;">
            <div class="section-header">
              <h2>Upcoming Student Appointments</h2>
            </div>
            <div class="history-card-list appointment-list">
              ${appointmentItems}
            </div>
          </div>
        </div>
      </div>
    </div>
  `;
}

// Initialize faculty appointments when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
  document.getElementById('faculty-main-content-container').innerHTML = createFacultyAppointments();
});
