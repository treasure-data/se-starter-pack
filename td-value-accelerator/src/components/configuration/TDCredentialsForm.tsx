import type { TDCredentials } from '@/types/deployment';
import { Input } from '@/lib/ui-components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/lib/ui-components/ui/select';
import { Eye, EyeOff, Key, Globe } from 'lucide-react';
import { useState } from 'react';

interface TDCredentialsFormProps {
  credentials: TDCredentials;
  onChange: (credentials: TDCredentials) => void;
}

export function TDCredentialsForm({ credentials, onChange }: TDCredentialsFormProps) {
  const [showApiKey, setShowApiKey] = useState(false);
  const [showEnvironmentTokens, setShowEnvironmentTokens] = useState({
    prod: false,
    qa: false,
    dev: false,
  });

  const handleChange = (field: keyof TDCredentials, value: string) => {
    onChange({
      ...credentials,
      [field]: value
    });
  };

  const handleEnvironmentTokenChange = (env: 'prod' | 'qa' | 'dev', value: string) => {
    onChange({
      ...credentials,
      environmentTokens: {
        ...credentials.environmentTokens,
        [env]: value
      }
    });
  };

  return (
    <div className="space-y-6">
      {/* API Key Field */}
      <div>
        <label htmlFor="apiKey" className="block text-sm font-medium text-slate-700 mb-2">
          <div className="flex items-center gap-2">
            <Key className="w-4 h-4 text-slate-500" />
            API Key
          </div>
        </label>
        <div className="relative">
          <Input
            id="apiKey"
            type={showApiKey ? "text" : "password"}
            placeholder="Enter your TD API key"
            value={credentials.apiKey}
            onChange={(e) => handleChange('apiKey', e.target.value)}
            className="pr-10"
          />
          <button
            type="button"
            className="absolute inset-y-0 right-0 pr-3 flex items-center"
            onClick={() => setShowApiKey(!showApiKey)}
          >
            {showApiKey ? (
              <EyeOff className="h-4 w-4 text-slate-400 hover:text-slate-600" />
            ) : (
              <Eye className="h-4 w-4 text-slate-400 hover:text-slate-600" />
            )}
          </button>
        </div>
        <p className="text-xs text-slate-500 mt-1 flex items-center gap-1">
          <span className="w-1 h-1 bg-slate-400 rounded-full"></span>
          Your Treasure Data API key (keep this secure)
        </p>
      </div>

      {/* Region Field */}
      <div>
        <label htmlFor="region" className="block text-sm font-medium text-slate-700 mb-2">
          <div className="flex items-center gap-2">
            <Globe className="w-4 h-4 text-slate-500" />
            Region
          </div>
        </label>
        <Select 
          value={credentials.region} 
          onValueChange={(value: 'us01' | 'eu01') => handleChange('region', value)}
        >
          <SelectTrigger id="region">
            <SelectValue placeholder="Select a region" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="us01">
              <div className="flex items-center gap-2">
                <span>🇺🇸</span>
                <span>US (us01)</span>
              </div>
            </SelectItem>
            <SelectItem value="eu01">
              <div className="flex items-center gap-2">
                <span>🇪🇺</span>
                <span>EU (eu01)</span>
              </div>
            </SelectItem>
          </SelectContent>
        </Select>
        <p className="text-xs text-slate-500 mt-1 flex items-center gap-1">
          <span className="w-1 h-1 bg-slate-400 rounded-full"></span>
          Select your Treasure Data region
        </p>
      </div>

      {/* Environment API Tokens */}
      <div className="border-t pt-6">
        <h3 className="text-lg font-medium text-slate-900 mb-2 flex items-center gap-2">
          <Key className="w-5 h-5 text-blue-600" />
          Environment API Tokens
        </h3>
        <p className="text-sm text-slate-600 mb-4">
          Configure TD API tokens for different environments. At least one environment is required for deployments.
        </p>
        
        <div className="space-y-4">
          {/* Production Environment */}
          <div>
            <label htmlFor="prodToken" className="block text-sm font-medium text-slate-700 mb-2">
              <div className="flex items-center gap-2">
                <Key className="w-4 h-4" />
                Production TD API Token
              </div>
            </label>
            <div className="relative">
              <Input
                id="prodToken"
                type={showEnvironmentTokens.prod ? "text" : "password"}
                placeholder="TD API token for production environment"
                value={credentials.environmentTokens?.prod || ''}
                onChange={(e) => handleEnvironmentTokenChange('prod', e.target.value)}
                className="pr-10"
              />
              <button
                type="button"
                className="absolute inset-y-0 right-0 pr-3 flex items-center"
                onClick={() => setShowEnvironmentTokens(prev => ({ ...prev, prod: !prev.prod }))}
              >
                {showEnvironmentTokens.prod ? (
                  <EyeOff className="h-4 w-4 text-slate-400" />
                ) : (
                  <Eye className="h-4 w-4 text-slate-400" />
                )}
              </button>
            </div>
          </div>

          {/* QA Environment */}
          <div>
            <label htmlFor="qaToken" className="block text-sm font-medium text-slate-700 mb-2">
              <div className="flex items-center gap-2">
                <Key className="w-4 h-4" />
                QA TD API Token (Optional)
              </div>
            </label>
            <div className="relative">
              <Input
                id="qaToken"
                type={showEnvironmentTokens.qa ? "text" : "password"}
                placeholder="TD API token for QA environment"
                value={credentials.environmentTokens?.qa || ''}
                onChange={(e) => handleEnvironmentTokenChange('qa', e.target.value)}
                className="pr-10"
              />
              <button
                type="button"
                className="absolute inset-y-0 right-0 pr-3 flex items-center"
                onClick={() => setShowEnvironmentTokens(prev => ({ ...prev, qa: !prev.qa }))}
              >
                {showEnvironmentTokens.qa ? (
                  <EyeOff className="h-4 w-4 text-slate-400" />
                ) : (
                  <Eye className="h-4 w-4 text-slate-400" />
                )}
              </button>
            </div>
          </div>

          {/* Development Environment */}
          <div>
            <label htmlFor="devToken" className="block text-sm font-medium text-slate-700 mb-2">
              <div className="flex items-center gap-2">
                <Key className="w-4 h-4" />
                Development TD API Token (Optional)
              </div>
            </label>
            <div className="relative">
              <Input
                id="devToken"
                type={showEnvironmentTokens.dev ? "text" : "password"}
                placeholder="TD API token for development environment"
                value={credentials.environmentTokens?.dev || ''}
                onChange={(e) => handleEnvironmentTokenChange('dev', e.target.value)}
                className="pr-10"
              />
              <button
                type="button"
                className="absolute inset-y-0 right-0 pr-3 flex items-center"
                onClick={() => setShowEnvironmentTokens(prev => ({ ...prev, dev: !prev.dev }))}
              >
                {showEnvironmentTokens.dev ? (
                  <EyeOff className="h-4 w-4 text-slate-400" />
                ) : (
                  <Eye className="h-4 w-4 text-slate-400" />
                )}
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Form Validation Indicators */}
      <div className="flex items-center gap-4 pt-2">
        <div className="flex items-center gap-2">
          <div className={`w-2 h-2 rounded-full ${credentials.apiKey ? 'bg-green-500' : 'bg-slate-300'}`}></div>
          <span className="text-xs text-slate-600">API Key</span>
        </div>
        <div className="flex items-center gap-2">
          <div className={`w-2 h-2 rounded-full ${credentials.region ? 'bg-green-500' : 'bg-slate-300'}`}></div>
          <span className="text-xs text-slate-600">Region</span>
        </div>
        <div className="flex items-center gap-2">
          <div className={`w-2 h-2 rounded-full ${
            credentials.environmentTokens?.prod || credentials.environmentTokens?.qa || credentials.environmentTokens?.dev 
              ? 'bg-green-500' 
              : 'bg-slate-300'
          }`}></div>
          <span className="text-xs text-slate-600">Environment Tokens</span>
        </div>
      </div>
    </div>
  );
}