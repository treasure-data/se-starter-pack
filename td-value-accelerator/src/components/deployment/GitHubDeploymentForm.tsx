import { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/lib/ui-components/ui/card';
import { Button } from '@/lib/ui-components/ui/button';
import { Input } from '@/lib/ui-components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/lib/ui-components/ui/select';
import { Checkbox } from '@/lib/ui-components/ui/checkbox';
import { useCredentials } from '@/contexts/CredentialsContext';
import { useGitHub } from '@/contexts/GitHubContext';
import { GitHubService } from '@/services/githubService';
import type { GitHubDeploymentConfig } from '@/types/deployment';
import { CLICommandsModal } from './CLICommandsModal';
import { Github, Key, User, FolderOpen, PlayCircle, Eye, EyeOff, AlertCircle } from 'lucide-react';


interface GitHubDeploymentFormProps {
  onStartDeployment: (config: GitHubDeploymentConfig) => void;
}

export function GitHubDeploymentForm({ onStartDeployment }: GitHubDeploymentFormProps) {
  const { credentials: tdCredentials } = useCredentials();
  const { githubCredentials, setGithubCredentials } = useGitHub();
  
  const [formData, setFormData] = useState({
    clientName: '',
    projectName: '',
    selectedPackage: '',
    githubPAT: githubCredentials?.personalAccessToken || '',
    githubOrg: githubCredentials?.organization || '',
    createRuleset: true,
  });
  
  const [showPAT, setShowPAT] = useState(false);
  const [isValidating, setIsValidating] = useState(false);

  const [availablePackages, setAvailablePackages] = useState([
    { id: 'retail-starter-pack', name: 'Retail Starter Pack' },
    { id: 'qsr-starter-pack', name: 'QSR Starter Pack' },
  ]);

  // Load available packages from GitHub
  useEffect(() => {
    const loadPackages = async () => {
      try {
        const response = await fetch('http://localhost:8000/api/github/packages');
        if (response.ok) {
          const data = await response.json();
          setAvailablePackages(data.packages);
        }
      } catch (error) {
        console.error('Failed to load packages:', error);
        // Keep default packages if API fails
      }
    };

    loadPackages();
  }, []);

  const handleInputChange = (field: string, value: string | boolean) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  const validateGitHubCredentials = async () => {
    if (!formData.githubPAT) return false;
    
    setIsValidating(true);
    try {
      const githubService = new GitHubService({
        personalAccessToken: formData.githubPAT,
        organization: formData.githubOrg || undefined,
      });
      
      await githubService.getCurrentUser();
      
      // Store validated credentials
      setGithubCredentials({
        personalAccessToken: formData.githubPAT,
        organization: formData.githubOrg || undefined,
      });
      
      return true;
    } catch (error) {
      console.error('GitHub validation failed:', error);
      return false;
    } finally {
      setIsValidating(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!tdCredentials) {
      alert('TD credentials are required');
      return;
    }

    const isValidGitHub = await validateGitHubCredentials();
    if (!isValidGitHub) {
      alert('Please check your GitHub credentials');
      return;
    }

    // Build environment secrets object from credentials
    const environmentSecrets: any = {};
    if (tdCredentials?.environmentTokens?.prod) environmentSecrets.prod = tdCredentials.environmentTokens.prod;
    if (tdCredentials?.environmentTokens?.qa) environmentSecrets.qa = tdCredentials.environmentTokens.qa;
    if (tdCredentials?.environmentTokens?.dev) environmentSecrets.dev = tdCredentials.environmentTokens.dev;

    const config: GitHubDeploymentConfig = {
      clientName: formData.clientName,
      projectName: formData.projectName,
      selectedPackage: formData.selectedPackage,
      githubCredentials: {
        personalAccessToken: formData.githubPAT,
        organization: formData.githubOrg || undefined,
      },
      tdCredentials,
      createRuleset: formData.createRuleset,
      environmentSecrets,
    };

    onStartDeployment(config);
  };

  const hasAtLeastOneEnvironment = tdCredentials?.environmentTokens?.prod || tdCredentials?.environmentTokens?.qa || tdCredentials?.environmentTokens?.dev;
  
  const isFormValid = 
    formData.clientName &&
    formData.projectName &&
    formData.selectedPackage &&
    formData.githubPAT &&
    hasAtLeastOneEnvironment &&
    tdCredentials;

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center gap-2">
          <Github className="w-5 h-5 text-slate-700" />
          <div>
            <CardTitle>GitHub Repository Deployment</CardTitle>
            <CardDescription>
              Deploy your selected package to a new GitHub repository with automated CI/CD setup
            </CardDescription>
          </div>
        </div>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Environment Tokens Status */}
          {!hasAtLeastOneEnvironment && (
            <div className="flex items-center gap-2 p-3 bg-amber-50 border border-amber-200 rounded-lg">
              <AlertCircle className="w-4 h-4 text-amber-600" />
              <span className="text-sm text-amber-700">
                Please configure environment tokens in <strong>Step 1: Configuration</strong> before deploying.
              </span>
            </div>
          )}

          {/* Client Information */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label htmlFor="clientName" className="block text-sm font-medium text-slate-700 mb-2">
                <div className="flex items-center gap-2">
                  <User className="w-4 h-4 text-slate-500" />
                  Client Name
                </div>
              </label>
              <Input
                id="clientName"
                placeholder="e.g., acme-corp"
                value={formData.clientName}
                onChange={(e) => handleInputChange('clientName', e.target.value)}
                required
              />
              <p className="text-xs text-slate-500 mt-1">
                Repository will be named: <span className="font-mono">va-{formData.clientName.toLowerCase().replace(/[^a-z0-9-]/g, '-')}</span>
              </p>
              {formData.clientName && (
                <p className="text-xs text-amber-600 mt-1">
                  ⚠️ If this repository already exists, deployment will fail
                </p>
              )}
            </div>

            <div>
              <label htmlFor="projectName" className="block text-sm font-medium text-slate-700 mb-2">
                <div className="flex items-center gap-2">
                  <FolderOpen className="w-4 h-4 text-slate-500" />
                  Project Name
                </div>
              </label>
              <Input
                id="projectName"
                placeholder="e.g., customer-analytics"
                value={formData.projectName}
                onChange={(e) => handleInputChange('projectName', e.target.value)}
                required
              />
              <p className="text-xs text-slate-500 mt-1">
                Folder name within the repository
              </p>
            </div>
          </div>

          {/* Package Selection */}
          <div>
            <label htmlFor="package" className="block text-sm font-medium text-slate-700 mb-2">
              Starter Package
            </label>
            <Select value={formData.selectedPackage} onValueChange={(value) => handleInputChange('selectedPackage', value)}>
              <SelectTrigger>
                <SelectValue placeholder="Select a starter package" />
              </SelectTrigger>
              <SelectContent>
                {availablePackages.map((pkg) => (
                  <SelectItem key={pkg.id} value={pkg.id}>
                    {pkg.name}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {/* GitHub Credentials */}
          <div className="border-t pt-6">
            <h3 className="text-lg font-medium text-slate-900 mb-4">GitHub Configuration</h3>
            
            <div className="space-y-4">
              <div>
                <label htmlFor="githubPAT" className="block text-sm font-medium text-slate-700 mb-2">
                  <div className="flex items-center gap-2">
                    <Key className="w-4 h-4 text-slate-500" />
                    Personal Access Token
                  </div>
                </label>
                <div className="relative">
                  <Input
                    id="githubPAT"
                    type={showPAT ? "text" : "password"}
                    placeholder="ghp_xxxxxxxxxxxxxxxxxxxx"
                    value={formData.githubPAT}
                    onChange={(e) => handleInputChange('githubPAT', e.target.value)}
                    className="pr-10"
                    required
                  />
                  <button
                    type="button"
                    className="absolute inset-y-0 right-0 pr-3 flex items-center"
                    onClick={() => setShowPAT(!showPAT)}
                  >
                    {showPAT ? (
                      <EyeOff className="h-4 w-4 text-slate-400 hover:text-slate-600" />
                    ) : (
                      <Eye className="h-4 w-4 text-slate-400 hover:text-slate-600" />
                    )}
                  </button>
                </div>
                <p className="text-xs text-slate-500 mt-1">
                  <strong>Classic Token (Recommended):</strong> repo, admin:repo_hook, admin:org (if using organization)
                  <br />
                  <strong>Fine-grained Token:</strong> Repository permissions for Actions, Administration, Contents, and Secrets
                </p>
              </div>

              <div>
                <label htmlFor="githubOrg" className="block text-sm font-medium text-slate-700 mb-2">
                  Organization (Optional)
                </label>
                <Input
                  id="githubOrg"
                  placeholder="your-organization"
                  value={formData.githubOrg}
                  onChange={(e) => handleInputChange('githubOrg', e.target.value)}
                />
                <p className="text-xs text-slate-500 mt-1">
                  Leave empty to create in your personal account
                </p>
              </div>
            </div>
          </div>


          {/* Advanced Options */}
          <div className="border-t pt-6">
            <h3 className="text-lg font-medium text-slate-900 mb-4">Advanced Options</h3>
            
            <div className="flex items-start space-x-3">
              <Checkbox
                id="createRuleset"
                checked={formData.createRuleset}
                onCheckedChange={(checked) => handleInputChange('createRuleset', checked as boolean)}
              />
              <div>
                <label htmlFor="createRuleset" className="text-sm font-medium text-slate-700 cursor-pointer">
                  Create repository ruleset
                </label>
                <p className="text-xs text-slate-500 mt-1">
                  Enforce branch naming conventions (feat/*, fix/*, hot/*) and protect against force pushes. 
                  Requires GitHub Pro/Team/Enterprise for private repositories.
                </p>
              </div>
            </div>
          </div>

          {/* Submit Button */}
          <div className="flex justify-between items-center pt-6 border-t">
            <div className="flex items-center gap-2">
              <CLICommandsModal
                clientName={formData.clientName}
                projectName={formData.projectName}
                selectedPackage={formData.selectedPackage}
                githubOrg={formData.githubOrg}
                githubPAT={formData.githubPAT}
                createRuleset={formData.createRuleset}
                environmentSecrets={{
                  prod: tdCredentials?.environmentTokens?.prod || '',
                  qa: tdCredentials?.environmentTokens?.qa || '',
                  dev: tdCredentials?.environmentTokens?.dev || '',
                }}
                tdCredentials={tdCredentials}
              />
              <span className="text-sm text-slate-600">
                Prefer manual deployment?
              </span>
            </div>
            
            <Button 
              type="submit" 
              disabled={!isFormValid || isValidating}
              className="min-w-[180px]"
            >
              {isValidating ? (
                <>
                  <div className="w-4 h-4 animate-spin border-2 border-white border-t-transparent rounded-full mr-2" />
                  Validating...
                </>
              ) : (
                <>
                  <PlayCircle className="w-4 h-4 mr-2" />
                  Deploy to GitHub
                </>
              )}
            </Button>
          </div>
        </form>
      </CardContent>
    </Card>
  );
}