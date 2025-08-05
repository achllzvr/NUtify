function createFacultyModals() {
  return `
    <div class="modal fade" id="historyDetailsModal" tabindex="-1" aria-labelledby="historyDetailsModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content history-details-modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="historyDetailsModalLabel">Appointment Status</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <div class="history-details-modal-body"></div>
          </div>
          <div class="modal-footer"></div>
        </div>
      </div>
    </div>

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
                  <input type="text" class="form-control" id="username" value="Not John Doe" />
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
  `;
}

document.addEventListener('DOMContentLoaded', function() {
  document.getElementById('faculty-modals-container').innerHTML = createFacultyModals();
});
