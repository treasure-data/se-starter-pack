import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/lib/ui-components/ui/card';
import type { StarterPack } from '@/types/deployment';
import { FileText, Workflow, Database, Zap } from 'lucide-react';

interface WorkflowPreviewProps {
  selectedPack: StarterPack;
}

export function WorkflowPreview({ selectedPack }: WorkflowPreviewProps) {
  const workflowSteps = [
    {
      icon: <Database size={16} />,
      name: 'Data Mapping',
      file: 'wf02_mapping.dig',
      description: 'Map source data to target schema'
    },
    {
      icon: <Zap size={16} />,
      name: 'Validation',
      file: 'wf03_validate.dig',
      description: 'Validate data quality and schema'
    },
    {
      icon: <FileText size={16} />,
      name: 'Staging',
      file: 'wf04_stage.dig',
      description: 'Stage data for processing'
    },
    {
      icon: <Workflow size={16} />,
      name: 'Unification',
      file: 'wf05_unify.dig',
      description: 'Unify customer identities'
    },
    {
      icon: <Database size={16} />,
      name: 'Golden Records',
      file: 'wf06_golden.dig',
      description: 'Create golden customer records'
    },
    {
      icon: <Zap size={16} />,
      name: 'Analytics',
      file: 'wf07_analytics.dig',
      description: 'Generate analytics and insights'
    }
  ];

  return (
    <Card className="h-fit">
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Workflow size={20} className="text-blue-600" />
          Workflow Preview
        </CardTitle>
        <CardDescription>
          Workflows that will be deployed with {selectedPack.name}
        </CardDescription>
      </CardHeader>
      <CardContent>
        <div className="space-y-3">
          {workflowSteps.map((step, index) => (
            <div key={index} className="flex items-start gap-3 p-3 bg-slate-50 rounded-lg">
              <div className="flex-shrink-0 w-8 h-8 bg-blue-100 text-blue-600 rounded-lg flex items-center justify-center">
                {step.icon}
              </div>
              <div className="flex-1 min-w-0">
                <h4 className="font-medium text-slate-900 text-sm">{step.name}</h4>
                <p className="text-xs text-slate-600 mt-1">{step.description}</p>
                <code className="text-xs text-slate-500 font-mono">{step.file}</code>
              </div>
              <div className="flex-shrink-0 text-xs text-slate-400">
                {index + 1}
              </div>
            </div>
          ))}
        </div>

        <div className="mt-4 p-3 bg-blue-50 rounded-lg border border-blue-200">
          <h4 className="font-medium text-blue-900 text-sm mb-1">Deployment Process</h4>
          <p className="text-xs text-blue-700">
            All workflows will be uploaded to your TD account and executed in sequence. 
            You'll receive notifications at each major step.
          </p>
        </div>
      </CardContent>
    </Card>
  );
}