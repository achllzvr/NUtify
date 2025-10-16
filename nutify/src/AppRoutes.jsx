import React from "react";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import ProtectedRoute from "./auth/ProtectedRoute";
import RedirectIfAuth from "./auth/RedirectIfAuth";

import LoginPage from "./pages/LoginPage";
import ForgotPassword from "./pages/ForgotPassword";
import AppHome from "./pages/AppHome";
import AdminHome from "./pages/AdminHome";
import NotFound from "./pages/NotFound";

export default function AppRoutes() {
  return (
    <BrowserRouter>
      <Routes>
        <Route element={<RedirectIfAuth />}>
          <Route path="/login" element={<LoginPage />} />
        </Route>

        {/* Make Forgot Password publicly accessible and do not redirect if already logged in */}
        <Route path="/forgot-password" element={<ForgotPassword />} />

        <Route element={<ProtectedRoute />}>
          <Route path="/app/*" element={<AppHome />} />
        </Route>

        <Route element={<ProtectedRoute requiredRoles={['admin']} />}>
          <Route path="/admin/*" element={<AdminHome />} />
        </Route>

        <Route path="/" element={<Navigate to="/app" replace />} />
        <Route path="*" element={<NotFound />} />
      </Routes>
    </BrowserRouter>
  );
}