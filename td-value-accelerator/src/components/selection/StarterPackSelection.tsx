import { useState } from 'react';
import { PackageCard } from './PackageCard';
import { PackagePreview } from './PackagePreview';
import type { StarterPack } from '@/types/deployment';

const starterPacks: StarterPack[] = [
  {
    id: 'qsr',
    name: 'QSR Starter Pack',
    description: 'Quick Service Restaurant analytics and customer journey tracking',
    type: 'QSR',
    features: [
      'Order analytics and sales trends',
      'Customer journey mapping',
      'Marketing attribution',
      'Cohort analysis',
      'Segmentation and targeting',
      'Dashboard templates'
    ],
    workflows: [
      'wf02_mapping.dig',
      'wf03_validate.dig',
      'wf04_stage.dig',
      'wf05_unify.dig',
      'wf06_golden.dig',
      'wf07_analytics.dig',
      'wf08_create_refresh_master_segment.dig'
    ]
  },
  {
    id: 'retail',
    name: 'Retail Starter Pack',
    description: 'Comprehensive retail analytics with customer insights and product performance',
    type: 'Retail',
    features: [
      'Sales and product analytics',
      'Customer lifetime value',
      'Inventory optimization insights',
      'Cross-sell recommendations',
      'Web analytics integration',
      'Advanced segmentation'
    ],
    workflows: [
      'wf02_mapping.dig',
      'wf03_validate.dig',
      'wf04_stage.dig',
      'wf05_unify.dig',
      'wf06_golden.dig',
      'wf07_analytics.dig',
      'wf08_create_refresh_master_segment.dig'
    ]
  }
];

export function StarterPackSelection() {
  const [selectedPack, setSelectedPack] = useState<StarterPack | null>(null);

  return (
    <div className="max-w-6xl mx-auto space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-slate-900">Select Starter Pack</h1>
        <p className="text-slate-600 mt-1">
          Choose the starter pack that best fits your business needs.
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="space-y-4">
          {starterPacks.map((pack) => (
            <PackageCard
              key={pack.id}
              pack={pack}
              isSelected={selectedPack?.id === pack.id}
              onSelect={() => setSelectedPack(pack)}
            />
          ))}
        </div>

        <div className="lg:sticky lg:top-6">
          {selectedPack ? (
            <PackagePreview pack={selectedPack} />
          ) : (
            <div className="bg-slate-50 border-2 border-dashed border-slate-300 rounded-lg p-8 text-center">
              <div className="text-slate-400 mb-2">
                <svg className="w-12 h-12 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
              </div>
              <p className="text-slate-600">Select a starter pack to see details</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}