import React, { useEffect, useState } from 'react';
import { Loader2 } from 'lucide-react';
import iconUrl from '../../assets/icon.svg';

interface LoadingScreenProps {
  isReady: boolean;
}

export const LoadingScreen: React.FC<LoadingScreenProps> = ({ isReady }) => {
  const [shouldRender, setShouldRender] = useState(true);

  useEffect(() => {
    if (isReady) {
      const timer = setTimeout(() => setShouldRender(false), 500);
      return () => clearTimeout(timer);
    }
  }, [isReady]);

  if (!shouldRender) return null;

  return (
    <div
      className={`fixed inset-0 z-[9999] flex flex-col items-center justify-center bg-slate-900 transition-opacity duration-500 ease-in-out ${
        isReady ? 'opacity-0 pointer-events-none' : 'opacity-100'
      }`}
    >
      <div className="flex flex-col items-center gap-6">
        <div className="relative flex items-center justify-center">
          <Loader2 className="absolute w-28 h-28 text-orange-500 animate-spin opacity-80" />
          
          <img 
            src={iconUrl} 
            alt="YAMAKAGE Logo" 
            className="w-20 h-20 rounded-full shadow-lg shadow-orange-500/20 object-cover relative z-10" 
          />
        </div>
        
        <div className="flex flex-col items-center gap-2">
          <h1 className="text-2xl font-bold text-white tracking-widest">YAMAKAGE</h1>
          <p className="text-sm text-slate-400 animate-pulse">Loading Map...</p>
        </div>
      </div>
    </div>
  );
};