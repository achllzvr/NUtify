import React, { createContext, useContext, useEffect, useMemo, useState } from "react";
import { getToken, getUser, setToken, setUser, clearAllAuth } from "./authStorage";
import { apiPost } from "../api/http";

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [token, setTok] = useState(null);
  const [user, setUsr] = useState(null);
  const [loading, setLoading] = useState(true);

  // Hydrate from localStorage on first mount
  useEffect(() => {
    const t = getToken();
    const u = getUser();
    if (t && u) {
      setTok(t);
      setUsr(u);
    }
    setLoading(false);
  }, []);

  const login = (newToken, newUser) => {
    setToken(newToken);
    setUser(newUser);
    setTok(newToken);
    setUsr(newUser);
  };

  const logout = async () => {
    // Optional: inform backend
    try {
      await apiPost("logout", {});
    } catch {
      // no-op
    }
    // Clear legacy flags (if any linger)
    localStorage.removeItem("isLoggedIn");
    localStorage.removeItem("csrfToken");

    // Clear canonical auth
    clearAllAuth();
    setTok(null);
    setUsr(null);
  };

  const isAuthenticated = !!token;

  const getHomePath = () => {
    if (!user) return "/login";
    switch (user.role) {
      case "moderator":
        return "/moderator/home";
      default:
        return "/";
    }
  };

  const value = useMemo(
    () => ({ token, user, isAuthenticated, loading, login, logout, getHomePath }),
    [token, user, isAuthenticated, loading]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used within <AuthProvider>");
  return ctx;
}