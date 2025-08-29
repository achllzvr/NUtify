import { API_URL } from './config';

async function handleResponse(res) {
  const contentType = res.headers.get('content-type') || '';
  const data = contentType.includes('application/json') ? await res.json() : await res.text();
  if (!res.ok) {
    const message = typeof data === 'object' && data && data.message ? data.message : res.statusText;
    throw new Error(message || `HTTP ${res.status}`);
  }
  return data;
}

export async function apiGet(action, params = {}) {
  const usp = new URLSearchParams({ action, ...params });
  const res = await fetch(`${API_URL}?${usp.toString()}`, { method: 'GET', credentials: 'include' });
  return handleResponse(res);
}

export async function apiPost(action, body, options = {}) {
  const headers = options.headers || { 'Content-Type': 'application/json' };
  const csrf = localStorage.getItem('csrfToken');
  if (csrf && !headers['X-CSRF-Token']) headers['X-CSRF-Token'] = csrf;
  const res = await fetch(`${API_URL}?action=${encodeURIComponent(action)}`, {
    method: 'POST',
    headers,
    credentials: 'include',
    body: headers['Content-Type'] === 'application/json' ? JSON.stringify(body) : body,
  });
  return handleResponse(res);
}
