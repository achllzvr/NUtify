import { useEffect } from 'react';
import { useLocation } from 'react-router-dom';

const routeTitleMap = {
  '/': 'NUtify',
  '/login': 'Login - NUtify',
  '/signup': 'Sign Up - NUtify',
  '/forgot-password': 'Forgot Password - NUtify',
  '/student/home': 'Home - NUtify',
  '/student/history': 'History - NUtify',
  '/faculty/home': 'Home - NUtify',
  '/faculty/history': 'History - NUtify',
  '/moderator/home': 'Home - NUtify',
  '/moderator/history': 'History - NUtify'
};

export const usePageTitle = () => {
  const location = useLocation();

  useEffect(() => {
    const title = routeTitleMap[location.pathname] || 'NUtify';

    document.title = title;
  }, [location.pathname]);
};

export default usePageTitle;