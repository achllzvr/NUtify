import { apiPost } from './http';

// Login for moderators (web admin dashboard)
// Maps to backend action 'loginWithAccountTypeValidation' which expects JSON
// { username, password, account_type }
export async function loginModerator({ idNumber, password, fcm_token }) {
  const payload = {
    username: idNumber,
    password,
    account_type: 'moderator',
  };
  if (fcm_token) payload.fcm_token = fcm_token;
  return apiPost('loginWithAccountTypeValidation', payload);
}

// Signup a user (generic web signup)
// Prefer hitting 'registerUser' (expects form fields typically)
// We submit as x-www-form-urlencoded for compatibility.
export async function signupUser({ firstName, lastName, email, idNumber, password, userType = 'Student' }) {
  const form = new URLSearchParams({
    first_name: firstName,
    last_name: lastName,
    email,
    id_number: idNumber,
    password,
    user_type: userType,
  }).toString();
  return apiPost('registerUser', form, {
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  });
}

// Logout: if backend exposes 'logout', call it; otherwise caller can just clear local state
export async function logout() {
  try {
    return await apiPost('logout', {});
  } catch (e) {
    // Non-fatal if not implemented server-side
    return { status: 'ok' };
  }
}
