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
    radiusMeters,
  } = useCalculatorStore();
  const currentLayer = useMapStore((state) => state.currentLayer);
  const zoom = useMapStore((state) => state.zoom);

  const [activeFormat, setActiveFormat] = useState<ShareFormat>('image');
  const [isCopied, setIsCopied] = useState(false);
  const [isGenerating, setIsGenerating] = useState(false);
  const [previewScale, setPreviewScale] = useState(0.3);

  const mergedData = useSkylineData(azimuthProfiles, sunPath);

  const sectorPositions = useMemo(() => {
    if (!position || hoveredAzimuth === null) return null;
    let spreadDeg = 7.5;
    if (azimuthProfiles && azimuthProfiles.length >= 2) {
      spreadDeg = Math.abs(azimuthProfiles[1].azimuthDeg - azimuthProfiles[0].azimuthDeg) / 2;
    }
    return createSectorPoints(position.lat, position.lng, hoveredAzimuth, radiusMeters, spreadDeg);
  }, [position, hoveredAzimuth, azimuthProfiles, radiusMeters]);

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
      return `⛰️ YAMAKAGE - ${t('app_subtitle')}\n\n📅 ${t('target_date')}: ${formattedTargetDate}\n📍 ${t('position_format', { lat: position.lat.toFixed(4), lon: position.lng.toFixed(4) })}\n🕒 ${t('timezone')}: ${timezone}\n🌅 ${t('sunrise_label')}: ${formatTime(sunriseTime, timezone)}\n🌇 ${t('sunset_label')}: ${formatTime(sunsetTime, timezone)}\n\n🔗 ${shareUrl}`;
    }
    if (activeFormat === 'json') {
      return JSON.stringify(
        {
          app: t('app_title'),
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
          title: t('app_title'),
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
      console.error('Image generation failed', error);
      alert(t('error_gen_image'));
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
