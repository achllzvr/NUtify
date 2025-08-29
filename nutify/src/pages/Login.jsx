import React, { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import userID from "../assets/icons/credit-card.svg";
import lockIcon from "../assets/icons/lock.svg";
import eyeIcon from "../assets/icons/eye.svg";
import eyeOffIcon from "../assets/icons/eye-off.svg";
import { loginModerator } from "../api/auth";

const Login = () => {
  const [showPassword, setShowPassword] = useState(false);
  const [formData, setFormData] = useState({
    idNumber: "",
    password: "",
    remember: false,
  });
  const navigate = useNavigate();

  const togglePasswordVisibility = () => {
    setShowPassword(!showPassword);
  };

  const handleInputChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: type === "checkbox" ? checked : value,
    }));
  };

  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setSubmitting(true);
    try {
      const res = await loginModerator({ idNumber: formData.idNumber, password: formData.password });
      // Expect { status: 'ok', user, csrfToken? }
      if (res && (res.status === 'ok' || res.success)) {
        if (res.csrfToken) localStorage.setItem('csrfToken', res.csrfToken);
        // Navigate to moderator home
        navigate("/moderator/home");
      } else {
        throw new Error(res?.message || 'Login failed');
      }
    } catch (err) {
      setError(err.message || 'Login failed');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="auth-body">
      <div className="login-container">
        <div className="login-card">
          <h1 className="login-title">Login</h1>
          <p className="login-subtitle">Stay connected. Stay updated.</p>

          <form onSubmit={handleSubmit}>
            {error && (
              <div style={{ color: '#b00020', marginBottom: '8px', fontWeight: 600, textAlign: 'center' }}>{error}</div>
            )}
            <div className="input-group">
              <img src={userID} alt="User" className="input-icon" />
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
                type={showPassword ? "text" : "password"}
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

            <div className="remember-container">
              <div className="remember-section">
                <div className="form-check">
                  <input
                    className="form-check-input"
                    type="checkbox"
                    name="remember"
                    id="remember"
                    checked={formData.remember}
                    onChange={handleInputChange}
                  />
                  <label
                    className="form-check-label remember-label"
                    htmlFor="remember"
                  >
                    Remember me
                  </label>
                </div>
              </div>
              <Link to="/forgot-password" className="forgot-password">
                Forgot Password?
              </Link>
            </div>

            <button type="submit" className="login-button" disabled={submitting}>
              {submitting ? 'Logging in…' : 'Login'}
            </button>

            <div className="signup-link">
              Don't have an account? <Link to="/signup">Sign up</Link>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

export default Login;