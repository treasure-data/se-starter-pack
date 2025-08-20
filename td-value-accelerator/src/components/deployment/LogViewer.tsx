import { useEffect, useRef } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/lib/ui-components/ui/card';
import { Terminal } from 'lucide-react';

interface LogViewerProps {
  logs: string[];
}

export function LogViewer({ logs }: LogViewerProps) {
  const logEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    logEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [logs]);

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Terminal size={20} className="text-slate-600" />
          Deployment Logs
        </CardTitle>
        <CardDescription>
          Real-time logs from the deployment process
        </CardDescription>
      </CardHeader>
      <CardContent>
        <div className="bg-slate-900 rounded-lg p-4 h-64 overflow-y-auto font-mono text-sm">
          {logs.length === 0 ? (
            <div className="text-slate-400">Waiting for logs...</div>
          ) : (
            <div className="space-y-1">
              {logs.map((log, index) => (
                <div key={index} className="text-green-400">
                  <span className="text-slate-500">
                    [{new Date().toLocaleTimeString()}]
                  </span>{' '}
                  {log}
                </div>
              ))}
              <div ref={logEndRef} />
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
}