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

function createFacultyList() {
  const facultyList = facultyData.map(faculty => createFacultyItem(faculty)).join('');

  return `
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
  `;
}

document.addEventListener('DOMContentLoaded', function() {
  setTimeout(() => {
    document.getElementById('faculty-container').innerHTML = createFacultyList();
  }, 100);
});