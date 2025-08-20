import React, { useState, useEffect } from 'react';
import { DashboardHeader } from './DashboardHeader';
import { AppSidebar } from './AppSidebar';

interface SidebarLayoutProps {
  children: React.ReactNode;
  appName?: string;
  appDescription?: string;
}

export function SidebarLayout({ 
  children,
  appName = 'TD Value Accelerator',
  appDescription = 'Deploy Starter Packs'
}: SidebarLayoutProps) {
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);
  const [isMobile, setIsMobile] = useState(false);

  useEffect(() => {
    const checkMobile = () => {
      const mobile = window.innerWidth < 768;
      setIsMobile(mobile);
      // Auto-collapse on mobile
      if (mobile) {
        setSidebarCollapsed(true);
      }
    };
    
    checkMobile();
    window.addEventListener('resize', checkMobile);
    return () => window.removeEventListener('resize', checkMobile);
  }, []);

  const handleToggleSidebar = () => {
    setSidebarCollapsed(!sidebarCollapsed);
  };

  const handleOverlayClick = () => {
    if (isMobile) {
      setSidebarCollapsed(true);
    }
  };

  return (
    <div className="h-full bg-gray-50 flex flex-col">
      {/* Header with sidebar toggle */}
      <DashboardHeader 
        onToggleSidebar={handleToggleSidebar}
        appName={appName}
        appDescription={appDescription}
      />
      
      {/* Main content area */}
      <div className="flex flex-1 min-h-0">
        {/* Mobile Sidebar Overlay */}
        {isMobile && !sidebarCollapsed && (
          <div 
            className="fixed inset-0 bg-black/50 z-40"
            onClick={handleOverlayClick}
          />
        )}
        
        {/* Sidebar */}
        <div className={`
          transition-all duration-300 ease-in-out
          ${isMobile ? 
            `fixed left-0 top-0 h-full z-50 transform ${sidebarCollapsed ? '-translate-x-full' : 'translate-x-0'}` :
            `${sidebarCollapsed ? 'w-0 -ml-4' : 'w-80'} flex-shrink-0`
          }
          overflow-hidden
        `}>
          <div className={`${isMobile ? 'w-80' : 'w-80'} h-full border-r border-slate-200 bg-white`}>
            <AppSidebar />
          </div>
        </div>
        
        {/* Main content */}
        <div className="flex-1 overflow-auto scrollbar-thin">
          <div className="p-6">
            {children}
          </div>
        </div>
      </div>
    </div>
  );
}