import React, { useEffect, useMemo, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useCalculatorStore } from '../store/calculatorStore';
import { useUiStore } from '../../../store/uiStore';
import { Button } from '../../../components/ui/Button';
import { ResultCard } from './ResultCard';
import { MapPin, Calendar, Sunset, Sunrise, Globe, Settings, ChevronDown, Info, Watch, Share2 } from 'lucide-react';
import { Turnstile, type TurnstileInstance } from '@marsidev/react-turnstile';
import { TIMEZONE_OPTIONS } from '../../../constants/timezones';
import iconUrl from "../../../assets/icon.svg";
import { IconButton } from '../../../components/ui/IconButton';
import { SkylineChart } from './SkylineChart';

const TURNSTILE_SITE_KEY = import.meta.env.VITE_TURNSTILE_SITE_KEY || '1x00000000000000000000AA';

export const CalculatorPanel: React.FC = () => {
  const { t, i18n } = useTranslation();
  const { setSmartwatchOpen, setAboutOpen, setSettingsOpen, setShareOpen } = useUiStore();
  
  const { 
    position, targetDate, setTargetDate, calculate, 
    isLoading, sunsetTime, sunriseTime, error, isPolar, 
    setTurnstileToken, turnstileToken,
    timezone, setTimezone, azimuthProfiles, sunPath
  } = useCalculatorStore();

  const turnstileRef = useRef<TurnstileInstance>(null);

  const handleCalculate = async () => {
    await calculate();
    turnstileRef.current?.reset();
    setTurnstileToken(null);
  };

  useEffect(() => {
    const urlParams = new URLSearchParams(window.location.search);
    if (turnstileToken && urlParams.has('lat') && urlParams.has('lon') && !sunsetTime && !isLoading) {
      calculate();
    }
  }, [turnstileToken]);

  const displayTimezones = useMemo(() => {
    const isTzInList = TIMEZONE_OPTIONS.some(tz => tz.value === timezone);
    const translatedList = TIMEZONE_OPTIONS.map(tz => ({ 
      value: tz.value, 
      label: t(tz.labelKey) 
    }));
    
    if (isTzInList) return translatedList;

    let localLabel = t('local_time', { tz: timezone });
    try {
      const formatter = new Intl.DateTimeFormat(i18n.language, { timeZone: timezone, timeZoneName: 'long' });
      const tzName = formatter.formatToParts(new Date()).find(p => p.type === 'timeZoneName')?.value;
      if (tzName) localLabel = t('local_standard_time', { tzName });
    } catch (e) {}

    return [{ value: timezone, label: localLabel }, ...translatedList];
  }, [timezone, t, i18n.language]);

  const [isMobile, setIsMobile] = useState(typeof window !== 'undefined' ? window.innerWidth < 768 : true);
  const [isMinimized, setIsMinimized] = useState(false);
  const [dragY, setDragY] = useState(0);
  const touchStartRef = useRef<{ y: number; isMinimized: boolean } | null>(null);

  useEffect(() => {
    const handleResize = () => setIsMobile(window.innerWidth < 768);
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  const handleTouchStart = (e: React.TouchEvent) => {
    if (!isMobile) return;
    touchStartRef.current = { y: e.touches[0].clientY, isMinimized };
  };

  const handleTouchMove = (e: React.TouchEvent) => {
    if (!touchStartRef.current) return;
    const deltaY = e.touches[0].clientY - touchStartRef.current.y;
    
    if (!touchStartRef.current.isMinimized && deltaY > 0) {
      setDragY(deltaY);
    } else if (touchStartRef.current.isMinimized && deltaY < 0) {
      setDragY(deltaY);
    }
  };

  const handleTouchEnd = () => {
    if (!touchStartRef.current) return;
    
    if (!isMinimized && dragY > 50) {
      setIsMinimized(true);
    } else if (isMinimized && dragY < -50) {
      setIsMinimized(false);
    }
    
    setDragY(0);
    touchStartRef.current = null;
  };

  const currentTranslateY = isMinimized 
    ? `calc(100% - 120px + ${dragY}px)`
    : `${dragY}px`;


  return (
    <div 
      className={`absolute z-50 flex flex-col bg-slate-900/95 backdrop-blur-md shadow-2xl border border-slate-700/50 overflow-hidden 
        bottom-0 left-0 w-full max-h-[65vh] rounded-t-3xl border-b-0
        md:top-4 md:bottom-auto md:left-4 md:w-96 md:max-h-[calc(100vh-2rem)] md:rounded-2xl md:border-b
        ${touchStartRef.current === null ? 'transition-transform duration-300' : ''}
      `}
      style={{
        transform: isMobile ? `translateY(${currentTranslateY})` : 'none'
      }}
    >
      
      <div className="shrink-0 bg-gradient-to-r from-orange-600 to-purple-700 p-5 md:p-6 flex items-center justify-between relative">
        
        <div 
          className="absolute inset-0 md:hidden touch-none z-0" 
          onTouchStart={handleTouchStart}
          onTouchMove={handleTouchMove}
          onTouchEnd={handleTouchEnd}
          onClick={() => {
            if (isMinimized) setIsMinimized(false);
          }}
        />
        <div className="absolute top-2 left-1/2 -translate-x-1/2 w-12 h-1.5 bg-white/30 rounded-full md:hidden pointer-events-none z-10" />

        <div className="flex items-center gap-3 relative z-20 pointer-events-none">
          <img 
            src={iconUrl} 
            alt="YAMAKAGE Logo" 
            className="w-20 h-20 rounded-full shadow-lg shadow-orange-500/20 object-cover relative z-10" 
          />
          <div>
            <h1 className="text-lg md:text-xl font-bold text-white tracking-wider">{t('app_title')}</h1>
            <p className="text-orange-100 text-[10px] md:text-xs mt-0.5">{t('app_subtitle')}</p>
          </div>
        </div>

        <div className="grid grid-cols-2 gap-1.5 md:gap-2 relative z-20">
          <IconButton 
            Icon={Watch} 
            onClick={() => setSmartwatchOpen(true)} 
            ariaLabel={t('smartwatch.menu_title')} 
          />
          <IconButton 
            Icon={Share2}
            onClick={() => setShareOpen(true)} 
            ariaLabel={t('share.menu_title')} 
          />
          <IconButton
            Icon={Info}
            onClick={()=>setAboutOpen(true)}
            ariaLabel={t('about.menu_title')}
          />
          <IconButton
            Icon={Settings}
            onClick={()=>setSettingsOpen(true)}
            ariaLabel={t('settings')}
          />
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-5 md:p-6 space-y-5 md:space-y-6">
        
        <div className="space-y-2">
          <label className="text-sm text-slate-400 font-medium flex items-center gap-2">
            <MapPin className="w-4 h-4" /> {t('selected_location')}
          </label>
          <div className="bg-slate-800 rounded-lg p-3 text-slate-200 text-sm font-mono border border-slate-700">
            {position 
              ? t('position_format', { lat: position?.lat.toFixed(4), lon: position?.lng.toFixed(4) })
              : t('click_to_select')
            }
          </div>
          <p className="text-xs text-slate-500">{t('can_change_location')}</p>
        </div>

        <div className="space-y-2">
          <label className="text-sm text-slate-400 font-medium flex items-center gap-2">
            <Globe className="w-4 h-4" /> {t('timezone')}
          </label>
          <div className="relative">
            <select
              value={timezone}
              onChange={(e) => setTimezone(e.target.value)}
              className="w-full bg-slate-800 text-white rounded-lg p-3 pr-10 border border-slate-700 focus:outline-none focus:border-orange-500 transition-colors appearance-none cursor-pointer truncate"
            >
              {displayTimezones.map((tz) => (
                <option key={tz.value} value={tz.value}>
                  {tz.label}
                </option>
              ))}
            </select>
            <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400 pointer-events-none" />
          </div>
        </div>

        <div className="space-y-2">
          <label className="text-sm text-slate-400 font-medium flex items-center gap-2">
            <Calendar className="w-4 h-4" /> {t('target_date')}
          </label>
          <input
            type="datetime-local"
            value={targetDate}
            onChange={(e) => setTargetDate(e.target.value)}
            className="w-full bg-slate-800 text-white rounded-lg p-3 border border-slate-700 focus:outline-none focus:border-orange-500 transition-colors"
          />
        </div>

        <div className="flex justify-center my-2">
          <Turnstile
            ref={turnstileRef}
            siteKey={TURNSTILE_SITE_KEY}
            onSuccess={(token) => setTurnstileToken(token)}
            onError={() => setTurnstileToken(null)}
            onExpire={() => setTurnstileToken(null)}
            options={{ theme: 'dark' }}
          />
        </div>

        <Button onClick={handleCalculate} isLoading={isLoading} disabled={!position || !turnstileToken}>
          {t('calculate_button')}
        </Button>

        {error && <p className="text-red-400 text-sm text-center">{t(error)}</p>}
        {isPolar && <p className="text-blue-400 text-sm text-center font-bold">{t('polar_alert')}</p>}

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

        {azimuthProfiles.length > 0 && (
          <SkylineChart 
            azimuthProfiles={azimuthProfiles} 
            sunPath={sunPath}
          />
        )}
      </div>
    </div>
  );
};