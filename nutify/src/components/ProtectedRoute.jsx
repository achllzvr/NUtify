import React from 'react';
import { Navigate, useLocation, Outlet } from 'react-router-dom';
import { useAuth } from '../auth/AuthProvider';

// Router v6 guard: must render <Outlet/> for nested routes.
// Props: requiredRoles?: string[] (e.g., ['moderator'])
export default function ProtectedRoute({ requiredRoles }) {
  const location = useLocation();
  const { isAuthenticated, user, loading } = useAuth();

  if (loading) return null;
  if (!isAuthenticated) {
    return <Navigate to="/login" replace state={{ from: location }} />;
  }

  if (Array.isArray(requiredRoles) && requiredRoles.length > 0) {
    const role = (user?.role || user?.user_type || '').toString().toLowerCase();
    const allowed = requiredRoles.map(r => r.toLowerCase()).includes(role);
    if (!allowed) {
      return <Navigate to="/" replace />;
    }
  }

  return <Outlet />;
}
