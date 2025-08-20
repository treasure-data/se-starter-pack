import type { StarterPack } from '@/types/deployment';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/lib/ui-components/ui/card';
import { Button } from '@/lib/ui-components/ui/button';
import { useNavigate } from 'react-router-dom';
import { FileText, Workflow, ArrowRight } from 'lucide-react';

interface PackagePreviewProps {
  pack: StarterPack;
}

export function PackagePreview({ pack }: PackagePreviewProps) {
  const navigate = useNavigate();

  const handleProceed = () => {
    navigate('/deployment', { state: { selectedPack: pack } });
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <FileText size={20} className="text-blue-600" />
          Package Preview
        </CardTitle>
        <CardDescription>
          Review what will be deployed with {pack.name}
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-6">
        <div>
          <h3 className="font-medium text-slate-900 mb-2">Package Details</h3>
          <div className="bg-slate-50 rounded-lg p-3 text-sm">
            <div className="grid grid-cols-2 gap-2">
              <span className="text-slate-600">Name:</span>
              <span className="font-medium">{pack.name}</span>
              <span className="text-slate-600">Type:</span>
              <span className="font-medium">{pack.type}</span>
              <span className="text-slate-600">Workflows:</span>
              <span className="font-medium">{pack.workflows.length}</span>
            </div>
          </div>
        </div>

        <div>
          <h3 className="font-medium text-slate-900 mb-2">Features Included</h3>
          <ul className="space-y-2">
            {pack.features.map((feature, index) => (
              <li key={index} className="flex items-start gap-2 text-sm">
                <div className="w-1.5 h-1.5 bg-blue-500 rounded-full mt-2 flex-shrink-0"></div>
                <span className="text-slate-700">{feature}</span>
              </li>
            ))}
          </ul>
        </div>

        <div>
          <h3 className="font-medium text-slate-900 mb-2 flex items-center gap-2">
            <Workflow size={16} />
            Workflows to Deploy
          </h3>
          <div className="space-y-1">
            {pack.workflows.map((workflow, index) => (
              <div key={index} className="text-sm text-slate-600 font-mono bg-slate-50 px-2 py-1 rounded">
                {workflow}
              </div>
            ))}
          </div>
        </div>

        <div className="border-t pt-4">
          <Button onClick={handleProceed} className="w-full">
            Proceed to Deployment
            <ArrowRight size={16} className="ml-2" />
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}