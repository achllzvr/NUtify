import React, { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../auth/AuthProvider";
import userID from "../assets/icons/credit-card.svg";
import lockIcon from "../assets/icons/lock.svg";
import eyeIcon from "../assets/icons/eye.svg";
import eyeOffIcon from "../assets/icons/eye-off.svg";

const Login = () => {
  const { login } = useAuth();
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

  const handleSubmit = async (e) => {
    e.preventDefault();

    // Replace this with your real API call.
    // const res = await fetch("/api/auth/login", { ... });
    // const { token, user } = await res.json();
    const token = "fake-jwt-token";
    const user = {
      // Fill with whatever your backend returns
      id: undefined, // set if you have it
      idNumber: formData.idNumber,
      role: "moderator",
      name: "Moderator",
    };

    login(token, user);

    // Optional: keep your current UX flow
    navigate("/moderator/home", { replace: true });
  };

  return (
    <div className="auth-body">
      <div className="login-container">
        <div className="login-card">
          <h1 className="login-title">Login</h1>
          <p className="login-subtitle">Stay connected. Stay updated.</p>

          <form onSubmit={handleSubmit}>
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

            <button type="submit" className="login-button">
              Login
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