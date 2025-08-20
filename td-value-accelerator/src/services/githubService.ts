import type { GitHubCredentials, TDCredentials } from '@/types/deployment';

export class GitHubService {
  private token: string;
  private organization?: string;
  private baseUrl = 'https://api.github.com';

  constructor(credentials: GitHubCredentials) {
    this.token = credentials.personalAccessToken;
    this.organization = credentials.organization;
  }

  private async makeRequest(endpoint: string, options: RequestInit = {}) {
    const url = `${this.baseUrl}${endpoint}`;
    const response = await fetch(url, {
      ...options,
      headers: {
        'Authorization': `Bearer ${this.token}`,
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
        'Content-Type': 'application/json',
        ...options.headers,
      },
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`HTTP ${response.status}: ${errorText}`);
    }

    return response.json();
  }

  async createRepository(clientName: string) {
    const repoName = `va-${clientName.toLowerCase().replace(/[^a-z0-9-]/g, '-')}`;
    const endpoint = this.organization 
      ? `/orgs/${this.organization}/repos`
      : '/user/repos';

    const repoData = {
      name: repoName,
      description: `Value Accelerator deployment for ${clientName}`,
      private: false,
      auto_init: true,
      gitignore_template: 'Python',
    };

    try {
      const repo = await this.makeRequest(endpoint, {
        method: 'POST',
        body: JSON.stringify(repoData),
      });

      return { ...repo, repoName };
    } catch (error: any) {
      // Handle specific GitHub API errors
      if (error.message.includes('422')) {
        // Parse the error response for more details
        try {
          const errorMatch = error.message.match(/HTTP 422[:\s]+(.*)/);
          if (errorMatch) {
            const errorData = JSON.parse(errorMatch[1]);
            if (errorData.errors && errorData.errors[0]) {
              const githubError = errorData.errors[0];
              if (githubError.code === 'custom' && githubError.field === 'name') {
                throw new Error(`Repository '${repoName}' already exists. Please choose a different client name or delete the existing repository.`);
              }
            }
            throw new Error(`Repository creation failed: ${errorData.message}`);
          }
        } catch (parseError) {
          // Fallback if we can't parse the error
          throw new Error(`Repository '${repoName}' already exists or creation failed. Please choose a different client name.`);
        }
      }
      // Re-throw other errors
      throw error;
    }
  }

  async createEnvironmentSecrets(
    repoName: string, 
    tdCredentials: TDCredentials, 
    projectName: string
  ) {
    const owner = this.organization || 'owner'; // Will need to get actual username if no org

    const environments = ['prod', 'qa', 'dev'];
    const secrets = {
      TD_API_TOKEN: tdCredentials.apiKey,
    };

    const results = [];

    for (const env of environments) {
      // Create environment first
      await this.makeRequest(`/repos/${owner}/${repoName}/environments/${env}`, {
        method: 'PUT',
        body: JSON.stringify({
          wait_timer: 0,
          reviewers: [],
          deployment_branch_policy: null,
        }),
      });

      // Add secrets to environment
      for (const [secretName, secretValue] of Object.entries(secrets)) {
        // Get public key for encryption
        const publicKeyResponse = await this.makeRequest(
          `/repos/${owner}/${repoName}/environments/${env}/secrets/public-key`
        );

        // In a real implementation, you'd encrypt the secret value with the public key
        // For now, we'll use a placeholder approach
        const encryptedValue = btoa(secretValue); // Basic encoding - should use proper encryption

        await this.makeRequest(
          `/repos/${owner}/${repoName}/environments/${env}/secrets/${secretName}`,
          {
            method: 'PUT',
            body: JSON.stringify({
              encrypted_value: encryptedValue,
              key_id: publicKeyResponse.key_id,
            }),
          }
        );
      }

      results.push({ environment: env, secrets: Object.keys(secrets) });
    }

    return results;
  }

  async createRepositoryVariables(
    repoName: string,
    tdCredentials: TDCredentials,
    projectName: string
  ) {
    const owner = this.organization || 'owner';
    
    // TD Workflow API endpoint based on region
    const getWorkflowEndpoint = (region: string) => {
      if (region === 'us01') return 'https://api-workflow.treasuredata.com';
      return `https://api-workflow.${region}.treasuredata.com`;
    };

    const variables = {
      TD_WF_API_ENDPOINT: getWorkflowEndpoint(tdCredentials.region),
      TD_WF_PROJS: projectName,
    };

    const results = [];

    for (const [variableName, variableValue] of Object.entries(variables)) {
      await this.makeRequest(
        `/repos/${owner}/${repoName}/actions/variables`,
        {
          method: 'POST',
          body: JSON.stringify({
            name: variableName,
            value: variableValue,
          }),
        }
      );

      results.push({ name: variableName, value: variableValue });
    }

    return results;
  }

  async createRuleset(repoName: string) {
    const owner = this.organization || 'owner';
    
    const rulesetData = {
      name: "Enforce Branch Names",
      target: "branch",
      enforcement: "active",
      conditions: {
        ref_name: {
          exclude: ["refs/heads/main"],
          include: ["~ALL"]
        }
      },
      rules: [
        {
          type: "non_fast_forward"
        },
        {
          type: "branch_name_pattern",
          parameters: {
            operator: "regex",
            pattern: "^(feat|fix|hot)\\/[a-z0-9._-]+$",
            negate: false,
            name: ""
          }
        }
      ],
      bypass_actors: []
    };

    return await this.makeRequest(`/repos/${owner}/${repoName}/rulesets`, {
      method: 'POST',
      body: JSON.stringify(rulesetData),
    });
  }

  async createBranch(repoName: string, branchName: string) {
    const owner = this.organization || 'owner';
    
    // Get the SHA of the main branch
    const mainBranch = await this.makeRequest(`/repos/${owner}/${repoName}/git/ref/heads/main`);
    const mainSha = mainBranch.object.sha;

    // Create new branch
    return await this.makeRequest(`/repos/${owner}/${repoName}/git/refs`, {
      method: 'POST',
      body: JSON.stringify({
        ref: `refs/heads/${branchName}`,
        sha: mainSha,
      }),
    });
  }

  async copyPackageFiles(repoName: string, packageName: string, projectName: string, sessionId?: string, useProjectPrefix: boolean = false, createRuleset: boolean = true, environmentSecrets?: any) {
    const owner = this.organization || await this.getCurrentUser().then(user => user.login);
    
    const response = await fetch('http://localhost:8000/api/github/copy-package', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        github_token: this.token,
        organization: this.organization,
        repo_name: repoName,
        package_name: packageName,
        project_name: projectName,
        session_id: sessionId,
        use_project_prefix: useProjectPrefix,
        create_ruleset: createRuleset,
        environment_secrets: environmentSecrets || {},
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Failed to copy package files: ${errorText}`);
    }

    return await response.json();
  }

  async getCopyProgress(sessionId: string) {
    const response = await fetch(`http://localhost:8000/api/github/copy-progress/${sessionId}`);
    
    if (!response.ok) {
      throw new Error(`Failed to get copy progress: ${response.statusText}`);
    }

    return await response.json();
  }

  async getCurrentUser() {
    return await this.makeRequest('/user');
  }
}