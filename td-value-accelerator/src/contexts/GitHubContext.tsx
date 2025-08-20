import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import type { GitHubCredentials } from '@/types/deployment';

interface GitHubContextType {
  githubCredentials: GitHubCredentials | null;
  setGithubCredentials: (credentials: GitHubCredentials | null) => void;
  clearGithubCredentials: () => void;
}

const GitHubContext = createContext<GitHubContextType | undefined>(undefined);

const GITHUB_STORAGE_KEY = 'github_credentials';

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

interface GitHubProviderProps {
  children: ReactNode;
}

export function GitHubProvider({ children }: GitHubProviderProps) {
  const [githubCredentials, setGithubCredentialsState] = useState<GitHubCredentials | null>(null);

  // Load credentials from localStorage on mount
  useEffect(() => {
    const loadStoredCredentials = () => {
      try {
        const storedCredentials = localStorage.getItem(GITHUB_STORAGE_KEY);
        
        if (storedCredentials) {
          const decryptedCredentials = decrypt(storedCredentials);
          const parsedCredentials = JSON.parse(decryptedCredentials);
          
          // Validate the structure
          if (parsedCredentials && 
              typeof parsedCredentials.personalAccessToken === 'string') {
            setGithubCredentialsState(parsedCredentials);
          }
        }
      } catch (error) {
        console.warn('Failed to load stored GitHub credentials:', error);
        // Clear corrupted data
        localStorage.removeItem(GITHUB_STORAGE_KEY);
      }
    };

    loadStoredCredentials();
  }, []);

  const setGithubCredentials = (newCredentials: GitHubCredentials | null) => {
    setGithubCredentialsState(newCredentials);
    
    if (newCredentials) {
      try {
        const encryptedCredentials = encrypt(JSON.stringify(newCredentials));
        localStorage.setItem(GITHUB_STORAGE_KEY, encryptedCredentials);
      } catch (error) {
        console.error('Failed to store GitHub credentials:', error);
      }
    } else {
      localStorage.removeItem(GITHUB_STORAGE_KEY);
    }
  };

  const clearGithubCredentials = () => {
    setGithubCredentialsState(null);
    localStorage.removeItem(GITHUB_STORAGE_KEY);
  };

  const value: GitHubContextType = {
    githubCredentials,
    setGithubCredentials,
    clearGithubCredentials,
  };

  return (
    <GitHubContext.Provider value={value}>
      {children}
    </GitHubContext.Provider>
  );
}

export function useGitHub() {
  const context = useContext(GitHubContext);
  if (context === undefined) {
    throw new Error('useGitHub must be used within a GitHubProvider');
  }
  return context;
}