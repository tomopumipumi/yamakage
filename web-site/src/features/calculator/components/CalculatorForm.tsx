import { Turnstile, type TurnstileInstance } from '@marsidev/react-turnstile';
import { Calendar, ChevronDown, Globe, MapPin } from 'lucide-react';
import type React from 'react';
import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import { Button } from '../../../components/ui/Button';
import { TIMEZONE_OPTIONS } from '../../../constants/timezones';
import { useCalculatorStore } from '../store/calculatorStore';

const TURNSTILE_SITE_KEY = import.meta.env.VITE_TURNSTILE_SITE_KEY || '1x00000000000000000000AA';

interface CalculatorFormProps {
  turnstileRef: React.RefObject<TurnstileInstance | null>;
  onCalculate: () => void;
}

export const CalculatorForm: React.FC<CalculatorFormProps> = ({ turnstileRef, onCalculate }) => {
  const { t, i18n } = useTranslation();
  const {
    position,
    targetDate,
    setTargetDate,
    isLoading,
    setTurnstileToken,
    turnstileToken,
    timezone,
    setTimezone,
  } = useCalculatorStore();

  const displayTimezones = useMemo(() => {
    const isTzInList = TIMEZONE_OPTIONS.some((tz) => tz.value === timezone);
    const translatedList = TIMEZONE_OPTIONS.map((tz) => ({
      value: tz.value,
      label: t(tz.labelKey),
    }));

    if (isTzInList) return translatedList;

    let localLabel = t('local_time', { tz: timezone });
    try {
      const formatter = new Intl.DateTimeFormat(i18n.language, {
        timeZone: timezone,
        timeZoneName: 'long',
      });
      const tzName = formatter
        .formatToParts(new Date())
        .find((p) => p.type === 'timeZoneName')?.value;
      if (tzName) localLabel = t('local_standard_time', { tzName });
    } catch (_e) {}

    return [{ value: timezone, label: localLabel }, ...translatedList];
  }, [timezone, t, i18n.language]);

  return (
    <>
      <div className="space-y-2">
        <div className="text-sm text-slate-400 font-medium flex items-center gap-2">
          <MapPin className="w-4 h-4" /> {t('selected_location')}
        </div>
        <div className="bg-slate-800 rounded-lg p-3 text-slate-200 text-sm font-mono border border-slate-700">
          {position
            ? t('position_format', { lat: position.lat.toFixed(4), lon: position.lng.toFixed(4) })
            : t('click_to_select')}
        </div>
        <p className="text-xs text-slate-500">{t('can_change_location')}</p>
      </div>

      <div className="space-y-2">
        <label
          htmlFor="timezone-select"
          className="text-sm text-slate-400 font-medium flex items-center gap-2"
        >
          <Globe className="w-4 h-4" /> {t('timezone')}
        </label>
        <div className="relative">
          <select
            id="timezone-select"
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
        <label
          htmlFor="target-date-input"
          className="text-sm text-slate-400 font-medium flex items-center gap-2"
        >
          <Calendar className="w-4 h-4" /> {t('target_datetime')}
        </label>
        <input
          id="target-date-input"
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

      <Button onClick={onCalculate} isLoading={isLoading} disabled={!position || !turnstileToken}>
        {t('calculate_button')}
      </Button>
    </>
  );
};
