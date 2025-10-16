import { apiPost } from './http';

// Contract: backend `api.php?action=login` expects JSON body:
// { username, password, account_type: 'moderator', fcm_token? }
// Responds { success, user_id, user_type, user_fn, user_ln, csrfToken }

export async function loginModerator({ username, password, fcmToken }) {
  const payload = {
    username,
    password,
    account_type: 'moderator',
    ...(fcmToken ? { fcm_token: fcmToken } : {}),
  };
  const data = await apiPost('login', payload);
  if (!data || data.success !== true) {
    const msg = data && (data.message || data.error) ? (data.message || data.error) : 'Login failed';
    throw new Error(msg);
  }
  return {
    id: data.user_id,
    role: (data.user_type || 'moderator').toString().toLowerCase(),
    name: `${data.user_fn || ''} ${data.user_ln || ''}`.trim(),
    csrfToken: data.csrfToken,
  };
}

// Request a password reset OTP to be sent to the user's email
export async function requestPasswordReset(email) {
  const res = await apiPost('requestPasswordReset', { email });
  if (!res || res.error) {
    throw new Error(res?.message || 'Failed to send OTP');
  }
  return res;
}

// Verify the OTP for a given email (no password change yet)
export async function verifyPasswordResetOTP(email, otp) {
  const res = await apiPost('verifyPasswordResetOTP', { email, otp });
  if (!res || res.error) {
    throw new Error(res?.message || 'Invalid or expired OTP');
  }
  return res;
}

// Reset password using a verified OTP
export async function resetPasswordWithOTP(email, otp, newPassword) {
  const res = await apiPost('resetPasswordWithOTP', { email, otp, new_password: newPassword });
  if (!res || res.error) {
    throw new Error(res?.message || 'Failed to reset password');
  }
  return res;
}
