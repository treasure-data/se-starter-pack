import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/lib/ui-components/ui/card';
import { Button } from '@/lib/ui-components/ui/button';
import { TDCredentialsForm } from './TDCredentialsForm';
import { ConnectionTest } from './ConnectionTest';
import { useCredentials } from '@/contexts/CredentialsContext';
import type { TDCredentials } from '@/types/deployment';
import { Settings, Database, CheckCircle2, AlertCircle, Trash2 } from 'lucide-react';

export function ConfigurationPage() {
  const { credentials, isConnected, setCredentials, setIsConnected, clearCredentials } = useCredentials();

  // Initialize credentials if they don't exist
  const currentCredentials = credentials || {
    apiKey: '',
    region: 'us01' as const,
    environmentTokens: {}
  };

  const handleClearCredentials = () => {
    if (confirm('Are you sure you want to clear your stored credentials? You will need to re-enter them.')) {
      clearCredentials();
    }
  };

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="border-b border-slate-200 pb-5">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-purple-600 rounded-lg flex items-center justify-center">
            <Settings className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-slate-900">Configuration</h1>
            <p className="text-slate-600 mt-1">
              Configure your Treasure Data connection to get started with the Value Accelerator.
            </p>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Main Configuration Card */}
        <div className="lg:col-span-2">
          <Card className="h-fit">
            <CardHeader>
              <div className="flex items-center gap-2">
                <Database className="w-5 h-5 text-blue-600" />
                <div>
                  <CardTitle>Treasure Data Connection</CardTitle>
                  <CardDescription className="mt-1">
                    Enter your TD credentials to connect to your account.
                  </CardDescription>
                </div>
              </div>
            </CardHeader>
            <CardContent className="space-y-6">
              <TDCredentialsForm 
                credentials={currentCredentials}
                onChange={setCredentials}
              />
              <ConnectionTest 
                credentials={currentCredentials}
                onConnectionChange={setIsConnected}
              />
            </CardContent>
          </Card>
        </div>

        {/* Status Sidebar */}
        <div className="space-y-4">
          {/* Connection Status Card */}
          <Card>
            <CardHeader className="pb-3">
              <CardTitle className="text-sm">Connection Status</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-center gap-3">
                {isConnected ? (
                  <>
                    <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                    <div>
                      <p className="text-sm font-medium text-green-700">Connected</p>
                      <p className="text-xs text-green-600">Ready to proceed</p>
                    </div>
                    <CheckCircle2 className="w-4 h-4 text-green-500 ml-auto" />
                  </>
                ) : (
                  <>
                    <div className="w-2 h-2 bg-slate-300 rounded-full"></div>
                    <div>
                      <p className="text-sm font-medium text-slate-600">Not Connected</p>
                      <p className="text-xs text-slate-500">Configure credentials</p>
                    </div>
                    <AlertCircle className="w-4 h-4 text-slate-400 ml-auto" />
                  </>
                )}
              </div>
            </CardContent>
          </Card>

          {/* Progress Card */}
          <Card>
            <CardHeader className="pb-3">
              <CardTitle className="text-sm">Setup Progress</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                <div className="flex items-center gap-3">
                  <div className={`w-2 h-2 rounded-full ${isConnected ? 'bg-green-500' : 'bg-blue-500'}`}></div>
                  <span className="text-sm text-slate-700">Step 1: Configuration</span>
                  {isConnected && <CheckCircle2 className="w-4 h-4 text-green-500 ml-auto" />}
                </div>
                <div className="flex items-center gap-3">
                  <div className="w-2 h-2 rounded-full bg-slate-300"></div>
                  <span className="text-sm text-slate-500">Step 2: Select Pack</span>
                </div>
                <div className="flex items-center gap-3">
                  <div className="w-2 h-2 rounded-full bg-slate-300"></div>
                  <span className="text-sm text-slate-500">Step 3: Deploy</span>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Stored Credentials Info */}
          {credentials && (
            <Card>
              <CardHeader className="pb-3">
                <CardTitle className="text-sm">Stored Credentials</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  <div className="flex items-center gap-2 text-sm">
                    <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
                    <span className="text-slate-600">Region: {credentials.region.toUpperCase()}</span>
                  </div>
                  <div className="flex items-center gap-2 text-sm">
                    <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
                    <span className="text-slate-600">API Key: ••••••{credentials.apiKey.slice(-4)}</span>
                  </div>
                  <Button 
                    variant="outline" 
                    size="sm" 
                    onClick={handleClearCredentials}
                    className="w-full mt-3"
                  >
                    <Trash2 className="w-4 h-4 mr-2" />
                    Clear Credentials
                  </Button>
                </div>
              </CardContent>
            </Card>
          )}

          {/* Requirements Card */}
          <Card>
            <CardHeader className="pb-3">
              <CardTitle className="text-sm">Requirements</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-2 text-sm text-slate-600">
                <div className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-green-500" />
                  <span>Valid TD API Key</span>
                </div>
                <div className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-green-500" />
                  <span>Network Connectivity</span>
                </div>
                <div className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-green-500" />
                  <span>Workflow Execution Rights</span>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>

      {/* Success State */}
      {isConnected && (
        <Card className="border-green-200 bg-green-50">
          <CardContent className="pt-6">
            <div className="flex items-start gap-3">
              <CheckCircle2 className="w-5 h-5 text-green-600 mt-0.5" />
              <div>
                <h3 className="font-medium text-green-800">Successfully connected to Treasure Data</h3>
                <p className="text-green-700 text-sm mt-1">
                  Your connection has been verified. You can now proceed to select your starter pack.
                </p>
                <div className="mt-3">
                  <button 
                    onClick={() => window.location.href = '/selection'}
                    className="inline-flex items-center gap-2 px-4 py-2 bg-green-600 text-white text-sm font-medium rounded-lg hover:bg-green-700 transition-colors"
                  >
                    Continue to Pack Selection
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                    </svg>
                  </button>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}