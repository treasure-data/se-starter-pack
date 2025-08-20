export interface TDCredentials {
  apiKey: string;
  region: 'us01' | 'eu01';
  environmentTokens: {
    prod?: string;
    qa?: string;
    dev?: string;
  };
}

export interface GitHubCredentials {
  personalAccessToken: string;
  organization?: string; // Optional - if empty, creates in personal account
}

export interface StarterPack {
  id: string;
  name: string;
  description: string;
  type: 'QSR' | 'Retail';
  features: string[];
  workflows: string[];
}

export interface DeploymentConfig {
  starterPack: StarterPack;
  tdCredentials: TDCredentials;
  parameters: Record<string, any>;
  customTableNames?: Record<string, string>;
}

export interface EnvironmentSecrets {
  prod?: string;
  qa?: string;
  dev?: string;
}

export interface GitHubDeploymentConfig {
  clientName: string;
  projectName: string;
  selectedPackage: string;
  githubCredentials: GitHubCredentials;
  tdCredentials: TDCredentials;
  createRuleset?: boolean;
  environmentSecrets: EnvironmentSecrets;
}

export interface DeploymentStatus {
  id: string;
  status: 'pending' | 'running' | 'completed' | 'failed';
  progress: number;
  logs: string[];
  error?: string;
  startTime: string;
  endTime?: string;
}

export interface WorkflowFile {
  name: string;
  path: string;
  content: string;
  type: 'dig' | 'yml' | 'sql' | 'py';
}