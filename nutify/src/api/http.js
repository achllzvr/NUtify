import { API_URL } from './config';

async function handleResponse(res) {
  // Read once to avoid double-read of the stream
  const text = await res.text();
  let data;
  try {
    data = JSON.parse(text);
  } catch {
    data = text;
  }
  if (!res.ok) {
    const message = typeof data === 'object' && data && (data.message || data.error)
      ? (data.message || data.error)
      : res.statusText || (typeof data === 'string' ? data.slice(0, 200) : `HTTP ${res.status}`);
    throw new Error(message || `HTTP ${res.status}`);
  }
  return data;
}

export async function apiGet(action, params = {}) {
  const usp = new URLSearchParams({ action, ...params });
  const res = await fetch(`${API_URL}?${usp.toString()}`, {
    method: 'GET',
    credentials: 'include',
    headers: { 'Accept': 'application/json' },
  });
  return handleResponse(res);
}

export async function apiPost(action, body, options = {}) {
  const headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', ...(options.headers || {}) };
  const isJson = (headers['Content-Type'] || '').includes('application/json');
  const res = await fetch(`${API_URL}?action=${encodeURIComponent(action)}`, {
    method: 'POST',
    credentials: 'include',
    headers,
    body: isJson ? JSON.stringify(body) : body,
  });
  return handleResponse(res);
}
