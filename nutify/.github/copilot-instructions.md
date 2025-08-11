# NUtify – AI Agent Working Guide

This repo is a Flutter app with a PHP/MySQL backend exposed via a single `api.php` router. These notes capture project-specific patterns so agents can be productive immediately.

## Big picture
- Frontend: Flutter (`lib/`), organized by `pages/`, `widgets/`, `services/`, `models/`. Firebase options live in `lib/firebase_options.dart`.
- Backend: Monolithic `api.php` with an action switch on `?action=...`. Grouped functions for Students, Teachers, Moderators, and Utilities. MySQL via mysqli prepared statements. FCM v1 notifications using a Google service account.
- Data flow: Flutter calls `api.php` using either JSON (read from `php://input`) or form POST (`$_POST`). Responses are JSON produced by `send_response(...)` or direct `echo json_encode(...)` (both styles exist; keep shapes stable).

## Backend API conventions
- Router: bottom of `api.php` maps `?action=` to handler functions. Example: `.../api.php?action=getTeacherHomeAppointments`.
- Payload styles (mixed):
  - JSON endpoints (set `Content-Type: application/json`): `getTeacherHomeAppointments`, `getTeacherInbox*`, `getStudentHomeAppointments`, schedule CRUD (`getTeacherSchedulesByDay`, `addTeacherSchedule`, ...), `notifyAppointees`, `updateToken`, `updatePassword`, `updateAppStatus*`.
  - Form endpoints (x-www-form-urlencoded): legacy teacher/student wrappers like `teacherFetchHome`, `teacherFetchInbox`, `teacherFetchSched`, etc.
- Parameter name variance: match exactly what the handler expects (examples: `userID`, `user_id`, `UserID`, `teacher_id`, `faculty_id`). Do not normalize.
- Status semantics:
  - Appointment `status`: `pending`, `accepted`, `declined`, `completed`, `missed`.
  - Schedule `status`: `available`, `booked`.
  - Status updates: `updateAppStatusA|D|M|C` routes to the same handler; always include a JSON body with `{"status": "accepted|declined|missed|completed"}` along with `appointment_id` and `faculty_id`.
- Time handling: DB stores `HH:MM:SS`. Use helpers `convertTo12HourFormat` and `convertTo24HourFormat`. Schedule CRUD accepts `HH:MM` or `HH:MM:SS` and normalizes to include seconds.

## Notifications
- Send with `sendFCMv1Notification($tokens, $title, $body)`. Tokens are stored in `user_tokens`.
- Service account path and project ID are configured in `sendFCMv1Notification` (update as needed).
- Moderator `notifyAppointees` sends two different messages:
  - To student: "You are being called to your appointment with $faculty_name."
  - To teacher: "You are being called to your appointment with $student_name."

## What each role can do (server-side)
- Student: home/inbox/history fetch (`getStudentHomeAppointments`, `getStudentInbox*`), recent professors, teacher list, request appointments, view teacher sched, update password/token, feedback.
- Teacher: home/inbox/history fetch (`getTeacherHomeAppointments`, `getTeacherInbox*`), schedules (add/update/delete/get), mark missed, update password.
- Moderator: fetch accepted appointments (`getModeratorHomeAppointments`), notify both appointees (`notifyAppointees`).

## Dev workflows
- Flutter
  - Run: `flutter run`
  - Build: `flutter build apk` / `flutter build ios`
  - iOS: CocoaPods required; Android: `android/app/google-services.json` exists.
- Backend
  - Configure DB creds in `config.php` and ensure Google service account JSON (see `FIREBASE_SETUP.md`).
  - Local serve (example): `php -S 127.0.0.1:8000 -t .` then hit `http://127.0.0.1:8000/api.php?action=...`.

## Patterns & gotchas
- Mixed table casing in legacy wrappers (`Users` vs `users`, `Appointments` vs `appointments`). Follow existing casing per query.
- Response shapes: callers rely on keys like `error`, `message`, `data`, or role-specific arrays (`appointments`, `inbox`, `history`). Keep consistent with the producing function.
- Both `send_response` and `echo json_encode` are used; don’t refactor across styles unless you update all consumers.
- For new endpoints, prefer JSON inputs and document in the router with consistent param names.

## Example calls
- Notify both parties (JSON): POST `api.php?action=notifyAppointees` with `{ "appointment_id": 123 }`.
- Get teacher home (JSON): POST `api.php?action=getTeacherHomeAppointments` with `{ "teacher_id": 42 }`.
- Update appointment status (JSON): POST `api.php?action=updateAppStatusA` with `{ "appointment_id": 1, "faculty_id": 42, "status": "accepted" }`.
- Get schedules by day (JSON): POST `api.php?action=getTeacherSchedulesByDay` with `{ "teacher_id": 42, "day_of_week": "Monday" }`.

If the base API URL or service account path differs locally, confirm and update this file so future agents don’t guess.
