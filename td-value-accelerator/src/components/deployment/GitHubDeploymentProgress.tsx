import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/lib/ui-components/ui/card';
import { Button } from '@/lib/ui-components/ui/button';
import { GitHubService } from '@/services/githubService';
import type { GitHubDeploymentConfig } from '@/types/deployment';
import { 
  CheckCircle, 
  XCircle, 
  Loader2, 
  Github, 
  FolderPlus, 
  Key, 
  Settings,
  ShieldCheck, 
  GitBranch,
  ExternalLink 
} from 'lucide-react';

interface DeploymentStep {
  id: string;
  title: string;
  description: string;
  status: 'pending' | 'running' | 'completed' | 'failed';
  error?: string;
}

interface GitHubDeploymentProgressProps {
  config: GitHubDeploymentConfig;
  onComplete: (success: boolean, repoUrl?: string) => void;
}

export function GitHubDeploymentProgress({ config, onComplete }: GitHubDeploymentProgressProps) {
  const [steps, setSteps] = useState<DeploymentStep[]>([
    {
      id: 'create-repo',
      title: 'Create Repository',
      description: `Creating va-${config.clientName} repository`,
      status: 'pending',
    },
    {
      id: 'copy-files',
      title: 'Copy Package Files',
      description: `Copying ${config.selectedPackage} to ${config.projectName}`,
      status: 'pending',
    },
    {
      id: 'setup-secrets',
      title: 'Configure Secrets',
      description: 'Setting up TD API tokens for prod, qa, dev environments',
      status: 'pending',
    },
    {
      id: 'setup-variables',
      title: 'Configure Variables',
      description: 'Setting up TD workflow configuration variables',
      status: 'pending',
    },
    {
      id: 'create-ruleset',
      title: 'Apply Branch Rules',
      description: 'Setting up branch name enforcement rules',
      status: 'pending',
    },
    {
      id: 'create-branch',
      title: 'Create Development Branch',
      description: 'Creating feat/dev branch',
      status: 'pending',
    },
  ]);

  const [repoUrl, setRepoUrl] = useState<string>('');
  const [deploymentStarted, setDeploymentStarted] = useState(false);

  const updateStepStatus = (stepId: string, status: DeploymentStep['status'], error?: string) => {
    setSteps(prev => prev.map(step => 
      step.id === stepId 
        ? { ...step, status, error }
        : step
    ));
  };

  const runDeployment = async () => {
    const githubService = new GitHubService(config.githubCredentials);
    let createdRepoUrl = '';

    try {
      // Step 1: Create Repository
      updateStepStatus('create-repo', 'running');
      try {
        const repo = await githubService.createRepository(config.clientName);
        createdRepoUrl = repo.html_url;
        setRepoUrl(createdRepoUrl);
        updateStepStatus('create-repo', 'completed');
      } catch (repoError: any) {
        updateStepStatus('create-repo', 'failed', repoError.message);
        onComplete(false);
        return;
      }

      // Step 2: Copy Package Files
      updateStepStatus('copy-files', 'running');
      try {
        // Generate a session ID for progress tracking
        const sessionId = Date.now().toString();
        
        // Start the copy operation
        const copyPromise = githubService.copyPackageFiles(
          `va-${config.clientName}`, 
          config.selectedPackage, 
          config.projectName,
          sessionId,
          false,  // Don't use project prefix - place files at repository root
          config.createRuleset !== false,  // Default to true if not specified
          config.environmentSecrets  // Pass environment secrets
        );
        
        // Poll for progress updates
        const progressInterval = setInterval(async () => {
          try {
            const progress = await githubService.getCopyProgress(sessionId);
            console.log('Copy progress:', progress);
            
            // Update the step description with progress
            setSteps(prev => prev.map(step => 
              step.id === 'copy-files' 
                ? { 
                    ...step, 
                    description: `Copying ${config.selectedPackage} files: ${progress.files_created || 0}/${progress.total_files || 0} files (${progress.current_file || 'Starting...'})`
                  }
                : step
            ));
            
            // Clear interval when done
            if (progress.status === 'completed' || progress.status === 'completed_with_errors' || progress.status === 'error') {
              clearInterval(progressInterval);
            }
          } catch (progressError) {
            console.error('Failed to get progress:', progressError);
          }
        }, 1000); // Poll every second
        
        // Wait for copy to complete
        const copyResult = await copyPromise;
        clearInterval(progressInterval);
        
        if (copyResult.success) {
          updateStepStatus('copy-files', 'completed');
        } else {
          updateStepStatus('copy-files', 'failed', `${copyResult.failed_count} files failed to copy`);
          onComplete(false);
          return;
        }
        
        console.log('Copy result:', copyResult);
      } catch (copyError: any) {
        updateStepStatus('copy-files', 'failed', copyError.message);
        onComplete(false);
        return;
      }

      // Step 3: Setup Environment Secrets
      updateStepStatus('setup-secrets', 'running');
      try {
        await githubService.createEnvironmentSecrets(
          `va-${config.clientName}`,
          config.tdCredentials,
          config.projectName
        );
        updateStepStatus('setup-secrets', 'completed');
      } catch (secretsError: any) {
        updateStepStatus('setup-secrets', 'failed', secretsError.message);
        onComplete(false);
        return;
      }

      // Step 4: Setup Repository Variables
      updateStepStatus('setup-variables', 'running');
      try {
        await githubService.createRepositoryVariables(
          `va-${config.clientName}`,
          config.tdCredentials,
          config.projectName
        );
        updateStepStatus('setup-variables', 'completed');
      } catch (variablesError: any) {
        updateStepStatus('setup-variables', 'failed', variablesError.message);
        onComplete(false);
        return;
      }

      // Step 5: Create Ruleset
      updateStepStatus('create-ruleset', 'running');
      try {
        await githubService.createRuleset(`va-${config.clientName}`);
        updateStepStatus('create-ruleset', 'completed');
      } catch (rulesetError: any) {
        updateStepStatus('create-ruleset', 'failed', rulesetError.message);
        onComplete(false);
        return;
      }

      // Step 6: Create Development Branch
      updateStepStatus('create-branch', 'running');
      try {
        await githubService.createBranch(`va-${config.clientName}`, 'feat/dev');
        updateStepStatus('create-branch', 'completed');
        onComplete(true, createdRepoUrl);
      } catch (branchError: any) {
        updateStepStatus('create-branch', 'failed', branchError.message);
        onComplete(false);
      }

    } catch (error) {
      // This should not be reached with individual error handling above
      console.error('Unexpected deployment error:', error);
      onComplete(false);
    }
  };

  useEffect(() => {
    if (!deploymentStarted) {
      setDeploymentStarted(true);
      runDeployment();
    }
  }, []); // Empty dependency array to run only once

  const getStepIcon = (step: DeploymentStep) => {
    switch (step.status) {
      case 'completed':
        return <CheckCircle className="w-5 h-5 text-green-600" />;
      case 'running':
        return <Loader2 className="w-5 h-5 text-blue-600 animate-spin" />;
      case 'failed':
        return <XCircle className="w-5 h-5 text-red-600" />;
      default:
        return <div className="w-5 h-5 border-2 border-slate-300 rounded-full" />;
    }
  };

  const getStepIconForId = (stepId: string) => {
    const iconMap = {
      'create-repo': <Github className="w-4 h-4" />,
      'copy-files': <FolderPlus className="w-4 h-4" />,
      'setup-secrets': <Key className="w-4 h-4" />,
      'setup-variables': <Settings className="w-4 h-4" />,
      'create-ruleset': <ShieldCheck className="w-4 h-4" />,
      'create-branch': <GitBranch className="w-4 h-4" />,
    };
    return iconMap[stepId as keyof typeof iconMap] || null;
  };

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Github className="w-5 h-5" />
            Deploying to GitHub
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {steps.map((step, index) => (
              <div key={step.id} className="flex items-start gap-4">
                <div className="flex flex-col items-center">
                  {getStepIcon(step)}
                  {index < steps.length - 1 && (
                    <div className={`w-px h-8 mt-2 ${
                      step.status === 'completed' ? 'bg-green-200' : 'bg-slate-200'
                    }`} />
                  )}
                </div>
                
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 mb-1">
                    {getStepIconForId(step.id)}
                    <h3 className={`font-medium ${
                      step.status === 'completed' ? 'text-green-700' :
                      step.status === 'running' ? 'text-blue-700' :
                      step.status === 'failed' ? 'text-red-700' :
                      'text-slate-700'
                    }`}>
                      {step.title}
                    </h3>
                  </div>
                  
                  <p className="text-sm text-slate-600 mb-2">
                    {step.description}
                  </p>
                  
                  {step.status === 'failed' && step.error && (
                    <div className="bg-red-50 border border-red-200 rounded-lg p-3">
                      <p className="text-sm text-red-700">
                        <strong>Error:</strong> {step.error}
                      </p>
                    </div>
                  )}
                  
                  {step.status === 'completed' && step.id === 'create-repo' && repoUrl && (
                    <div className="bg-green-50 border border-green-200 rounded-lg p-3">
                      <p className="text-sm text-green-700 mb-2">
                        Repository created successfully!
                      </p>
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => window.open(repoUrl, '_blank')}
                        className="text-green-700 border-green-300 hover:bg-green-100"
                      >
                        <ExternalLink className="w-4 h-4 mr-2" />
                        View Repository
                      </Button>
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Repository Summary */}
      {repoUrl && (
        <Card className="border-blue-200 bg-blue-50">
          <CardHeader>
            <CardTitle className="text-blue-800">Deployment Summary</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3 text-sm">
              <div className="flex justify-between">
                <span className="text-blue-700">Repository:</span>
                <span className="font-mono text-blue-900">va-{config.clientName}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-blue-700">Project Folder:</span>
                <span className="font-mono text-blue-900">{config.projectName}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-blue-700">Package:</span>
                <span className="font-mono text-blue-900">{config.selectedPackage}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-blue-700">Environments:</span>
                <span className="font-mono text-blue-900">prod, qa, dev</span>
              </div>
              <div className="flex justify-between">
                <span className="text-blue-700">Development Branch:</span>
                <span className="font-mono text-blue-900">feat/dev</span>
              </div>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}