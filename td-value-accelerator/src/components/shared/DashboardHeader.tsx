import { Bell, Search, User, PanelLeft, Menu } from "lucide-react";
import { Button } from "@/lib/ui-components/ui/button";
import { Input } from "@/lib/ui-components/ui/input";
import { Separator } from "@/lib/ui-components/ui/separator";
import { useState, useEffect } from "react";

interface DashboardHeaderProps {
  onToggleSidebar: () => void;
  appName?: string;
  appDescription?: string;
}

export function DashboardHeader({
  onToggleSidebar,
  appName = 'TD Value Accelerator',
  appDescription = 'Deploy Starter Packs',
}: DashboardHeaderProps) {
  // Mobile detection
  const [isMobile, setIsMobile] = useState(false);
  
  useEffect(() => {
    const checkMobile = () => {
      setIsMobile(window.innerWidth < 768);
    };
    
    checkMobile();
    window.addEventListener('resize', checkMobile);
    return () => window.removeEventListener('resize', checkMobile);
  }, []);

  return (
    <header className={`flex ${isMobile ? 'h-14' : 'h-16'} shrink-0 items-center gap-2 bg-white border-b border-slate-200`}>
      <div className={`flex items-center gap-2 ${isMobile ? 'px-2' : 'px-4'}`}>
        <Button
          variant="ghost"
          size="icon"
          className={`${isMobile ? 'h-8 w-8' : 'h-7 w-7'} -ml-1`}
          onClick={onToggleSidebar}
        >
          {isMobile ? <Menu className="h-5 w-5" /> : <PanelLeft className="h-4 w-4" />}
          <span className="sr-only">Toggle Sidebar</span>
        </Button>
        {!isMobile && <Separator orientation="vertical" className="mr-2 h-4" />}
        <div className={isMobile ? 'ml-2' : ''}>
          <h1 className={`${isMobile ? 'text-lg' : 'text-xl'} font-semibold text-slate-900`}>
            {appName}
          </h1>
          {!isMobile && appDescription && (
            <p className="text-sm text-slate-500">
              {appDescription}
            </p>
          )}
        </div>
      </div>

      <div className={`ml-auto flex items-center ${isMobile ? 'gap-2 px-2' : 'gap-4 px-4'}`}>
        {!isMobile && (
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400 w-4 h-4" />
            <Input
              placeholder="Search..."
              className="pl-10 w-64 bg-slate-50 border-slate-200 focus:bg-white"
            />
          </div>
        )}
        
        {isMobile && (
          <Button variant="ghost" size="icon" className="hover:bg-slate-100">
            <Search className="w-4 h-4" />
          </Button>
        )}

        <Button variant="ghost" size="icon" className="hover:bg-slate-100">
          <Bell className="w-4 h-4" />
        </Button>

        <Button variant="ghost" size="icon" className="hover:bg-slate-100">
          <User className="w-4 h-4" />
        </Button>
      </div>
    </header>
  );
}