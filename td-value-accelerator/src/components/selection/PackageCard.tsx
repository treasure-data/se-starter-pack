import type { StarterPack } from '@/types/deployment';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/lib/ui-components/ui/card';
import { Button } from '@/lib/ui-components/ui/button';
import { CheckCircle, Package } from 'lucide-react';
import { cn } from '@/lib/ui-components/lib/utils';

interface PackageCardProps {
  pack: StarterPack;
  isSelected: boolean;
  onSelect: () => void;
}

export function PackageCard({ pack, isSelected, onSelect }: PackageCardProps) {
  return (
    <Card 
      className={cn(
        "cursor-pointer transition-all duration-200 hover:shadow-md",
        isSelected ? "ring-2 ring-blue-500 bg-blue-50/50" : "hover:bg-slate-50"
      )}
      onClick={onSelect}
    >
      <CardHeader>
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className={cn(
              "w-10 h-10 rounded-lg flex items-center justify-center",
              pack.type === 'QSR' 
                ? "bg-orange-100 text-orange-600" 
                : "bg-purple-100 text-purple-600"
            )}>
              <Package size={20} />
            </div>
            <div>
              <CardTitle className="text-lg">{pack.name}</CardTitle>
              <div className={cn(
                "text-xs px-2 py-1 rounded-full font-medium inline-block",
                pack.type === 'QSR' 
                  ? "bg-orange-100 text-orange-700" 
                  : "bg-purple-100 text-purple-700"
              )}>
                {pack.type}
              </div>
            </div>
          </div>
          {isSelected && <CheckCircle size={20} className="text-blue-600" />}
        </div>
      </CardHeader>
      <CardContent>
        <CardDescription className="mb-4">
          {pack.description}
        </CardDescription>
        <div className="space-y-2">
          <h4 className="text-sm font-medium text-slate-900">Key Features:</h4>
          <ul className="text-sm text-slate-600 space-y-1">
            {pack.features.slice(0, 3).map((feature, index) => (
              <li key={index} className="flex items-center gap-2">
                <div className="w-1.5 h-1.5 bg-slate-400 rounded-full"></div>
                {feature}
              </li>
            ))}
            {pack.features.length > 3 && (
              <li className="text-xs text-slate-500">
                +{pack.features.length - 3} more features
              </li>
            )}
          </ul>
        </div>
        <Button 
          className="w-full mt-4" 
          variant={isSelected ? "default" : "outline"}
          onClick={(e) => {
            e.stopPropagation();
            onSelect();
          }}
        >
          {isSelected ? 'Selected' : 'Select Package'}
        </Button>
      </CardContent>
    </Card>
  );
}