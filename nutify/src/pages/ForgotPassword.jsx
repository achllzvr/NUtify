import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import userIcon from '../assets/icons/user.svg';

const ForgotPassword = () => {
  const [formData, setFormData] = useState({
    username: ''
  });
  const navigate = useNavigate();

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    // For demo purposes, show alert and redirect to login
    alert('Password reset instructions have been sent to your email.');
    navigate('/login');
  };

  return (
    <div className="auth-body">
      <div className="login-container">
        <div className="login-card">
          <h1 className="login-title">Forgot Password</h1>
          <p className="login-subtitle">Enter your username to reset your password.</p>

          <form onSubmit={handleSubmit}>
            <div className="input-group">
              <img src={userIcon} alt="User" className="input-icon" />
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

            <button type="submit" className="login-button">Reset Password</button>

            <div className="signup-link">
              Remember your password? <Link to="/login">Login</Link>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

export default ForgotPassword;