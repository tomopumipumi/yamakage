import React, { useState, useEffect } from 'react';
import { YamakageMap } from '../features/map/components/YamakageMap';
import { CalculatorPanel } from '../features/calculator/components/CalculatorPanel';
import { LoadingScreen } from '../components/ui/LoadingScreen';
import { SettingsDialog } from '../components/ui/SettingsDialog';
import { AboutDialog } from '../components/ui/AboutDialog';
import { SmartwatchDialog } from '../components/ui/SmartwatchDialog';
import { ShareDialog } from '../components/ui/ShareDialog';

export const MainLayout: React.FC = () => {
  const [isAppReady, setIsAppReady] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => {
      setIsAppReady(true);
    }, 1000);

    return () => clearTimeout(timer);
  }, []);

  return (
    <main className="relative w-screen h-screen overflow-hidden bg-slate-900">
      <LoadingScreen isReady={isAppReady} />
      
      <SettingsDialog />
      <AboutDialog />
      <SmartwatchDialog />
      <ShareDialog />

      <div className="absolute inset-0 z-0">
        <YamakageMap />
      </div>
      
      <CalculatorPanel />
    </main>
  );
};