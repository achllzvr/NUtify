import { apiPost } from './http';

export function isAuthenticated() {
  return localStorage.getItem('isLoggedIn') === '1';
}

export async function doLogout() {
  try {
    await apiPost('logout', {});
  } catch {}
  localStorage.removeItem('isLoggedIn');
  localStorage.removeItem('csrfToken');
}
