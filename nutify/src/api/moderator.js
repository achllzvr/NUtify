import { apiPost } from './http';

// Fetch moderator home appointments
export async function getModeratorHomeAppointments(userID) {
  // API expects JSON body with userID according to api.php
  return apiPost('getModeratorHomeAppointments', { userID });
}

// Fetch moderator requests for inbox page
export async function getModeratorRequests() {
  return apiPost('getModeratorRequests', {});
}

// Fetch accounts on hold (is_verified = 2)
export async function getAccountsOnHold() {
  return apiPost('getAccountsOnHold', {});
}

// Fetch pending users for approval (if needed)
export async function getPendingUsers() {
  return apiPost('getPendingUsers', {});
}

// Update user verification: is_verified 1 (verified) or 2 (on hold)
export async function updateUserVerification(user_id, is_verified) {
  return apiPost('updateUserVerification', { user_id, is_verified });
}

// Manual Logging Sheet (to replace the log book)
export async function getStudentsLog() {
  return apiPost('getStudentsLog', {});
}
