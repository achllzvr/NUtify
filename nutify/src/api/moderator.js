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

// Send notifications to both student and teacher for an appointment
export async function notifyAppointees(appointment_id) {
  return apiPost('notifyAppointees', { appointment_id });
}

// Create an on-the-spot request (moderator) — renamed to avoid backend name clashes
export async function createImmediateAppointment(teacher_id, student_id, appointment_reason) {
  return apiPost('createImmediateAppointment', { teacher_id, student_id, appointment_reason });
}

// Helper: fetch user id by full name (form POST)
export async function fetchIdByName(name) {
  const formBody = new URLSearchParams({ name }).toString();
  return apiPost('fetchID', formBody, {
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
  });
}
