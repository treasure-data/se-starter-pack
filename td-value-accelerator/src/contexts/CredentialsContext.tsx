import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import type { TDCredentials } from '@/types/deployment';

interface CredentialsContextType {
  credentials: TDCredentials | null;
  isConnected: boolean;
  setCredentials: (credentials: TDCredentials | null) => void;
  setIsConnected: (connected: boolean) => void;
  clearCredentials: () => void;
}

const CredentialsContext = createContext<CredentialsContextType | undefined>(undefined);

const STORAGE_KEY = 'td_credentials';
const CONNECTION_KEY = 'td_connection_status';

// Simple encryption/decryption for localStorage (basic obfuscation)
const encrypt = (text: string): string => {
  return btoa(unescape(encodeURIComponent(text)));
};

const decrypt = (encodedText: string): string => {
  try {
    return decodeURIComponent(escape(atob(encodedText)));
  } catch {
    return '';
  }
};

interface CredentialsProviderProps {
  children: ReactNode;
}

export function CredentialsProvider({ children }: CredentialsProviderProps) {
  const [credentials, setCredentialsState] = useState<TDCredentials | null>(null);
  const [isConnected, setIsConnectedState] = useState(false);

  // Load credentials from localStorage on mount
  useEffect(() => {
    const loadStoredCredentials = () => {
      try {
        const storedCredentials = localStorage.getItem(STORAGE_KEY);
        const storedConnection = localStorage.getItem(CONNECTION_KEY);
        
        if (storedCredentials) {
          const decryptedCredentials = decrypt(storedCredentials);
          const parsedCredentials = JSON.parse(decryptedCredentials);
          
          // Validate the structure
          if (parsedCredentials && 
              typeof parsedCredentials.apiKey === 'string' &&
              typeof parsedCredentials.region === 'string') {
            // Ensure environmentTokens exists
            if (!parsedCredentials.environmentTokens) {
              parsedCredentials.environmentTokens = {};
            }
            setCredentialsState(parsedCredentials);
          }
        }
        
        if (storedConnection === 'true') {
          setIsConnectedState(true);
        }
      } catch (error) {
        console.warn('Failed to load stored credentials:', error);
        // Clear corrupted data
        localStorage.removeItem(STORAGE_KEY);
        localStorage.removeItem(CONNECTION_KEY);
      }
    };

    loadStoredCredentials();
  }, []);

  const setCredentials = (newCredentials: TDCredentials | null) => {
    setCredentialsState(newCredentials);
    
    if (newCredentials) {
      try {
        const encryptedCredentials = encrypt(JSON.stringify(newCredentials));
        localStorage.setItem(STORAGE_KEY, encryptedCredentials);
      } catch (error) {
        console.error('Failed to store credentials:', error);
      }
    } else {
      localStorage.removeItem(STORAGE_KEY);
    }
  };

  const setIsConnected = (connected: boolean) => {
    setIsConnectedState(connected);
    
    if (connected) {
      localStorage.setItem(CONNECTION_KEY, 'true');
    } else {
      localStorage.removeItem(CONNECTION_KEY);
    }
  };

  const clearCredentials = () => {
    setCredentialsState(null);
    setIsConnectedState(false);
    localStorage.removeItem(STORAGE_KEY);
    localStorage.removeItem(CONNECTION_KEY);
  };

  const value: CredentialsContextType = {
    credentials,
    isConnected,
    setCredentials,
    setIsConnected,
    clearCredentials,
  };

  return (
    <CredentialsContext.Provider value={value}>
      {children}
    </CredentialsContext.Provider>
  );
}

export function useCredentials() {
  const context = useContext(CredentialsContext);
  if (context === undefined) {
    throw new Error('useCredentials must be used within a CredentialsProvider');
  }
  return context;
}

// Hook to get credentials for API calls
export function useApiCredentials() {
  const { credentials, isConnected } = useCredentials();
  
  if (!credentials || !isConnected) {
    throw new Error('No valid credentials available. Please configure your TD connection first.');
  }
  
  return credentials;
}