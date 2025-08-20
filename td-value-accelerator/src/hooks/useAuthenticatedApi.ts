import { useApiCredentials } from '@/contexts/CredentialsContext';

interface ApiRequestOptions extends Omit<RequestInit, 'headers'> {
  headers?: Record<string, string>;
}

export function useAuthenticatedApi() {
  const credentials = useApiCredentials();

  const makeAuthenticatedRequest = async (url: string, options: ApiRequestOptions = {}) => {
    const { headers = {}, ...restOptions } = options;

    // Add TD credentials to headers
    const authenticatedHeaders = {
      'Content-Type': 'application/json',
      'X-TD-API-KEY': credentials.apiKey,
      'X-TD-REGION': credentials.region,
      ...headers,
    };

    const response = await fetch(url, {
      ...restOptions,
      headers: authenticatedHeaders,
    });

    if (!response.ok) {
      const errorText = await response.text().catch(() => 'Unknown error');
      throw new Error(`API request failed (${response.status}): ${errorText}`);
    }

    return response;
  };

  const get = (url: string, options?: Omit<ApiRequestOptions, 'method' | 'body'>) =>
    makeAuthenticatedRequest(url, { ...options, method: 'GET' });

  const post = (url: string, data?: any, options?: Omit<ApiRequestOptions, 'method'>) =>
    makeAuthenticatedRequest(url, {
      ...options,
      method: 'POST',
      body: data ? JSON.stringify(data) : undefined,
    });

  const put = (url: string, data?: any, options?: Omit<ApiRequestOptions, 'method'>) =>
    makeAuthenticatedRequest(url, {
      ...options,
      method: 'PUT',
      body: data ? JSON.stringify(data) : undefined,
    });

  const del = (url: string, options?: Omit<ApiRequestOptions, 'method' | 'body'>) =>
    makeAuthenticatedRequest(url, { ...options, method: 'DELETE' });

  return {
    makeAuthenticatedRequest,
    get,
    post,
    put,
    delete: del,
    credentials, // Expose credentials for direct access if needed
  };
}