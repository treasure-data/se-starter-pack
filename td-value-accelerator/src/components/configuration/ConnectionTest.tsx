import { useState } from 'react';
import { Button } from '@/lib/ui-components/ui/button';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { CheckCircle, XCircle, Wifi, AlertTriangle } from 'lucide-react';
import type { TDCredentials } from '@/types/deployment';
import { cn } from '@/lib/ui-components/lib/utils';
import { getApiUrl, API_CONFIG } from '@/config/api';

interface ConnectionTestProps {
  credentials: TDCredentials;
  onConnectionChange: (isConnected: boolean) => void;
}

interface ConnectionResult {
  status: 'success' | 'error';
  message: string;
  details?: string;
}

export function ConnectionTest({ credentials, onConnectionChange }: ConnectionTestProps) {
  const [isLoading, setIsLoading] = useState(false);
  const [connectionStatus, setConnectionStatus] = useState<'idle' | 'success' | 'error'>('idle');
  const [errorMessage, setErrorMessage] = useState('');
  const [errorDetails, setErrorDetails] = useState('');
  const [successDetails, setSuccessDetails] = useState('');

  const testConnection = async () => {
    if (!credentials.apiKey || !credentials.region) {
      const missing = [];
      if (!credentials.apiKey) missing.push('API Key');
      if (!credentials.region) missing.push('Region');
      
      setErrorMessage(`Missing required fields: ${missing.join(', ')}`);
      setErrorDetails('Please complete all fields before testing the connection.');
      setConnectionStatus('error');
      onConnectionChange(false);
      return;
    }

    setIsLoading(true);
    setConnectionStatus('idle');
    setErrorMessage('');
    setErrorDetails('');
    setSuccessDetails('');

    try {
      const response = await fetch(getApiUrl(API_CONFIG.ENDPOINTS.TD_TEST_CONNECTION), {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(credentials),
      });

      const result: ConnectionResult = await response.json();

      if (response.ok) {
        setConnectionStatus('success');
        setSuccessDetails(result.details || '');
        onConnectionChange(true);
      } else {
        setErrorMessage(result.message || getStatusCodeMessage(response.status));
        setErrorDetails(getErrorSuggestion(response.status, result.message));
        setConnectionStatus('error');
        onConnectionChange(false);
      }
    } catch (error) {
      if (error instanceof TypeError && error.message.includes('fetch')) {
        setErrorMessage('Cannot connect to backend service');
        setErrorDetails('Please ensure the backend server is running and accessible.');
      } else {
        setErrorMessage('Unexpected error occurred');
        setErrorDetails('Please try again or contact support if the issue persists.');
      }
      setConnectionStatus('error');
      onConnectionChange(false);
    } finally {
      setIsLoading(false);
    }
  };

  const getStatusCodeMessage = (status: number): string => {
    switch (status) {
      case 400:
        return 'Invalid credentials format';
      case 401:
        return 'Authentication failed';
      case 403:
        return 'Access denied';
      case 404:
        return 'Resource not found';
      case 503:
        return 'Service unavailable';
      case 504:
        return 'Connection timeout';
      default:
        return 'Connection failed';
    }
  };

  const getErrorSuggestion = (status: number, message?: string): string => {
    switch (status) {
      case 400:
        return 'Please verify your API key format and region selection.';
      case 401:
        return 'Check that your API key is correct and hasn\'t expired.';
      case 403:
        return 'Your API key may need additional permissions to access databases.';
      case 404:
        return 'Verify that the region and database name are correct.';
      case 503:
        return 'The MCP server may be offline. Please check if it\'s running on localhost:8001.';
      case 504:
        return 'The connection is taking too long. Check your network connection.';
      default:
        return 'Please check your credentials and network connection.';
    }
  };

  const getStatusIcon = () => {
    if (isLoading) return <LoadingSpinner size="sm" />;
    if (connectionStatus === 'success') return <CheckCircle size={20} className="text-green-600" />;
    if (connectionStatus === 'error') return <XCircle size={20} className="text-red-600" />;
    return <Wifi size={20} className="text-slate-400" />;
  };

  const getStatusMessage = () => {
    if (connectionStatus === 'success') return 'Connection successful';
    if (connectionStatus === 'error') return errorMessage || 'Connection failed';
    return 'Test your connection to Treasure Data';
  };

  const getStatusColor = () => {
    if (connectionStatus === 'success') return 'text-green-700';
    if (connectionStatus === 'error') return 'text-red-700';
    return 'text-slate-600';
  };

  const isFormValid = credentials.apiKey && credentials.region;

  return (
    <div className="border-t border-slate-200 pt-6">
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-3">
          {getStatusIcon()}
          <div>
            <p className={cn("text-sm font-medium", getStatusColor())}>
              {getStatusMessage()}
            </p>
            {connectionStatus === 'idle' && (
              <p className="text-xs text-slate-500">
                Verify your credentials and network connectivity
              </p>
            )}
            {connectionStatus === 'success' && (
              <p className="text-xs text-green-600">
                {successDetails || 'All systems operational - ready to proceed'}
              </p>
            )}
            {connectionStatus === 'error' && (
              <p className="text-xs text-red-600">
                {errorDetails || 'Please check your credentials and try again'}
              </p>
            )}
          </div>
        </div>
        
        <Button 
          onClick={testConnection}
          disabled={isLoading || !isFormValid}
          variant={connectionStatus === 'success' ? 'secondary' : 'default'}
          size="sm"
          className="min-w-[120px]"
        >
          {isLoading ? (
            <>
              <LoadingSpinner size="sm" />
              Testing...
            </>
          ) : connectionStatus === 'success' ? (
            <>
              <CheckCircle size={14} className="mr-2" />
              Connected
            </>
          ) : (
            <>
              <Wifi size={14} className="mr-2" />
              Test Connection
            </>
          )}
        </Button>
      </div>

      {/* Validation Warnings */}
      {!isFormValid && (
        <div className="flex items-start gap-2 p-3 bg-amber-50 border border-amber-200 rounded-lg">
          <AlertTriangle className="w-4 h-4 text-amber-600 mt-0.5 flex-shrink-0" />
          <div>
            <p className="text-sm font-medium text-amber-800">Incomplete Configuration</p>
            <p className="text-xs text-amber-700 mt-1">
              Please fill in all required fields before testing the connection.
            </p>
            <div className="flex items-center gap-3 mt-2 text-xs">
              {!credentials.apiKey && <span className="text-amber-700">• API Key required</span>}
              {!credentials.region && <span className="text-amber-700">• Region required</span>}
            </div>
          </div>
        </div>
      )}

      {/* Error Details */}
      {connectionStatus === 'error' && errorMessage && (
        <div className="flex items-start gap-2 p-3 bg-red-50 border border-red-200 rounded-lg">
          <XCircle className="w-4 h-4 text-red-600 mt-0.5 flex-shrink-0" />
          <div>
            <p className="text-sm font-medium text-red-800">Connection Failed</p>
            <p className="text-xs text-red-700 mt-1">{errorMessage}</p>
            {errorDetails && (
              <p className="text-xs text-red-600 mt-2 font-medium">
                💡 {errorDetails}
              </p>
            )}
          </div>
        </div>
      )}

      {/* Success Details */}
      {connectionStatus === 'success' && (
        <div className="flex items-start gap-2 p-3 bg-green-50 border border-green-200 rounded-lg">
          <CheckCircle className="w-4 h-4 text-green-600 mt-0.5 flex-shrink-0" />
          <div>
            <p className="text-sm font-medium text-green-800">Connection Verified</p>
            <p className="text-xs text-green-700 mt-1">
              Successfully connected to Treasure Data in {credentials.region}
            </p>
          </div>
        </div>
      )}
    </div>
  );
}