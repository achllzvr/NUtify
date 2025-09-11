import React from "react";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";

import "./styles/global.css";
import "bootstrap/dist/css/bootstrap.min.css";

import usePageTitle from "./hooks/usePageTitle";

// Auth context/guards
import { AuthProvider } from "./auth/AuthProvider";
import ProtectedRoute from "./auth/ProtectedRoute";
import RedirectIfAuth from "./auth/RedirectIfAuth";

// Pages
import LandingPage from "./pages/LandingPage.jsx";
import Login from "./pages/Login.jsx";
import Signup from "./pages/Signup.jsx";
import ForgotPassword from "./pages/ForgotPassword.jsx";
import ModeratorHome from "./pages/ModeratorHome.jsx";
import ModeratorHistory from "./pages/ModeratorHistory.jsx";
import ModeratorApproved from "./pages/ModeratorApproved.jsx";

function AppContent() {
  // keep dynamic titles inside Router context
  usePageTitle();
  return (
    <Routes>
      {/* Public landing */}
      <Route path="/" element={<LandingPage />} />

      {/* Keep logged-in users out of auth pages */}
      <Route element={<RedirectIfAuth />}>
        <Route path="/login" element={<Login />} />
        <Route path="/signup" element={<Signup />} />
        <Route path="/forgot-password" element={<ForgotPassword />} />
      </Route>

      {/* Moderator protected area */}
      <Route element={<ProtectedRoute requiredRoles={["moderator"]} />}>
        <Route path="/moderator/home" element={<ModeratorHome />} />
        <Route path="/moderator/history" element={<ModeratorHistory />} />
        <Route path="/moderator/approved" element={<ModeratorApproved />} />
         <Route path="/admin/home" element={<ModeratorHome />} />
        <Route path="/admin/history" element={<ModeratorHistory />} />
        <Route path="/admin/approved" element={<ModeratorApproved />} />
      </Route>

      {/* Fallbacks */}
        <Route path="/moderator" element={<Navigate to="/moderator/home" replace />} />
      <Route path="/admin" element={<Navigate to="/admin/home" replace />} />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <AppContent />
      </BrowserRouter>
    </AuthProvider>
  );
}