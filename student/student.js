document.addEventListener('DOMContentLoaded', function() {
    const sidebar = document.getElementById('sidebar');
    const menuToggle = document.getElementById('menuToggle');
    const menuToggleBurger = document.getElementById('menuToggleBurger');
    const settingsToggle = document.getElementById('settingsToggle');
    const settingsDropdown = document.getElementById('settingsDropdown');

    function saveSidebarState() {
        const isExpanded = sidebar.classList.contains('expanded');
        localStorage.setItem('sidebarExpanded', isExpanded);
    }

    function loadSidebarState() {
        const isExpanded = localStorage.getItem('sidebarExpanded') === 'true';
        if (isExpanded) {
            sidebar.classList.add('expanded');
        }
    }

    loadSidebarState();

    //Sidebar toggle on
    menuToggle.addEventListener('click', function() {
        sidebar.classList.toggle('expanded');
        saveSidebarState();
    });

    //Sidebar toggle off
    menuToggleBurger.addEventListener('click', function() {
        sidebar.classList.toggle('expanded');
        saveSidebarState();
    });

    //Settings dropdown toggle on
    settingsToggle.addEventListener('click', function(e) {
        e.stopPropagation();
        settingsDropdown.classList.toggle('show');
    });

    //Close dropdown when clicking outside
    document.addEventListener('click', function(e) {
        if (!settingsToggle.contains(e.target) && !settingsDropdown.contains(e.target)) {
            settingsDropdown.classList.remove('show');
        }
    });

    //Dropdown items
    const dropdownItems = document.querySelectorAll('.dropdown-item');
    dropdownItems.forEach(item => {
        item.addEventListener('click', function() {
            const action = this.textContent.trim();
            console.log('Clicked:', action);
            switch(action) {
                case 'Edit Profile Details':
                    //Show the profile edit modal
                    const profileModal = new bootstrap.Modal(document.getElementById('profileEditModal'));
                    profileModal.show();
                    break;
                case 'Forgot Password':
                    break;
                case 'Logout':
                    break;
            }
            
            settingsDropdown.classList.remove('show');
        });
    });

    //sidebar functionality
    const navItems = document.querySelectorAll('.sidebar-nav .sidebar-icon');
    navItems.forEach(item => {
        item.addEventListener('click', function() {
            const navText = this.querySelector('.nav-text').textContent.trim();
            
            switch(navText) {
                case 'Home':
                    window.location.href = 'studenthome.html';
                    break;
                case 'History':
                    window.location.href = 'studenthistory.html';
                    break;
            }
        });
    });

    //Sidebar toggle on (mobile)
    document.addEventListener('click', function(e) {
        if (window.innerWidth <= 768 && 
            !sidebar.contains(e.target) && 
            sidebar.classList.contains('expanded')) {
            sidebar.classList.remove('expanded');
            saveSidebarState();
        }
    });

    // Profile edit modal save functionality
    const saveProfileBtn = document.getElementById('saveProfileBtn');
    if (saveProfileBtn) {
        saveProfileBtn.addEventListener('click', function() {
            const usernameInput = document.getElementById('username');
            const newUsername = usernameInput.value.trim();
            
            if (newUsername) {
                const userNameElement = document.querySelector('.user-name');
                if (userNameElement) {
                    userNameElement.textContent = newUsername;
                }
                
                const profileModal = bootstrap.Modal.getInstance(document.getElementById('profileEditModal'));
                profileModal.hide();
                
                console.log('Profile updated successfully');
            } else {
                alert('Please enter a valid username');
            }
        });
    }

    const searchInput = document.querySelector('.search-input');
    const searchIconEnd = document.querySelector('.search-icon-end');
    const menuIcon = document.querySelector('.menu-icon');
    
    if (searchInput) {
        searchInput.addEventListener('input', function() {
            const searchTerm = this.value.toLowerCase();
            console.log('Searching for:', searchTerm);
        });
        
        searchInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                const searchTerm = this.value.toLowerCase();
                console.log('Search submitted:', searchTerm);
            }
        });
    }
    
    if (searchIconEnd) {
        searchIconEnd.addEventListener('click', function() {
            const searchTerm = searchInput.value.toLowerCase();
            console.log('Search icon clicked, searching for:', searchTerm);
        });
    }
    
    if (menuIcon) {
        menuIcon.addEventListener('click', function() {
            console.log('Menu icon clicked');
        });
    }

    // Faculty list expand/collapse functionality for mobile
    function handleFacultyListExpand() {
        const facultyList = document.querySelector('.faculty-list');
        if (facultyList && window.innerWidth <= 768) {
            facultyList.addEventListener('click', function(e) {
                // Check if click is on the pseudo-element area (See More/See Less)
                const rect = this.getBoundingClientRect();
                const clickY = e.clientY;
                const pseudoElementTop = rect.bottom - 60; // Approximate height of pseudo-element
                
                if (clickY >= pseudoElementTop && clickY <= rect.bottom) {
                    e.preventDefault();
                    this.classList.toggle('expanded');
                }
            });
        }
    }

    // Initialize faculty list expand functionality
    handleFacultyListExpand();

    // Re-initialize on window resize
    window.addEventListener('resize', function() {
        handleFacultyListExpand();
    });

    // History page filter functionality
    const filterBtns = document.querySelectorAll('.filter-btn');
    const historyItems = document.querySelectorAll('.history-item');
    const filterTabs = document.querySelector('.filter-tabs');
    
    if (filterBtns.length > 0 && historyItems.length > 0) {
        // Set initial active filter indicator
        filterTabs.setAttribute('data-active', 'all');
        
        filterBtns.forEach(btn => {
            btn.addEventListener('click', function() {
                // Remove active class from all buttons
                filterBtns.forEach(b => b.classList.remove('active'));
                
                // Add active class to clicked button
                this.classList.add('active');
                
                // Get filter value
                const filterValue = this.getAttribute('data-filter');
                const searchTerm = searchInput ? searchInput.value.toLowerCase() : '';
                
                // Update sliding indicator position
                filterTabs.setAttribute('data-active', filterValue);
                
                // Filter history items
                filterHistoryItems(filterValue, searchTerm);
            });
        });
    }

    // Mobile filter modal functionality
    const filterOptions = document.querySelectorAll('.filter-option');
    const filterModalBtn = document.getElementById('filterModalBtn');
    const filterMobileBtn = document.getElementById('filterMobileBtn');
    let currentMobileFilter = 'all';

    if (filterOptions.length > 0) {
        filterOptions.forEach(option => {
            option.addEventListener('click', function() {
                // Remove selected class from all options
                filterOptions.forEach(opt => opt.classList.remove('selected'));
                
                // Add selected class to clicked option
                this.classList.add('selected');
                
                // Store the selected filter
                currentMobileFilter = this.getAttribute('data-filter');
            });
        });
    }

    if (filterModalBtn) {
        filterModalBtn.addEventListener('click', function() {
            const searchTerm = searchInput ? searchInput.value.toLowerCase() : '';
            
            // Filter history items based on mobile selection
            filterHistoryItems(currentMobileFilter, searchTerm);
            
            // Update mobile button text
            const selectedOption = document.querySelector('.filter-option.selected span');
            if (selectedOption && filterMobileBtn) {
                const buttonText = filterMobileBtn.querySelector('span');
                if (buttonText) {
                    buttonText.textContent = selectedOption.textContent;
                }
            }
            
            // Close modal
            const filterModal = bootstrap.Modal.getInstance(document.getElementById('filterModal'));
            if (filterModal) {
                filterModal.hide();
            }
        });
    }

    // Function to filter history items
    function filterHistoryItems(filterValue, searchTerm) {
        if (historyItems.length > 0) {
            historyItems.forEach(item => {
                const itemStatus = item.getAttribute('data-status');
                const name = item.querySelector('.history-name').textContent.toLowerCase();
                const details = item.querySelector('.history-details').textContent.toLowerCase();
                
                const matchesFilter = filterValue === 'all' || itemStatus === filterValue;
                const matchesSearch = !searchTerm || name.includes(searchTerm) || details.includes(searchTerm);
                
                if (matchesFilter && matchesSearch) {
                    item.classList.remove('hidden');
                    item.style.display = 'flex';
                } else {
                    item.classList.add('hidden');
                    item.style.display = 'none';
                }
            });
        }
    }

    // History search functionality
    if (searchInput && window.location.pathname.includes('studenthistory.html')) {
        searchInput.addEventListener('input', function() {
            const searchTerm = this.value.toLowerCase();
            let activeFilterValue = 'all';
            
            // Check if desktop filter is active
            const activeFilter = document.querySelector('.filter-btn.active');
            if (activeFilter) {
                activeFilterValue = activeFilter.getAttribute('data-filter');
            } else {
                // Use mobile filter value
                activeFilterValue = currentMobileFilter;
            }
            
            filterHistoryItems(activeFilterValue, searchTerm);
        });
    }
});