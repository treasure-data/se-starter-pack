import { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/lib/ui-components/ui/card';
import { Button } from '@/lib/ui-components/ui/button';
import { Input } from '@/lib/ui-components/ui/input';
import type { StarterPack } from '@/types/deployment';
import { WorkflowPreview } from './WorkflowPreview';
import { ParameterEditor } from './ParameterEditor';

interface DeploymentConfigProps {
  selectedPack: StarterPack;
  onStartDeployment: (config: any) => void;
}

export function DeploymentConfig({ selectedPack, onStartDeployment }: DeploymentConfigProps) {
  const [parameters, setParameters] = useState({
    email_ids: ['admin@company.com'],
    table_prefix: selectedPack.type.toLowerCase(),
    environment: 'production'
  });
  
  const [customTableNames] = useState<Record<string, string>>({});
  const [isDeploying, setIsDeploying] = useState(false);

  const handleDeploy = async () => {
    setIsDeploying(true);
    
    const config = {
      starterPack: selectedPack,
      parameters,
      customTableNames
    };

    await onStartDeployment(config);
    setIsDeploying(false);
  };

  return (
    <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <div className="space-y-6">
        <Card>
          <CardHeader>
            <CardTitle>Deployment Parameters</CardTitle>
            <CardDescription>
              Configure the parameters for your {selectedPack.name} deployment.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <ParameterEditor
              parameters={parameters}
              onChange={setParameters}
            />
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Table Configuration</CardTitle>
            <CardDescription>
              Customize table names if needed (optional).
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">
                Table Prefix
              </label>
              <Input
                value={parameters.table_prefix}
                onChange={(e) => setParameters(prev => ({ ...prev, table_prefix: e.target.value }))}
                placeholder="e.g., retail, qsr"
              />
              <p className="text-xs text-slate-500 mt-1">
                All tables will be prefixed with this value
              </p>
            </div>
          </CardContent>
        </Card>

        <div className="flex gap-3">
          <Button
            onClick={handleDeploy}
            disabled={isDeploying}
            className="flex-1"
          >
            {isDeploying ? 'Starting Deployment...' : 'Start Deployment'}
          </Button>
        </div>
      </div>

      <div>
        <WorkflowPreview selectedPack={selectedPack} />
      </div>
    </div>
  );
}