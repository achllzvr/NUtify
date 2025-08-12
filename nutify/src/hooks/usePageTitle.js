import { useEffect } from 'react';
import { useLocation } from 'react-router-dom';

// Route to title mapping
const routeTitleMap = {
  '/': 'NUtify',
  '/login': 'Login - NUtify',
  '/signup': 'Sign Up - NUtify',
  '/forgot-password': 'Forgot Password - NUtify',
  '/student/home': 'Home - NUtify',
  '/student/history': 'History - NUtify',
  '/faculty/home': 'Home - NUtify',
  '/faculty/history': 'History - NUtify'
};

// Custom hook for managing page titles
export const usePageTitle = () => {
  const location = useLocation();

  useEffect(() => {
    // Get the title for the current route
    const title = routeTitleMap[location.pathname] || 'NUtify';
    
    // Update the document title
    document.title = title;
  }, [location.pathname]);
};

export default usePageTitle;