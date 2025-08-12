document.addEventListener("DOMContentLoaded", function () {
  const sidebar = document.getElementById("sidebar");
  const menuToggle = document.getElementById("menuToggle");
  const menuToggleBurger = document.getElementById("menuToggleBurger");
  const settingsToggle = document.getElementById("settingsToggle");
  const settingsDropdown = document.getElementById("settingsDropdown");

  function saveSidebarState() {
    const isExpanded = sidebar.classList.contains("expanded");
    localStorage.setItem("sidebarExpanded", isExpanded);
  }

  function loadSidebarState() {
    const isExpanded = localStorage.getItem("sidebarExpanded") === "true";
    if (isExpanded) {
      sidebar.classList.add("expanded");
    }
  }

  loadSidebarState();

  function attachChevronListener() {
    const chevron = document.getElementById("menuToggle");
    if (chevron) {
      chevron.onclick = function () {
        sidebar.classList.toggle("expanded");
        saveSidebarState();
      };
    }
  }
  attachChevronListener();
  sidebar.addEventListener("transitionend", attachChevronListener);

  function attachBurgerListener() {
    const burger = document.getElementById("menuToggleBurger");
    if (burger) {
      burger.onclick = function () {
        sidebar.classList.toggle("expanded");
        saveSidebarState();
      };
    }
  }
  attachBurgerListener();
  sidebar.addEventListener("transitionend", attachBurgerListener);

  function attachSettingsListener() {
    const settings = document.getElementById("settingsToggle");
    if (settings) {
      settings.onclick = function (e) {
        e.stopPropagation();
        settingsDropdown.classList.toggle("show");
      };
    }
  }
  attachSettingsListener();
  sidebar.addEventListener("transitionend", attachSettingsListener);

  document.addEventListener("click", function (e) {
    if (
      !settingsToggle.contains(e.target) &&
      !settingsDropdown.contains(e.target)
    ) {
      settingsDropdown.classList.remove("show");
    }
  });

  const dropdownItems = document.querySelectorAll(".dropdown-item");
  dropdownItems.forEach((item) => {
    item.addEventListener("click", function () {
      const action = this.textContent.trim();
      switch (action) {
        case "Edit Profile Details":
          const profileModal = new bootstrap.Modal(
            document.getElementById("profileEditModal")
          );
          profileModal.show();
          break;
        case "Forgot Password":
          break;
        case "Logout":
          break;
      }
      settingsDropdown.classList.remove("show");
    });
  });

  const navItems = document.querySelectorAll(".sidebar-nav .sidebar-icon");
  navItems.forEach((item) => {
    item.addEventListener("click", function () {
      const navText = this.querySelector(".nav-text").textContent.trim();
      switch (navText) {
        case "Home":
          window.location.href = "studenthome.html";
          break;
        case "History":
          window.location.href = "studenthistory.html";
          break;
      }
    });
  });

  document.addEventListener("click", function (e) {
    if (
      window.innerWidth <= 768 &&
      !sidebar.contains(e.target) &&
      sidebar.classList.contains("expanded")
    ) {
      sidebar.classList.remove("expanded");
      saveSidebarState();
    }
  });

  const saveProfileBtn = document.getElementById("saveProfileBtn");
  if (saveProfileBtn) {
    saveProfileBtn.addEventListener("click", function () {
      const usernameInput = document.getElementById("username");
      const newUsername = usernameInput.value.trim();

      if (newUsername) {
        const userNameElement = document.querySelector(".user-name");
        if (userNameElement) {
          userNameElement.textContent = newUsername;
        }

        const profileModal = bootstrap.Modal.getInstance(
          document.getElementById("profileEditModal")
        );
        profileModal.hide();
      } else {
        alert("Please enter a valid username");
      }
    });
  }

  const searchInput = document.querySelector(".search-input");
  const searchIconEnd = document.querySelector(".search-icon-end");
  const menuIcon = document.querySelector(".menu-icon");

  if (searchInput) {
    searchInput.addEventListener("input", function () {
      const searchTerm = this.value.toLowerCase();
    });

    searchInput.addEventListener("keypress", function (e) {
      if (e.key === "Enter") {
        e.preventDefault();
        const searchTerm = this.value.toLowerCase();
      }
    });
  }

  if (searchIconEnd) {
    searchIconEnd.addEventListener("click", function () {
      const searchTerm = searchInput.value.toLowerCase();
    });
  }

  if (menuIcon) {
    menuIcon.addEventListener("click", function () {});
  }

  function handleFacultyListExpand() {
    const facultyList = document.querySelector(".faculty-list");
    if (facultyList && window.innerWidth <= 768) {
      facultyList.addEventListener("click", function (e) {
        const rect = this.getBoundingClientRect();
        const clickY = e.clientY;
        const pseudoElementTop = rect.bottom - 60;
        if (clickY >= pseudoElementTop && clickY <= rect.bottom) {
          e.preventDefault();
          this.classList.toggle("expanded");
        }
      });
    }
  }

  handleFacultyListExpand();
  window.addEventListener("resize", function () {
    handleFacultyListExpand();
  });

  const filterBtns = document.querySelectorAll(".filter-btn");
  const historyItems = document.querySelectorAll(".history-item");
  const filterTabs = document.querySelector(".filter-tabs");

  if (filterBtns.length > 0 && historyItems.length > 0) {
    filterTabs.setAttribute("data-active", "all");
    filterBtns.forEach((btn) => {
      btn.addEventListener("click", function () {
        filterBtns.forEach((b) => b.classList.remove("active"));
        this.classList.add("active");
        const filterValue = this.getAttribute("data-filter");
        const searchTerm = searchInput ? searchInput.value.toLowerCase() : "";
        filterTabs.setAttribute("data-active", filterValue);
        filterHistoryItems(filterValue, searchTerm);
      });
    });
  }

  const filterOptions = document.querySelectorAll(".filter-option");
  const filterModalBtn = document.getElementById("filterModalBtn");
  const filterMobileBtn = document.getElementById("filterMobileBtn");
  let currentMobileFilter = "all";

  if (filterOptions.length > 0) {
    filterOptions.forEach((option) => {
      option.addEventListener("click", function () {
        filterOptions.forEach((opt) => opt.classList.remove("selected"));
        this.classList.add("selected");
        currentMobileFilter = this.getAttribute("data-filter");
      });
    });
  }

  if (filterModalBtn) {
    filterModalBtn.addEventListener("click", function () {
      const searchTerm = searchInput ? searchInput.value.toLowerCase() : "";
      filterHistoryItems(currentMobileFilter, searchTerm);
      const selectedOption = document.querySelector(
        ".filter-option.selected span"
      );
      if (selectedOption && filterMobileBtn) {
        const buttonText = filterMobileBtn.querySelector("span");
        if (buttonText) {
          buttonText.textContent = selectedOption.textContent;
        }
      }
      const filterModal = bootstrap.Modal.getInstance(
        document.getElementById("filterModal")
      );
      if (filterModal) {
        filterModal.hide();
      }
    });
  }

  function filterHistoryItems(filterValue, searchTerm) {
    if (historyItems.length > 0) {
      historyItems.forEach((item) => {
        const itemStatus = item.getAttribute("data-status");
        const name = item
          .querySelector(".history-name")
          .textContent.toLowerCase();
        const details = item
          .querySelector(".history-details")
          .textContent.toLowerCase();
        const matchesFilter =
          filterValue === "all" || itemStatus === filterValue;
        const matchesSearch =
          !searchTerm ||
          name.includes(searchTerm) ||
          details.includes(searchTerm);
        if (matchesFilter && matchesSearch) {
          item.classList.remove("hidden");
          item.style.display = "flex";
        } else {
          item.classList.add("hidden");
          item.style.display = "none";
        }
      });
    }
  }

  if (searchInput && window.location.pathname.includes("studenthistory.html")) {
    searchInput.addEventListener("input", function () {
      const searchTerm = this.value.toLowerCase();
      let activeFilterValue = "all";
      const activeFilter = document.querySelector(".filter-btn.active");
      if (activeFilter) {
        activeFilterValue = activeFilter.getAttribute("data-filter");
      } else {
        activeFilterValue = currentMobileFilter;
      }
      filterHistoryItems(activeFilterValue, searchTerm);
    });
  }

  if (window.location.pathname.includes("studenthistory.html")) {
    const urlParams = new URLSearchParams(window.location.search);
    const filterParam = urlParams.get("filter");
    if (filterParam) {
      const filterBtn = document.querySelector(
        `.filter-btn[data-filter="${filterParam}"]`
      );
      if (filterBtn) {
        filterBtn.click();
      }
      const filterOption = document.querySelector(
        `.filter-option[data-filter="${filterParam}"]`
      );
      if (filterOption) {
        filterOption.classList.add("selected");
      }
    }
  }

  const seeMoreBtns = document.querySelectorAll(".see-more-btn");
  const historyDetailsModal = document.getElementById("historyDetailsModal");
  const historyDetailsModalBody = document.querySelector(
    ".history-details-modal-body"
  );

  const statusModalMap = {
    pending: {
      main: { text: "-", class: "pending" },
      secondary: [
        { text: "-", class: "secondary" },
        { text: "Pending - June 11; 6:00 pm", class: "secondary" },
      ],
    },
    completed: {
      main: { text: "Completed - June 13; 9:23 am", class: "completed" },
      secondary: [
        { text: "Accepted - June 12; 12:00 am", class: "secondary" },
        { text: "Pending - June 11; 6:00 pm", class: "secondary" },
      ],
    },
    accepted: {
      main: { text: "-", class: "pending" },
      secondary: [
        { text: "Accepted - June 13; 9:23 am", class: "accepted" },
        { text: "Pending - June 11; 6:00 pm", class: "secondary" },
      ],
    },
    missed: {
      main: { text: "Missed - June 13; 9:23 am", class: "missed" },
      secondary: [
        { text: "Accepted - June 12; 12:00 am", class: "secondary" },
        { text: "Pending - June 11; 6:00 pm", class: "secondary" },
      ],
    },
    declined: {
      main: { text: "-", class: "pending" },
      secondary: [
        { text: "Declined - June 13; 9:23 am", class: "declined" },
        { text: "Pending - June 11; 6:00 pm", class: "secondary" },
      ],
    },
    cancelled: {
      main: { text: "Cancelled - June 13; 9:23 am", class: "cancelled" },
      secondary: [
        { text: "Accepted - June 12; 12:00 am", class: "secondary" },
        { text: "Pending - June 11; 6:00 pm", class: "secondary" },
      ],
    },
  };

  seeMoreBtns.forEach((btn) => {
    btn.addEventListener("click", function () {
      const item = btn.closest(".history-item");
      const status = item.getAttribute("data-status");
      const name = item.querySelector(".history-name").textContent;
      const details = item.querySelector(".history-details").textContent;
      const time = item.querySelector(".appointment-time").textContent;

      let modalHtml = `
        <div class="history-details-modal-title">${name}</div>
        <div class="history-details-modal-time">${time}</div>
      `;

      let modalStatus = statusModalMap[status] || statusModalMap["pending"];
      if (status === "completed") {
        modalStatus = statusModalMap.completed;
      } else if (status === "missed") {
        modalStatus = statusModalMap.missed;
      } else if (status === "declined") {
        modalStatus = statusModalMap.declined;
      } else if (status === "cancelled") {
        modalStatus = statusModalMap.cancelled;
      } else if (status === "pending") {
        modalStatus = statusModalMap.pending;
      }

      modalHtml += `<div class="history-details-modal-status ${modalStatus.main.class}">${modalStatus.main.text}</div>`;

      if (modalStatus.secondary && modalStatus.secondary.length) {
        modalStatus.secondary.forEach((sec) => {
          modalHtml += `<div class="history-details-modal-status ${sec.class}">${sec.text}</div>`;
        });
      }

      if (historyDetailsModalBody) {
        historyDetailsModalBody.innerHTML = modalHtml;
      }

      if (historyDetailsModal) {
        const modalDialog = historyDetailsModal.querySelector(".modal-dialog");
        if (modalDialog) {
          modalDialog.classList.add("profile-modal-bg");
        }
      }

      const modalInstance = new bootstrap.Modal(historyDetailsModal);
      modalInstance.show();
    });
  });
});

const facultySchedules = {
  "Jayson Guia": [
    "Monday - 9:00 - 10:00",
    "Tuesday - 9:00 - 10:00",
    "Wednesday - 10:00 - 11:00",
    "Thursday - 1:00 - 2:00",
    "Friday - 9:00 - 10:00",
    "Friday - 2:00 - 3:00",
  ],
  "Jei Pastrana": [
    "Monday - 9:00 - 10:00",
    "Tuesday - 9:00 - 10:00",
    "Friday - 9:00 - 10:00",
  ],
  "Irene Balmes": [
    "Monday - 8:00 - 9:00",
    "Tuesday - 10:00 - 11:00",
    "Wednesday - 1:00 - 2:00",
    "Thursday - 3:00 - 4:00",
    "Friday - 11:00 - 12:00",
  ],
  "Carlo Torres": [
    "Monday - 7:00 - 8:00",
    "Tuesday - 8:00 - 9:00",
    "Wednesday - 9:00 - 10:00",
    "Thursday - 10:00 - 11:00",
    "Friday - 1:00 - 2:00",
    "Friday - 3:00 - 4:00",
    "Saturday - 9:00 - 10:00",
  ],
  "Archie Menisis": [
    "Monday - 9:00 - 10:00",
    "Tuesday - 9:00 - 10:00",
    "Wednesday - 9:00 - 10:00",
    "Thursday - 9:00 - 10:00",
    "Friday - 9:00 - 10:00",
  ],
  "Michael Joseph Aramil": [
    "Monday - 8:00 - 9:00",
    "Tuesday - 8:00 - 9:00",
    "Wednesday - 8:00 - 9:00",
    "Thursday - 8:00 - 9:00",
    "Friday - 8:00 - 9:00",
    "Saturday - 8:00 - 9:00",
  ],
  "Erwin De Castro": [
    "Monday - 10:00 - 11:00",
    "Tuesday - 10:00 - 11:00",
    "Wednesday - 10:00 - 11:00",
    "Thursday - 10:00 - 11:00",
    "Friday - 10:00 - 11:00",
  ],
  "Joel Enriquez": [
    "Monday - 2:00 - 3:00",
    "Tuesday - 2:00 - 3:00",
    "Wednesday - 2:00 - 3:00",
    "Thursday - 2:00 - 3:00",
    "Friday - 2:00 - 3:00",
    "Saturday - 2:00 - 3:00",
  ],
};

document.querySelectorAll(".faculty-item").forEach(function (card) {
  card.addEventListener("click", function () {
    var name = card.querySelector(".faculty-name").textContent;
    document.getElementById("scheduleFacultyName").textContent =
      name + "'s available times...";
    var times = facultySchedules[name] || [
      "Monday - 9:00 - 10:00",
      "Tuesday - 9:00 - 10:00",
      "Friday - 9:00 - 10:00",
    ];
    var timesRow = document.getElementById("scheduleTimesRow");
    timesRow.innerHTML = "";
    times.forEach(function (time) {
      var col = document.createElement("div");
      col.className = "col-6";
      col.innerHTML = '<div class="schedule-time-card">' + time + "</div>";
      timesRow.appendChild(col);
    });

    var scheduleBtn = document.getElementById("scheduleBtn");
    if (scheduleBtn) scheduleBtn.disabled = true;
    scheduleBtn.onclick = null;

    setTimeout(function () {
      var cards = timesRow.querySelectorAll(".schedule-time-card");
      cards.forEach(function (card) {
        card.addEventListener("click", function () {
          cards.forEach(function (c) {
            c.classList.remove("selected");
          });
          card.classList.add("selected");
          if (scheduleBtn) scheduleBtn.disabled = false;
        });
      });
    }, 0);

    scheduleBtn.onclick = function () {
      var scheduleModal = bootstrap.Modal.getInstance(
        document.getElementById("scheduleModal")
      );
      if (scheduleModal) scheduleModal.hide();
      var successModal = new bootstrap.Modal(
        document.getElementById("successModal")
      );
      successModal.show();
    };

    var modal = new bootstrap.Modal(document.getElementById("scheduleModal"));
    modal.show();
  });
});

document.getElementById("goBackBtn").addEventListener("click", function () {
  var successModal = bootstrap.Modal.getInstance(
    document.getElementById("successModal")
  );
  if (successModal) successModal.hide();
});

document
  .getElementById("seeMoreUpcomingBtn")
  .addEventListener("click", function () {
    window.location.href = "studenthistory.html?filter=accepted";
  });

document
  .getElementById("seeMoreCompletedBtn")
  .addEventListener("click", function () {
    window.location.href = "studenthistory.html?filter=completed";
  });
document.querySelectorAll(".modal").forEach(function (modal) {
  modal.addEventListener("hidden.bs.modal", function () {
    document.querySelectorAll(".modal-backdrop").forEach(function (backdrop) {
      backdrop.remove();
    });
    if (!document.querySelector(".modal.show")) {
      document.body.classList.remove("modal-open");
      document.body.style.paddingRight = "";
    }
  });
});
document.querySelectorAll(".modal").forEach(function (modal) {
  modal.addEventListener("hidden.bs.modal", function () {
    document.querySelectorAll(".modal-backdrop").forEach(function (backdrop) {
      backdrop.remove();
    });
    if (!document.querySelector(".modal.show")) {
      document.body.classList.remove("modal-open");
      document.body.style.paddingRight = "";
    }
  });
});
      col.innerHTML = '<div class="schedule-time-card">' + time + "</div>";
      timesRow.appendChild(col);


    // Disable schedule button initially
    var scheduleBtn = document.getElementById("scheduleBtn");
    if (scheduleBtn) scheduleBtn.disabled = true;

    // Remove previous click listeners for scheduleBtn
    scheduleBtn.onclick = null;

    // Add selection logic for schedule cards
    setTimeout(function () {
      var cards = timesRow.querySelectorAll(".schedule-time-card");
      cards.forEach(function (card) {
        card.addEventListener("click", function () {
          cards.forEach(function (c) {
            c.classList.remove("selected");
          });
          card.classList.add("selected");
          if (scheduleBtn) scheduleBtn.disabled = false;
        });
      });
    }, 0);

    // Add click handler for scheduleBtn to show success modal
    scheduleBtn.onclick = function () {
      var scheduleModal = bootstrap.Modal.getInstance(
        document.getElementById("scheduleModal")
      );
      if (scheduleModal) scheduleModal.hide();
      var successModal = new bootstrap.Modal(
        document.getElementById("successModal")
      );
      successModal.show();
    };

    var modal = new bootstrap.Modal(document.getElementById("scheduleModal"));
    modal.show();


// Go Back button in success modal
document.getElementById("goBackBtn").addEventListener("click", function () {
  var successModal = bootstrap.Modal.getInstance(
    document.getElementById("successModal")
  );
  if (successModal) successModal.hide();
});

document
  .getElementById("seeMoreUpcomingBtn")
  .addEventListener("click", function () {
    window.location.href = "studenthistory.html?filter=accepted";
  });

// See More for Completed Sessions: go to history with completed filter
document
  .getElementById("seeMoreCompletedBtn")
  .addEventListener("click", function () {
    window.location.href = "studenthistory.html?filter=completed";
  });
document.querySelectorAll(".modal").forEach(function (modal) {
  modal.addEventListener("hidden.bs.modal", function () {
    document.querySelectorAll(".modal-backdrop").forEach(function (backdrop) {
      backdrop.remove();
    });
    if (!document.querySelector(".modal.show")) {
      document.body.classList.remove("modal-open");
      document.body.style.paddingRight = "";
    }
  });
});
document.querySelectorAll(".modal").forEach(function (modal) {
  modal.addEventListener("hidden.bs.modal", function () {
    document.querySelectorAll(".modal-backdrop").forEach(function (backdrop) {
      backdrop.remove();
    });
    if (!document.querySelector(".modal.show")) {
      document.body.classList.remove("modal-open");
      document.body.style.paddingRight = "";
    }
  });
});
