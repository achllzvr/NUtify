import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';

import './styles/global.css';
import 'bootstrap/dist/css/bootstrap.min.css';

// Custom hook for page titles
import usePageTitle from './hooks/usePageTitle';

// Auth Pages
import Login from './pages/Login';
import Signup from './pages/Signup';
import ForgotPassword from './pages/ForgotPassword';
import LandingPage from './pages/LandingPage';

// Moderator Pages
import ModeratorHome from './pages/ModeratorHome';
import ModeratorHistory from './pages/ModeratorHistory';
import ProtectedRoute from './components/ProtectedRoute';
import ModeratorApproved from './pages/ModeratorApproved'; // Add this import

// Component that uses the page title hook
function AppContent() {
  // This hook will automatically update the page title based on the current route
  usePageTitle();

  return (
    <div className="App">
      <Routes>
        {/* Default route shows landing page */}
        <Route path="/" element={<LandingPage />} />
        
        {/* Auth Routes */}
        <Route path="/login" element={<Login />} />
        <Route path="/signup" element={<Signup />} />
        <Route path="/forgot-password" element={<ForgotPassword />} />

        {/* Moderator Routes (protected) */}
        <Route
          path="/moderator/home"
          element={
            <ProtectedRoute>
              <ModeratorHome />
            </ProtectedRoute>
          }
        />
        <Route path="/moderator/approved" element={<ModeratorApproved />} /> {/* Add this route */}
        <Route
          path="/moderator/history"
          element={
            <ProtectedRoute>
              <ModeratorHistory />
            </ProtectedRoute>
          }
        />

        {/* Fallback: redirect unknown paths to landing or login */}
        <Route path="*" element={<Navigate to="/login" replace />} />
        
      </Routes>
    </div>
  );
}

function App() {
  return (
    <Router>
      <AppContent />
    </Router>
  );
}

export default App;