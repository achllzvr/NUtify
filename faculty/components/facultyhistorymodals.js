function createFacultyHistoryModals() {
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

    <div class="modal fade" id="filterModal" tabindex="-1" aria-labelledby="filterModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="filterModalLabel">Filter History</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <div class="filter-modal-options">
              <div class="filter-option selected" data-filter="all">
                <img src="../feather/list.svg" alt="All" class="filter-option-icon" />
                <span>All</span>
              </div>
              <div class="filter-option" data-filter="pending">
                <img src="../feather/clock.svg" alt="Pending" class="filter-option-icon" />
                <span>Pending</span>
              </div>
              <div class="filter-option" data-filter="accepted">
                <img src="../feather/thumbs-up.svg" alt="Accepted" class="filter-option-icon" />
                <span>Accepted</span>
              </div>
              <div class="filter-option" data-filter="completed">
                <img src="../feather/check-circle.svg" alt="Completed" class="filter-option-icon" />
                <span>Completed</span>
              </div>
              <div class="filter-option" data-filter="missed">
                <img src="../feather/alert-circle.svg" alt="Missed" class="filter-option-icon" />
                <span>Missed</span>
              </div>
              <div class="filter-option" data-filter="cancelled">
                <img src="../feather/x-circle.svg" alt="Cancelled" class="filter-option-icon" />
                <span>Cancelled</span>
              </div>
              <div class="filter-option" data-filter="declined">
                <img src="../feather/slash.svg" alt="Declined" class="filter-option-icon" />
                <span>Declined</span>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-primary" id="filterModalBtn">Apply Filter</button>
          </div>
        </div>
      </div>
    </div>
  `;
}

// Initialize faculty history modals when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
  document.getElementById('faculty-history-modals-container').innerHTML = createFacultyHistoryModals();
});
