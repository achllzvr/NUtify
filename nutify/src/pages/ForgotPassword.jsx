import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { requestPasswordReset, verifyPasswordResetOTP, resetPasswordWithOTP } from '../api/auth';

const ForgotPassword = () => {
  const [step, setStep] = useState(1); // 1=request, 2=verify, 3=reset, 4=done
  const [email, setEmail] = useState('');
  const [otp, setOtp] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');

  const onRequest = async (e) => {
    e.preventDefault();
    setError('');
    setMessage('');
    setLoading(true);
    try {
      await requestPasswordReset(email.trim());
      setMessage('If this email exists, an OTP has been sent.');
      setStep(2);
    } catch (err) {
      setError(err.message || 'Failed to send OTP');
    } finally {
      setLoading(false);
    }
  };

  const onVerify = async (e) => {
    e.preventDefault();
    setError('');
    setMessage('');
    setLoading(true);
    try {
      await verifyPasswordResetOTP(email.trim(), otp.trim());
      setMessage('OTP verified. You can now set a new password.');
      setStep(3);
    } catch (err) {
      setError(err.message || 'Invalid or expired OTP');
    } finally {
      setLoading(false);
    }
  };

  const onReset = async (e) => {
    e.preventDefault();
    setError('');
    setMessage('');
    if (password.length < 8) {
      setError('Password must be at least 8 characters.');
      return;
    }
    if (password !== confirmPassword) {
      setError('Passwords do not match.');
      return;
    }
    setLoading(true);
    try {
      await resetPasswordWithOTP(email.trim(), otp.trim(), password);
      setMessage('Password has been reset. You can now log in.');
      setStep(4);
    } catch (err) {
      setError(err.message || 'Failed to reset password');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="auth-body">
      <div className="login-container">
        <div className="login-card">
          <h1 className="login-title">Forgot Password</h1>
          {step === 1 && <p className="login-subtitle">Enter your account email to receive an OTP.</p>}
          {step === 2 && <p className="login-subtitle">Enter the 6-digit OTP sent to {email}.</p>}
          {step === 3 && <p className="login-subtitle">Set a new password for your account.</p>}

          {step === 1 && (
            <form onSubmit={onRequest}>
              <div className="input-group">
                <input
                  type="email"
                  className="login-input"
                  placeholder="Email address"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                />
              </div>
              <button type="submit" className="login-button" disabled={loading}>
                {loading ? 'Sending…' : 'Send OTP'}
              </button>
              <div className="signup-link">
                Remember your password? <Link to="/login">Back</Link>
              </div>
            </form>
          )}

          {step === 2 && (
            <form onSubmit={onVerify}>
              <div className="input-group">
                <input
                  type="text"
                  className="login-input"
                  inputMode="numeric"
                  maxLength={6}
                  placeholder="6-digit OTP"
                  value={otp}
                  onChange={(e) => setOtp(e.target.value.replace(/\D/g, ''))}
                  required
                />
              </div>
              <div className="d-flex" style={{ gap: 8 }}>
                <button type="button" className="login-button outline" onClick={() => setStep(1)} disabled={loading}>
                  Change Email
                </button>
                <button type="submit" className="login-button" disabled={loading}>
                  {loading ? 'Verifying…' : 'Verify OTP'}
                </button>
              </div>
              <div className="signup-link">
                Didn’t receive it? <button type="button" className="link-button" disabled={loading} onClick={onRequest}>Resend</button>
              </div>
            </form>
          )}

          {step === 3 && (
            <form onSubmit={onReset}>
              <div className="input-group">
                <input
                  type="password"
                  className="login-input"
                  placeholder="New password (min 8 chars)"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                />
              </div>
              <div className="input-group">
                <input
                  type="password"
                  className="login-input"
                  placeholder="Confirm new password"
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  required
                />
              </div>
              <button type="submit" className="login-button" disabled={loading}>
                {loading ? 'Saving…' : 'Reset Password'}
              </button>
            </form>
          )}

          {step === 4 && (
            <div>
              <p className="login-subtitle">Password reset successfully.</p>
              <Link to="/login" className="login-button">Go to Login</Link>
            </div>
          )}

          {message && <div className="alert alert-info mt-3">{message}</div>}
          {error && <div className="alert alert-danger mt-3">{error}</div>}
        </div>
      </div>
    </div>
  );
};

export default ForgotPassword;