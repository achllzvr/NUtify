import React from "react";
import { Navigate, Outlet, useLocation } from "react-router-dom";
import { useAuth } from "./AuthProvider";

export default function RedirectIfAuth({ fallbackPath }) {
  const { isAuthenticated, loading, getHomePath } = useAuth();
  const location = useLocation();

  if (loading) return null;

  if (isAuthenticated) {
    const to = location.state?.from?.pathname || fallbackPath || getHomePath();
    return <Navigate to={to} replace />;
  }

  return <Outlet />;
}