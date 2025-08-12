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

// Student Pages
import StudentHome from './pages/StudentHome';
import StudentHistory from './pages/StudentHistory';

// Faculty Pages
import FacultyHome from './pages/FacultyHome';
import FacultyHistory from './pages/FacultyHistory';

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
        
        {/* Student Routes */}
        <Route path="/student/home" element={<StudentHome />} />
        <Route path="/student/history" element={<StudentHistory />} />
        
        {/* Faculty Routes */}
        <Route path="/faculty/home" element={<FacultyHome />} />
        <Route path="/faculty/history" element={<FacultyHistory />} />
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
