import { Database, Settings, Package, Upload, CheckCircle, HelpCircle, FileInput } from 'lucide-react';
import { cn } from '@/lib/ui-components/lib/utils';
import { useLocation, Link } from 'react-router-dom';
import { useState, useEffect } from 'react';
import { useCredentials } from '@/contexts/CredentialsContext';

interface NavItem {
  icon: React.ReactNode;
  label: string;
  path: string;
  completed?: boolean;
  badge?: string;
}

interface AppSidebarProps {
  className?: string;
}

export function AppSidebar({ className }: AppSidebarProps) {
  const location = useLocation();
  const { isConnected } = useCredentials();
  const [isMobile, setIsMobile] = useState(false);

  useEffect(() => {
    const checkMobile = () => {
      setIsMobile(window.innerWidth < 768);
    };
    
    checkMobile();
    window.addEventListener('resize', checkMobile);
    return () => window.removeEventListener('resize', checkMobile);
  }, []);

  const navItems: NavItem[] = [
    { 
      icon: <Settings size={16} />, 
      label: 'Configuration', 
      path: '/configuration',
      badge: '1',
      completed: isConnected
    },
    { 
      icon: <Package size={16} />, 
      label: 'Select Pack', 
      path: '/selection',
      badge: '2'
    },
    { 
      icon: <Upload size={16} />, 
      label: 'Deploy', 
      path: '/deployment',
      badge: '3'
    },
    { 
      icon: <FileInput size={16} />, 
      label: 'Ingestion', 
      path: '/ingestion',
      badge: '4'
    },
  ];

  const isActive = (path: string) => {
    return location.pathname === path;
  };

  return (
    <div className={cn("flex flex-col h-full bg-white border-r border-slate-200", className)}>
      {/* App header with icon and description */}
      <div className={`border-b border-slate-200 ${isMobile ? 'p-3' : 'p-4'}`}>
        <div className="flex items-center gap-3">
          <div className={`${isMobile ? 'w-10 h-10' : 'w-8 h-8'} bg-gradient-to-br from-blue-500 to-purple-600 rounded-lg flex items-center justify-center shadow-sm`}>
            <Database className={`${isMobile ? 'w-5 h-5' : 'w-4 h-4'} text-white`} />
          </div>
          <div>
            <h2 className={`font-semibold text-slate-900 ${isMobile ? 'text-lg' : 'text-sm'}`}>TD Value Accelerator</h2>
            <p className={`text-xs text-slate-500 ${isMobile ? 'text-sm' : ''}`}>Deploy Starter Packs</p>
          </div>
        </div>
      </div>
      
      {/* Navigation sections */}
      <div className={`flex-1 overflow-y-auto ${isMobile ? 'p-3' : 'p-2'}`}>
        <div className={`space-y-1 ${isMobile ? 'space-y-3' : ''}`}>
          <div className="px-2 py-1.5">
            <h3 className="text-xs font-medium text-slate-500 uppercase tracking-wider">
              Deployment Steps
            </h3>
          </div>
          
          {navItems.map((item) => {
            const active = isActive(item.path);
            return (
              <Link
                key={item.path}
                to={item.path}
                className={cn(
                  "flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors group",
                  active
                    ? "bg-blue-50 text-blue-700 border border-blue-200 shadow-sm"
                    : "text-slate-600 hover:bg-slate-50 hover:text-slate-900"
                )}
              >
                <div className="flex items-center gap-3 flex-1">
                  {item.badge && (
                    <div className={cn(
                      "w-6 h-6 rounded-full flex items-center justify-center text-xs font-semibold",
                      active 
                        ? "bg-blue-100 text-blue-700"
                        : "bg-slate-100 text-slate-500 group-hover:bg-slate-200"
                    )}>
                      {item.badge}
                    </div>
                  )}
                  <span className={cn(
                    "flex items-center justify-center",
                    active ? "text-blue-600" : "text-slate-400 group-hover:text-slate-600"
                  )}>
                    {item.icon}
                  </span>
                  <span className="flex-1">{item.label}</span>
                </div>
                {item.completed && (
                  <CheckCircle size={16} className="text-green-500 flex-shrink-0" />
                )}
              </Link>
            );
          })}
        </div>
      </div>

      {/* Footer actions */}
      <div className="border-t border-slate-200 p-3">
        <Link
          to="/help"
          className="flex items-center gap-3 px-3 py-2 rounded-lg text-sm text-slate-600 hover:bg-slate-50 hover:text-slate-900 transition-colors"
        >
          <HelpCircle size={16} className="text-slate-400" />
          <span>Help & Support</span>
        </Link>
        
        <div className="mt-3 px-3 py-2 bg-slate-50 rounded-lg">
          <div className="text-xs text-slate-500">
            <p className="font-medium text-slate-700">Treasure Data</p>
            <p>Value Accelerator v1.0</p>
          </div>
        </div>
      </div>
    </div>
  );
}