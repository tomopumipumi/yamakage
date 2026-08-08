import React from 'react';
import { useTranslation } from 'react-i18next';
import { Sunrise, Sunset } from 'lucide-react';
import { useCalculatorStore } from '../store/calculatorStore';
import { ResultCard } from './ResultCard';
import { SkylineChart } from './SkylineChart';

export const CalculatorResults: React.FC = () => {
  const { t } = useTranslation();
  const { 
    error, isPolar, sunriseTime, sunsetTime, 
    timezone, azimuthProfiles, sunPath 
  } = useCalculatorStore();

  if (!sunriseTime && !sunsetTime && !isPolar && !error && azimuthProfiles.length === 0) {
    return null;
  }

  return (
    <>
      {error && <p className="text-red-400 text-sm text-center">{t(error)}</p>}
      {isPolar && <p className="text-blue-400 text-sm text-center font-bold">{t('polar_alert')}</p>}

      {(sunriseTime || sunsetTime) && (
        <div className="space-y-3 pt-4 border-t border-slate-700/50">
          <ResultCard 
            icon={<Sunrise className="w-5 h-5 text-yellow-500" />} 
            label={t('sunrise_label')} 
            timestamp={sunriseTime} 
            color="text-yellow-500"
            timezone={timezone}
          />
          <ResultCard 
            icon={<Sunset className="w-5 h-5 text-purple-400" />} 
            label={t('sunset_label')} 
            timestamp={sunsetTime} 
            color="text-purple-400"
            timezone={timezone}
          />
        </div>
      )}

      {azimuthProfiles.length > 0 && (
        <SkylineChart 
          azimuthProfiles={azimuthProfiles} 
          sunPath={sunPath}
        />
      )}
    </>
  );
};