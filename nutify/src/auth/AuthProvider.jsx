import React, { createContext, useContext, useEffect, useMemo, useState } from "react";
import { getToken, getUser, setToken, setUser, clearAllAuth } from "./authStorage";

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

  const logout = () => {
    clearAllAuth();
    setTok(null);
    setUsr(null);
  };

  const isAuthenticated = !!token;

  // If you have more roles, add mappings here.
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