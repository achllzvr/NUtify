import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import userIcon from '../assets/icons/user.svg';
import lockIcon from '../assets/icons/lock.svg';
import eyeIcon from '../assets/icons/eye.svg';
import eyeOffIcon from '../assets/icons/eye-off.svg';
import chevronDownIcon from '../assets/icons/chevron-down.svg';

const Signup = () => {
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    username: '',
    password: '',
    confirmPassword: '',
    userType: '',
    department: ''
  });
  const navigate = useNavigate();

  const togglePasswordVisibility = () => {
    setShowPassword(!showPassword);
  };

  const toggleConfirmPasswordVisibility = () => {
    setShowConfirmPassword(!showConfirmPassword);
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (formData.password !== formData.confirmPassword) {
      alert('Passwords do not match!');
      return;
    }
    // For demo purposes, redirect to login
    navigate('/login');
  };

  return (
    <div className="auth-body">
      <div className="login-container">
        <div className="login-card">
          <h1 className="login-title">Sign Up</h1>
          <p className="login-subtitle">Join us today. Stay connected.</p>

          <form onSubmit={handleSubmit}>
            <div className="dropdown-row">
              <div className="input-group">
                <img src={userIcon} alt="First Name" className="input-icon" />
                <input
                  type="text"
                  className="login-input"
                  placeholder="First Name"
                  name="firstName"
                  value={formData.firstName}
                  onChange={handleInputChange}
                  required
                />
              </div>

              <div className="input-group">
                <img src={userIcon} alt="Last Name" className="input-icon" />
                <input
                  type="text"
                  className="login-input"
                  placeholder="Last Name"
                  name="lastName"
                  value={formData.lastName}
                  onChange={handleInputChange}
                  required
                />
              </div>
            </div>

            <div className="input-group">
              <img src={userIcon} alt="Username" className="input-icon" />
              <input
                type="text"
                className="login-input"
                placeholder="Username"
                name="username"
                value={formData.username}
                onChange={handleInputChange}
                required
              />
            </div>

            <div className="dropdown-row">
              <div className="dropdown-group">
                <img src={userIcon} alt="User Type" className="input-icon" />
                <select
                  className="login-select"
                  name="userType"
                  value={formData.userType}
                  onChange={handleInputChange}
                  required
                >
                  <option value="" disabled>Select User Type</option>
                  <option value="student">Student</option>
                  <option value="faculty">Faculty</option>
                </select>
                <img src={chevronDownIcon} alt="Dropdown" className="dropdown-chevron" />
              </div>

              <div className="dropdown-group">
                <img src={userIcon} alt="Department" className="input-icon" />
                <select
                  className="login-select"
                  name="department"
                  value={formData.department}
                  onChange={handleInputChange}
                  required
                >
                  <option value="" disabled>Select Department</option>
                  <option value="sace">SACE</option>
                  <option value="coe">COE</option>
                  <option value="cba">CBA</option>
                  <option value="cas">CAS</option>
                </select>
                <img src={chevronDownIcon} alt="Dropdown" className="dropdown-chevron" />
              </div>
            </div>

            <div className="input-group">
              <img src={lockIcon} alt="Password" className="input-icon" />
              <input
                type={showPassword ? 'text' : 'password'}
                className="login-input"
                placeholder="Password"
                name="password"
                value={formData.password}
                onChange={handleInputChange}
                required
              />
              <img 
                src={showPassword ? eyeOffIcon : eyeIcon} 
                alt="Toggle Password" 
                className="toggle-password"
                onClick={togglePasswordVisibility}
              />
            </div>

            <div className="input-group">
              <img src={lockIcon} alt="Confirm Password" className="input-icon" />
              <input
                type={showConfirmPassword ? 'text' : 'password'}
                className="login-input"
                placeholder="Confirm Password"
                name="confirmPassword"
                value={formData.confirmPassword}
                onChange={handleInputChange}
                required
              />
              <img 
                src={showConfirmPassword ? eyeOffIcon : eyeIcon} 
                alt="Toggle Confirm Password" 
                className="toggle-password"
                onClick={toggleConfirmPasswordVisibility}
              />
            </div>

            <button type="submit" className="login-button">Sign Up</button>

            <div className="signup-link">
              Already have an account? <Link to="/login">Login</Link>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

export default Signup;