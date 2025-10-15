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
