import React from "react";
import { Navigate, Outlet, useLocation } from "react-router-dom";
import { useAuth } from "./AuthProvider";

export default function RedirectIfAuth({ fallbackPath }) {
  const { isAuthenticated, loading } = useAuth();
  const location = useLocation();

  if (loading) return null;

  if (isAuthenticated) {
    // Only redirect when there's an explicit origin (e.g., came from a protected route)
    // or when a fallbackPath is provided by the caller. Otherwise, allow access
    // (e.g., a logged-in moderator can visit /login without being forced to /moderator/home).
    const fromPath = location.state?.from?.pathname;
    if (fromPath) return <Navigate to={fromPath} replace />;
    if (fallbackPath) return <Navigate to={fallbackPath} replace />;
    // No automatic redirect to role-based home by default
    return <Outlet />;
  }

  return <Outlet />;
}