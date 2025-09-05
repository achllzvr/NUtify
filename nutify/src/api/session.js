import { apiPost } from "./http";
import { getToken, clearAllAuth } from "../auth/authStorage";

export function isAuthenticated() {
  return !!getToken();
}

export async function doLogout() {
  try {
    await apiPost("logout", {});
  } catch {}
  // Clear both canonical and any legacy flags
  clearAllAuth();
  localStorage.removeItem("isLoggedIn");
  localStorage.removeItem("csrfToken");
}