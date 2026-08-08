import React, { useState, useMemo } from 'react';
import { Share2, Copy, Check, X } from 'lucide-react';
import { useTranslation } from 'react-i18next';
import { useUiStore } from '../../store/uiStore';
import { useCalculatorStore } from '../../features/calculator/store/calculatorStore';
import { format, toZonedTime } from 'date-fns-tz';
import { BaseDialog } from './BaseDialog';

type ShareFormat = 'text' | 'json';

export const ShareDialog: React.FC = () => {
  const { t } = useTranslation();
  const { isShareOpen, setShareOpen } = useUiStore();
  const { position, sunriseTime, sunsetTime, timezone, isPolar } = useCalculatorStore();
  
  const [activeFormat, setActiveFormat] = useState<ShareFormat>('text');
  const [isCopied, setIsCopied] = useState(false);

  const formatTime = (timestamp: number | null, tz: string) => {
    if (!timestamp) return '--:--';
    const date = new Date(timestamp * 1000);
    return format(toZonedTime(date, tz), 'HH:mm', { timeZone: tz });
  };

  const shareContent = useMemo(() => {
    if (!position || (!sunriseTime && !sunsetTime && !isPolar)) {
      return '';
    }

    const currentUrl = typeof window !== 'undefined' ? window.location.href.split('?')[0] : '';
    const encodedTz = encodeURIComponent(timezone);
    const shareUrl = `${currentUrl}?lat=${position.lat.toFixed(4)}&lng=${position.lng.toFixed(4)}&tz=${encodedTz}`;

    if (activeFormat === 'text') {
      return `⛰️ YAMAKAGE - ${t('app_subtitle')}\n\n` +
             `📍 ${t('position_format', { lat: position.lat.toFixed(4), lon: position.lng.toFixed(4) })}\n` +
             `🕒 ${t('timezone')}: ${timezone}\n` +
             `🌅 ${t('sunrise_label')}: ${formatTime(sunriseTime, timezone)}\n` +
             `🌇 ${t('sunset_label')}: ${formatTime(sunsetTime, timezone)}\n\n` +
             `🔗 ${shareUrl}`;
    }

    const jsonObj = {
      app: "YAMAKAGE",
      coordinates: { lat: Number(position.lat.toFixed(4)), lng: Number(position.lng.toFixed(4)) },
      timezone,
      results: {
        sunrise: formatTime(sunriseTime, timezone),
        sunset: formatTime(sunsetTime, timezone),
        isPolar
      },
      url: shareUrl
    };
    return JSON.stringify(jsonObj, null, 2);
  }, [activeFormat, position, sunriseTime, sunsetTime, timezone, isPolar, t]);

  const handleCopy = async () => {
    if (!shareContent) return;
    try {
      await navigator.clipboard.writeText(shareContent);
      setIsCopied(true);
      setTimeout(() => setIsCopied(false), 2000);
    } catch (err) {
      console.error('Failed to copy text: ', err);
    }
  };

  const handleShareX = () => {
    if (!shareContent) return;
    const xUrl = `https://twitter.com/intent/tweet?text=${encodeURIComponent(shareContent)}`;
    window.open(xUrl, '_blank');
  };

  return (
    <BaseDialog
      isOpen={isShareOpen}
      onClose={() => setShareOpen(false)}
      title={t('share.title')}
      icon={<Share2 className="w-5 h-5 text-blue-400" />}
      maxWidth="max-w-lg"
    >
      <div className="space-y-4">
        {!shareContent ? (
          <div className="text-center py-10 text-slate-400">
            {t('share.not_calculated')}
          </div>
        ) : (
          <>
            <div className="flex bg-slate-800 rounded-lg p-1 border border-slate-700">
              <button
                onClick={() => setActiveFormat('text')}
                className={`flex-1 py-2 text-sm font-bold rounded-md transition-all cursor-pointer ${
                  activeFormat === 'text' ? 'bg-slate-700 text-white shadow' : 'text-slate-400 hover:text-slate-200'
                }`}
              >
                {t('share.format_text')}
              </button>
              <button
                onClick={() => setActiveFormat('json')}
                className={`flex-1 py-2 text-sm font-bold rounded-md transition-all cursor-pointer ${
                  activeFormat === 'json' ? 'bg-slate-700 text-white shadow' : 'text-slate-400 hover:text-slate-200'
                }`}
              >
                {t('share.format_json')}
              </button>
            </div>

            <textarea
              readOnly
              value={shareContent}
              className="w-full h-48 bg-slate-950 text-slate-300 rounded-xl p-4 border border-slate-700 font-mono text-sm resize-none focus:outline-none"
            />

            <div className="flex gap-3">
              <button 
                onClick={handleCopy}
                className="flex-1 py-3 px-4 bg-slate-800 hover:bg-slate-700 border border-slate-600 text-white rounded-lg font-bold transition-colors flex items-center justify-center gap-2 cursor-pointer"
              >
                {isCopied ? <Check className="w-5 h-5 text-emerald-400" /> : <Copy className="w-5 h-5" />}
                {isCopied ? t('share.copied') : t('share.copy_button')}
              </button>
              
              {activeFormat === 'text' && (
                <button 
                  onClick={handleShareX}
                  className="flex-1 py-3 px-4 bg-blue-600 hover:bg-blue-500 text-white rounded-lg font-bold transition-colors flex items-center justify-center gap-2 cursor-pointer"
                >
                  <X className="w-5 h-5 fill-current" />
                  {t('share.share_x')}
                </button>
              )}
            </div>
          </>
        )}
      </div>
    </BaseDialog>
  );
};