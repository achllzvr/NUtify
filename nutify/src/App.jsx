import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import 'bootstrap/dist/css/bootstrap.min.css';
import './styles/global.css';

// Custom hook for page titles
import usePageTitle from './hooks/usePageTitle';

// Auth Pages
import Login from './pages/Login';
import Signup from './pages/Signup';
import ForgotPassword from './pages/ForgotPassword';

// Moderator Pages
import ModeratorHome from './pages/ModeratorHome';
import ModeratorHistory from './pages/ModeratorHistory';

// Component that uses the page title hook
function AppContent() {
  // This hook will automatically update the page title based on the current route
  usePageTitle();

  return (
    <div className="App">
      <Routes>
        {/* Default route redirects to login */}
        <Route path="/" element={<Navigate to="/login" replace />} />
        
        {/* Auth Routes */}
        <Route path="/login" element={<Login />} />
        <Route path="/signup" element={<Signup />} />
        <Route path="/forgot-password" element={<ForgotPassword />} />

        {/* Moderator Routes */}
        <Route path="/moderator/home" element={<ModeratorHome />} />
        <Route path="/moderator/history" element={<ModeratorHistory />} />
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