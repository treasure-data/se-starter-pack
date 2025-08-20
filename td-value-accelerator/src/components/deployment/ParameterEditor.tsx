import { Input } from '@/lib/ui-components/ui/input';
import { Button } from '@/lib/ui-components/ui/button';
import { Plus, X } from 'lucide-react';

interface ParameterEditorProps {
  parameters: any;
  onChange: (parameters: any) => void;
}

export function ParameterEditor({ parameters, onChange }: ParameterEditorProps) {
  const handleEmailChange = (index: number, value: string) => {
    const newEmails = [...parameters.email_ids];
    newEmails[index] = value;
    onChange({ ...parameters, email_ids: newEmails });
  };

  const addEmail = () => {
    onChange({ 
      ...parameters, 
      email_ids: [...parameters.email_ids, ''] 
    });
  };

  const removeEmail = (index: number) => {
    const newEmails = parameters.email_ids.filter((_: any, i: number) => i !== index);
    onChange({ ...parameters, email_ids: newEmails });
  };

  return (
    <div className="space-y-4">
      <div>
        <label className="block text-sm font-medium text-slate-700 mb-2">
          Notification Emails
        </label>
        <div className="space-y-2">
          {parameters.email_ids.map((email: string, index: number) => (
            <div key={index} className="flex gap-2">
              <Input
                type="email"
                value={email}
                onChange={(e) => handleEmailChange(index, e.target.value)}
                placeholder="admin@company.com"
                className="flex-1"
              />
              {parameters.email_ids.length > 1 && (
                <Button
                  type="button"
                  variant="outline"
                  size="icon"
                  onClick={() => removeEmail(index)}
                >
                  <X size={16} />
                </Button>
              )}
            </div>
          ))}
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={addEmail}
            className="w-full"
          >
            <Plus size={16} className="mr-2" />
            Add Email
          </Button>
        </div>
        <p className="text-xs text-slate-500 mt-1">
          Emails to notify about deployment status and workflow results
        </p>
      </div>

      <div>
        <label className="block text-sm font-medium text-slate-700 mb-1">
          Environment
        </label>
        <select
          className="flex h-9 w-full rounded-md border border-input bg-background px-3 py-1 text-sm shadow-sm"
          value={parameters.environment}
          onChange={(e) => onChange({ ...parameters, environment: e.target.value })}
        >
          <option value="development">Development</option>
          <option value="staging">Staging</option>
          <option value="production">Production</option>
        </select>
      </div>
    </div>
  );
}