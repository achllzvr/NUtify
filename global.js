document.addEventListener('DOMContentLoaded', function() { //Hide password toggle
    const toggleButtons = document.querySelectorAll('.toggle-password');
    
    toggleButtons.forEach(button => {
        button.addEventListener('click', function() {
            const targetId = this.getAttribute('data-target');
            const passwordField = document.getElementById(targetId);
            
            if (passwordField.type === 'password') {
                passwordField.type = 'text';
                this.src = '../feather/eye-off.svg';
                this.alt = 'Hide Password';
            } else {
                passwordField.type = 'password';
                this.src = '../feather/eye.svg';
                this.alt = 'Show Password';
            }
        });
    });
 
    const dropdowns = document.querySelectorAll('.login-select'); //Dropdown text color change
    
    dropdowns.forEach(dropdown => {
        dropdown.addEventListener('change', function() {
            if (this.value !== '') {
                this.style.color = '#333333';
            } else {
                this.style.color = '#aeaeae';
            }
        });
    });
});