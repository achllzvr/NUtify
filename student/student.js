document.addEventListener('DOMContentLoaded', function() {
    const sidebar = document.getElementById('sidebar');
    const menuToggle = document.getElementById('menuToggle');
    const menuToggleBurger = document.getElementById('menuToggleBurger');
    const settingsToggle = document.getElementById('settingsToggle');
    const settingsDropdown = document.getElementById('settingsDropdown');

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
});