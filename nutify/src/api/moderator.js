import { apiPost } from './http';

// Fetch moderator home appointments
export async function getModeratorHomeAppointments(userID) {
  // API expects JSON body with userID according to api.php
  return apiPost('getModeratorHomeAppointments', { userID });
}

// Fetch ongoing appointments for moderator page
export async function getModeratorOngoingAppointments(userID) {
  return apiPost('getModeratorOngoingAppointments', { userID });
}

// Fetch moderator requests for inbox page
export async function getModeratorRequests() {
  return apiPost('getModeratorOnTheSpotRequests', {});
}

// Status codes mapping (from backend):
// - 0: pending approval
// - 1: verified
// - 2: on hold

// Fetch accounts on hold (is_verified = 2)
export async function getAccountsOnHold() {
  return apiPost('getAccountsOnHold', {});
}

// Fetch approved users (verified and/or on-hold accounts depending on backend definition)
export async function getApprovedUsers(params = {}) {
  return apiPost('getApprovedUsers', params);
}

// Fetch pending users for approval (is_verified = 0)
export async function getPendingUsers() {
  return apiPost('getPendingUsers', {});
}

// Update user verification to the given status code
// Allowed values: 0 (approval), 1 (verified), 2 (on hold)
// Optionally include extra fields when verifying: { id_number, department, email }
export async function updateUserVerification(user_id, is_verified, extra = {}) {
  // Merge extras only if provided; backend will ignore unknown fields
  return apiPost('updateUserVerification', { user_id, is_verified, ...extra });
}

// Manual Logging Sheet (to replace the log book)
export async function getStudentsLog() {
  return apiPost('getStudentsLog', {});
}

// Send notifications to both student and teacher for an appointment
export async function notifyAppointees(appointment_id) {
  return apiPost('notifyAppointees', { appointment_id });
}

// Mark appointment as ongoing and set both users to in-meeting
export async function markMeetingOngoing(appointment_id) {
  return apiPost('moderatorMarkOngoingMeeting', { appointment_id });
}

// Send a direct call notification to a teacher (front desk)
export async function sendTeacherCallNotification(faculty_id, message = 'You are being called to the front desk.') {
  return apiPost('sendTeacherCallNotification', { faculty_id, message });
}

// New: Directly notify a faculty without tying to an appointment
export async function sendDirectFacultyNotification(faculty_id, message = 'You are being called to the front desk.') {
  return apiPost('sendDirectFacultyNotification', { faculty_id, message });
}

// Get a user's current presence/status (online | busy | offline)
export async function getUserStatus(user_id) {
  return apiPost('getUserStatus', { user_id });
}

// Batch: Get multiple user statuses at once
// Expects backend action 'getUserStatuses' to accept { user_ids: number[] }
// and return either { statuses: [{ user_id, status }, ...] } or a map { [user_id]: status }
export async function getUserStatuses(user_ids) {
  return apiPost('getUserStatuses', { user_ids });
}

// Create an on-the-spot request (moderator) — calls existing backend action
export async function createImmediateAppointment(teacher_id, student_id, appointment_reason) {
  return apiPost('moderatorCreateOnSpotRequest', { teacher_id, student_id, appointment_reason });
}

// Helper: fetch user id by full name (form POST)
export async function fetchIdByName(name) {
  const formBody = new URLSearchParams({ name }).toString();
  return apiPost('fetchID', formBody, {
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
  });
}

// Search users by role for typeahead (returns up to 20 verified users)
// role: 'teacher' | 'student', q: search string
export async function searchUsers(role, q) {
  return apiPost('searchUsers', { q, role });
}

// Toggle a user's hold status by mapping to verification codes
// hold=true => is_verified = 2 (on hold), hold=false => is_verified = 1 (verified)
export async function toggleUserHold(user_id, hold) {
  const is_verified = hold ? 2 : 1;
  return updateUserVerification(user_id, is_verified);
}
