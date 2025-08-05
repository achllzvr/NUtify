function createHomeModals() {
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

// Initialize home modals when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
  document.getElementById('modals-container').innerHTML = createHomeModals();
});
