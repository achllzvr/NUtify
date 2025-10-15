// Central API URL config. Set VITE_API_URL in a .env file to override.
// In dev, use the proxy (/api) to avoid CORS; in prod, use the full URL.
const isDev = import.meta.env.DEV;
export const API_URL = isDev
	? '/api'
	: (import.meta.env.VITE_API_URL || 'https://nutify.site/api.php');
