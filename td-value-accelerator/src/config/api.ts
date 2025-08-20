// API Configuration
export const API_CONFIG = {
  BASE_URL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000',
  ENDPOINTS: {
    TD_TEST_CONNECTION: '/api/td/test-connection',
    TD_DATABASES: '/api/td/databases',
    TD_TABLES: '/api/td/tables',
    DEPLOYMENT_START: '/api/deployment/start',
    DEPLOYMENT_STATUS: '/api/deployment/status',
    GITHUB_REPOS: '/api/github/repos'
  }
};

export const getApiUrl = (endpoint: string): string => {
  return `${API_CONFIG.BASE_URL}${endpoint}`;
};