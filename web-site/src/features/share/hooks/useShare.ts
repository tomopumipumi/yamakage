import { format } from 'date-fns';
import { format as formatTz, toZonedTime } from 'date-fns-tz';
import { toBlob } from 'html-to-image';
import { useCallback, useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';

import { useSkylineData } from '../../calculator/hooks/useSkylineData';
import { useCalculatorStore } from '../../calculator/store/calculatorStore';
import { useMapStore } from '../../map/store/mapStore';
import { createSectorPoints } from '../../map/utils/geoUtils';

export type ShareFormat = 'text' | 'json' | 'image';

export const formatTime = (timestamp: number | null, tz: string) => {
  if (!timestamp) return '--:--';
  const date = new Date(timestamp * 1000);
  return formatTz(toZonedTime(date, tz), 'HH:mm', { timeZone: tz });
};

export const useShare = () => {
  const { t } = useTranslation();

  const {
    position,
    targetDate,
    sunriseTime,
    sunsetTime,
    timezone,
    isPolar,
    azimuthProfiles,
    sunPath,
    hoveredAzimuth,
    pinnedAzimuth,
    radiusMeters,
  } = useCalculatorStore();

  const currentLayer = useMapStore((state) => state.currentLayer);
  const zoom = useMapStore((state) => state.zoom);

  const [activeFormat, setActiveFormat] = useState<ShareFormat>('image');
  const [isCopied, setIsCopied] = useState(false);
  const [isGenerating, setIsGenerating] = useState(false);
  const [previewScale, setPreviewScale] = useState(0.3);

  const mergedData = useSkylineData(azimuthProfiles, sunPath);

  const activeAzimuth = pinnedAzimuth !== null ? pinnedAzimuth : hoveredAzimuth;

  const sectorPositions = useMemo(() => {
    if (!position || activeAzimuth === null) return null;
    let spreadDeg = 7.5;
    if (azimuthProfiles && azimuthProfiles.length >= 2) {
      spreadDeg = Math.abs(azimuthProfiles[1].azimuthDeg - azimuthProfiles[0].azimuthDeg) / 2;
    }
    return createSectorPoints(position.lat, position.lng, activeAzimuth, radiusMeters, spreadDeg);
  }, [position, activeAzimuth, azimuthProfiles, radiusMeters]);

  const highestObstaclePoint = useMemo(() => {
    if (activeAzimuth === null || !azimuthProfiles || azimuthProfiles.length === 0) return null;

    let closestProfile = azimuthProfiles[0];
    let minDiff = 360;

    for (const profile of azimuthProfiles) {
      let diff = Math.abs(profile.azimuthDeg - activeAzimuth);
      if (diff > 180) diff = 360 - diff;
      if (diff < minDiff) {
        minDiff = diff;
        closestProfile = profile;
      }
    }

    return closestProfile.highestPoint || null;
  }, [activeAzimuth, azimuthProfiles]);

  const cardProps = position
    ? {
        position,
        timezone,
        targetDate,
        sunriseTime,
        sunsetTime,
        isPolar,
        mergedData,
        currentLayer,
        zoom,
        sectorPositions,
        highestObstaclePoint,
        pinnedAzimuth,
        t,
        formatTime,
      }
    : null;

  const previewContainerRef = useCallback((node: HTMLDivElement | null) => {
    if (node !== null) {
      setPreviewScale(node.offsetWidth / 1200);
      const observer = new ResizeObserver((entries) => {
        if (entries[0]) {
          setPreviewScale(entries[0].contentRect.width / 1200);
        }
      });
      observer.observe(node);
    }
  }, []);

  const shareContent = useMemo(() => {
    if (!position) return '';
    const shareUrl = `${window.location.href.split('?')[0]}?lat=${position.lat.toFixed(4)}&lng=${position.lng.toFixed(4)}&tz=${encodeURIComponent(timezone)}`;
    const formattedTargetDate = format(new Date(targetDate), 'yyyy/MM/dd');

    if (activeFormat === 'text') {
      return `⛰️ YAMAKAGE - ${t('app_subtitle')}

📅 ${t('target_date')}: ${formattedTargetDate}
📍 ${t('position_format', { lat: position.lat.toFixed(4), lon: position.lng.toFixed(4) })}
🕒 ${t('timezone')}: ${timezone}

🌅 ${t('sunrise_label')}: ${formatTime(sunriseTime, timezone)}
🌇 ${t('sunset_label')}: ${formatTime(sunsetTime, timezone)}

🔗 ${shareUrl}`;
    }
    if (activeFormat === 'json') {
      return JSON.stringify(
        {
          app: 'YAMAKAGE',
          targetDate: formattedTargetDate,
          coordinates: {
            lat: Number(position.lat.toFixed(4)),
            lng: Number(position.lng.toFixed(4)),
          },
          timezone,
          results: {
            sunrise: formatTime(sunriseTime, timezone),
            sunset: formatTime(sunsetTime, timezone),
            isPolar,
          },
          url: shareUrl,
        },
        null,
        2,
      );
    }
    return '';
  }, [activeFormat, position, targetDate, sunriseTime, sunsetTime, timezone, isPolar, t]);

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
    window.open(
      `https://twitter.com/intent/tweet?text=${encodeURIComponent(shareContent)}`,
      '_blank',
    );
  };

  const handleShareImage = async () => {
    const element = document.getElementById('capture-target');
    if (!element) return;

    setIsGenerating(true);
    try {
      await new Promise((resolve) => setTimeout(resolve, 600));
      const blob = await toBlob(element, { cacheBust: true, pixelRatio: 1 });
      if (!blob) throw new Error('Failed to create blob');

      const file = new File([blob], 'yamakage-result.png', { type: 'image/png' });

      if (navigator.canShare?.({ files: [file] })) {
        await navigator.share({
          title: 'YAMAKAGE',
          text: t('app_subtitle'),
          files: [file],
        });
      } else {
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'yamakage-result.png';
        a.click();
        URL.revokeObjectURL(url);
      }
    } catch (error) {
      if (
        error instanceof Error &&
        (error.name === 'AbortError' || error.message.toLowerCase().includes('cancel'))
      ) {
        return;
      }

      console.error('Image generation failed', error);
      alert(t('error_calculation_failed'));
    } finally {
      setIsGenerating(false);
    }
  };

  return {
    t,
    isCalculated: !!position && (!!sunriseTime || !!sunsetTime || isPolar),
    cardProps,
    activeFormat,
    setActiveFormat,
    shareContent,
    previewContainerRef,
    previewScale,
    isGenerating,
    isCopied,
    handleCopy,
    handleShareX,
    handleShareImage,
  };
};
