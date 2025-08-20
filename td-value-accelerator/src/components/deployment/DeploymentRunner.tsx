import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/lib/ui-components/ui/card';
import { Button } from '@/lib/ui-components/ui/button';
import { useCredentials } from '@/contexts/CredentialsContext';
import { GitHubDeploymentForm } from './GitHubDeploymentForm';
import { GitHubDeploymentProgress } from './GitHubDeploymentProgress';
import type { GitHubDeploymentConfig } from '@/types/deployment';
import { AlertTriangle, Settings, Github, CheckCircle, ExternalLink } from 'lucide-react';

export function DeploymentRunner() {
  const navigate = useNavigate();
  const { credentials, isConnected } = useCredentials();
  
  const [currentStep, setCurrentStep] = useState<'config' | 'deploying' | 'complete'>('config');
  const [deploymentConfig, setDeploymentConfig] = useState<GitHubDeploymentConfig | null>(null);
  const [repoUrl, setRepoUrl] = useState<string>('');

  // Check if credentials are available and connected
  if (!credentials || !isConnected) {
    return (
      <div className="max-w-2xl mx-auto">
        <Card className="border-amber-200 bg-amber-50">
          <CardHeader>
            <div className="flex items-center gap-3">
              <AlertTriangle className="w-5 h-5 text-amber-600" />
              <div>
                <CardTitle className="text-amber-800">TD Credentials Required</CardTitle>
                <CardDescription className="text-amber-700">
                  You need to configure and verify your Treasure Data connection before deploying.
                </CardDescription>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <Button 
              onClick={() => navigate('/configuration')}
              className="w-full"
            >
              <Settings className="w-4 h-4 mr-2" />
              Go to Configuration
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  const handleStartDeployment = (config: GitHubDeploymentConfig) => {
    setDeploymentConfig(config);
    setCurrentStep('deploying');
  };

  const handleDeploymentComplete = (success: boolean, repositoryUrl?: string) => {
    if (success && repositoryUrl) {
      setRepoUrl(repositoryUrl);
    }
    setCurrentStep('complete');
  };

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      {/* Page Header */}
      <div className="border-b border-slate-200 pb-5">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-purple-600 rounded-lg flex items-center justify-center">
            <Github className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-slate-900">Deploy to GitHub</h1>
            <p className="text-slate-600 mt-1">
              Create a new GitHub repository with your selected starter pack and automated CI/CD setup.
            </p>
          </div>
        </div>
      </div>

      {/* Configuration Step */}
      {currentStep === 'config' && (
        <GitHubDeploymentForm onStartDeployment={handleStartDeployment} />
      )}

      {/* Deployment Progress Step */}
      {currentStep === 'deploying' && deploymentConfig && (
        <GitHubDeploymentProgress 
          config={deploymentConfig}
          onComplete={handleDeploymentComplete}
        />
      )}

      {/* Completion Step */}
      {currentStep === 'complete' && (
        <div className="space-y-6">
          <Card className="border-green-200 bg-green-50">
            <CardHeader>
              <div className="flex items-center gap-3">
                <CheckCircle className="w-6 h-6 text-green-600" />
                <div>
                  <CardTitle className="text-green-800">Deployment Complete!</CardTitle>
                  <CardDescription className="text-green-700">
                    Your GitHub repository has been successfully created and configured.
                  </CardDescription>
                </div>
              </div>
            </CardHeader>
            {repoUrl && (
              <CardContent>
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm text-green-700 mb-1">Repository URL:</p>
                    <p className="font-mono text-sm text-green-800">{repoUrl}</p>
                  </div>
                  <Button 
                    onClick={() => window.open(repoUrl, '_blank')}
                    className="bg-green-600 hover:bg-green-700"
                  >
                    <ExternalLink className="w-4 h-4 mr-2" />
                    Open Repository
                  </Button>
                </div>
              </CardContent>
            )}
          </Card>

          {/* Next Steps */}
          <Card>
            <CardHeader>
              <CardTitle>Next Steps</CardTitle>
              <CardDescription>
                Your repository is ready for development. Here's what you can do next:
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-3 text-sm">
                <div className="flex items-start gap-3">
                  <div className="w-6 h-6 bg-blue-100 rounded-full flex items-center justify-center text-blue-600 font-semibold text-xs mt-0.5">
                    1
                  </div>
                  <div>
                    <p className="font-medium">Clone the repository locally</p>
                    <p className="text-slate-600">Start working on your project by cloning the repository to your local machine.</p>
                  </div>
                </div>
                <div className="flex items-start gap-3">
                  <div className="w-6 h-6 bg-blue-100 rounded-full flex items-center justify-center text-blue-600 font-semibold text-xs mt-0.5">
                    2
                  </div>
                  <div>
                    <p className="font-medium">Switch to the development branch</p>
                    <p className="text-slate-600">Use <code className="bg-slate-100 px-1 rounded">git checkout feat/dev</code> to start development.</p>
                  </div>
                </div>
                <div className="flex items-start gap-3">
                  <div className="w-6 h-6 bg-blue-100 rounded-full flex items-center justify-center text-blue-600 font-semibold text-xs mt-0.5">
                    3
                  </div>
                  <div>
                    <p className="font-medium">Configure your workflows</p>
                    <p className="text-slate-600">GitHub Actions are ready with TD credentials for prod, qa, and dev environments.</p>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Reset Button */}
          <div className="flex justify-center">
            <Button 
              variant="outline" 
              onClick={() => {
                setCurrentStep('config');
                setDeploymentConfig(null);
                setRepoUrl('');
              }}
            >
              Deploy Another Repository
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}