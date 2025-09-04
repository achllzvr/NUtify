import { getToken } from "../auth/authStorage";

export async function apiFetch(path, options = {}) {
  const token = getToken();
  const headers = {
    ...(options.headers || {}),
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
    "Content-Type": "application/json",
  };

  const res = await fetch(path, { ...options, headers });
  if (res.status === 401) {
    // Optionally clear auth and bounce to login
    // window.location.href = "/login";
  }
  return res;
}