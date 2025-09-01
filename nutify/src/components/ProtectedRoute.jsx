import React, { useEffect, useState } from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { apiGet } from '../api/http';

// Simple client-side guard.
// Logic:
// 1) Quick check: localStorage.isLoggedIn === '1' (set after successful login)
// 2) Optional server ping once per mount to validate session cookie (best-effort)
export default function ProtectedRoute({ children }) {
  const location = useLocation();
  const [allowed, setAllowed] = useState(() => localStorage.getItem('isLoggedIn') === '1');
  const [checked, setChecked] = useState(false);

  useEffect(() => {
    let active = true;
    // If quick check passes, do a best-effort validation in background
    const quick = localStorage.getItem('isLoggedIn') === '1';
    if (!quick) {
      setAllowed(false);
      setChecked(true);
      return;
    }
    (async () => {
      try {
        // Try a lightweight endpoint that should require a session.
        // If your backend exposes a dedicated whoami/session route, switch to that.
        await apiGet('getUserType');
        if (active) {
          setAllowed(true);
          setChecked(true);
        }
      } catch {
        if (active) {
          localStorage.removeItem('isLoggedIn');
          localStorage.removeItem('csrfToken');
          setAllowed(false);
          setChecked(true);
        }
      }
    })();
    return () => {
      active = false;
    };
  }, [location.pathname]);

  if (!checked) return null; // avoid flicker
  if (!allowed) return <Navigate to="/login" replace state={{ from: location }} />;
  return children;
}
