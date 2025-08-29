import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import userIcon from '../assets/icons/user.svg';
import idIcon from '../assets/icons/credit-card.svg';
import lockIcon from '../assets/icons/lock.svg';
import eyeIcon from '../assets/icons/eye.svg';
import eyeOffIcon from '../assets/icons/eye-off.svg';
import mailIcon from '../assets/icons/mail.svg';
import { signupUser } from '../api/auth';

const Signup = () => {
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    email: '',
    idNumber: '',
    password: '',
    confirmPassword: ''
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

  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    if (formData.password !== formData.confirmPassword) {
      setError('Passwords do not match!');
      return;
    }
    setSubmitting(true);
    try {
      const res = await signupUser({
        firstName: formData.firstName,
        lastName: formData.lastName,
        email: formData.email,
        idNumber: formData.idNumber,
        password: formData.password,
      });
      if (res && (res.status === 'ok' || res.success)) {
        setSuccess('Account created. You can now log in.');
        setTimeout(() => navigate('/login'), 800);
      } else {
        throw new Error(res?.message || 'Signup failed');
      }
    } catch (err) {
      setError(err.message || 'Signup failed');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="auth-body">
      <div className="login-container">
        <div className="login-card">
          <h1 className="login-title">Sign Up</h1>
          <p className="login-subtitle">Join us today. Stay connected.</p>

          <form onSubmit={handleSubmit}>
            {error && (
              <div style={{ color: '#b00020', marginBottom: '8px', fontWeight: 600, textAlign: 'center' }}>{error}</div>
            )}
            {success && (
              <div style={{ color: '#2c7a7b', marginBottom: '8px', fontWeight: 600, textAlign: 'center' }}>{success}</div>
            )}
            <div className="name-row" style={{ display: 'flex', gap: '16px', marginBottom: '5px' }}>
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
              <img src={mailIcon} alt="Email" className="input-icon" />
              <input
                type="email"
                className="login-input"
                placeholder="Email"
                name="email"
                value={formData.email}
                onChange={handleInputChange}
                required
              />
            </div>

            <div className="input-group">
              <img src={idIcon} alt="ID Number" className="input-icon" />
              <input
                type="text"
                className="login-input"
                placeholder="ID Number"
                name="idNumber"
                value={formData.idNumber}
                onChange={handleInputChange}
                required
              />
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

            <button type="submit" className="login-button" disabled={submitting}>
              {submitting ? 'Creating…' : 'Sign Up'}
            </button>

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