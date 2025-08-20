import { useEffect, useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/lib/ui-components/ui/card';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { LogViewer } from './LogViewer';
import type { DeploymentStatus } from '@/types/deployment';
import { CheckCircle, XCircle, Clock } from 'lucide-react';
import { cn } from '@/lib/ui-components/lib/utils';

interface DeploymentProgressProps {
  deploymentStatus: DeploymentStatus;
  onComplete: () => void;
}

export function DeploymentProgress({ deploymentStatus, onComplete }: DeploymentProgressProps) {
  const [currentStatus, setCurrentStatus] = useState(deploymentStatus);
  const [logs, setLogs] = useState<string[]>([]);

  useEffect(() => {
    if (currentStatus.status === 'completed') {
      onComplete();
      return;
    }

    const ws = new WebSocket(`ws://localhost:8000/api/deployment/logs/${currentStatus.id}`);
    
    ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      
      if (data.type === 'status') {
        setCurrentStatus(data.status);
      } else if (data.type === 'log') {
        setLogs(prev => [...prev, data.message]);
      }
    };

    return () => ws.close();
  }, [currentStatus.id, onComplete]);

  const getStatusIcon = () => {
    switch (currentStatus.status) {
      case 'running':
        return <LoadingSpinner size="sm" />;
      case 'completed':
        return <CheckCircle size={20} className="text-green-600" />;
      case 'failed':
        return <XCircle size={20} className="text-red-600" />;
      default:
        return <Clock size={20} className="text-slate-400" />;
    }
  };

  const getStatusColor = () => {
    switch (currentStatus.status) {
      case 'running':
        return 'text-blue-700';
      case 'completed':
        return 'text-green-700';
      case 'failed':
        return 'text-red-700';
      default:
        return 'text-slate-700';
    }
  };

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            {getStatusIcon()}
            Deployment Progress
          </CardTitle>
          <CardDescription>
            <span className={cn("font-medium", getStatusColor())}>
              Status: {currentStatus.status.charAt(0).toUpperCase() + currentStatus.status.slice(1)}
            </span>
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <div>
              <div className="flex justify-between text-sm mb-1">
                <span>Progress</span>
                <span>{currentStatus.progress}%</span>
              </div>
              <div className="w-full bg-slate-200 rounded-full h-2">
                <div 
                  className={cn(
                    "h-2 rounded-full transition-all duration-300",
                    currentStatus.status === 'failed' ? 'bg-red-500' : 'bg-blue-500'
                  )}
                  style={{ width: `${currentStatus.progress}%` }}
                ></div>
              </div>
            </div>

            {currentStatus.error && (
              <div className="p-3 bg-red-50 border border-red-200 rounded-lg">
                <h4 className="font-medium text-red-800 mb-1">Error</h4>
                <p className="text-red-700 text-sm">{currentStatus.error}</p>
              </div>
            )}

            <div className="grid grid-cols-2 gap-4 text-sm">
              <div>
                <span className="text-slate-600">Started:</span>
                <span className="ml-2 font-mono">
                  {new Date(currentStatus.startTime).toLocaleString()}
                </span>
              </div>
              {currentStatus.endTime && (
                <div>
                  <span className="text-slate-600">Completed:</span>
                  <span className="ml-2 font-mono">
                    {new Date(currentStatus.endTime).toLocaleString()}
                  </span>
                </div>
              )}
            </div>
          </div>
        </CardContent>
      </Card>

      <LogViewer logs={logs} />
    </div>
  );
}