import { format } from 'date-fns';
import type { TFunction } from 'i18next';
import L from 'leaflet';
import { Calendar, Globe, MapPin, Sunrise, Sunset } from 'lucide-react';
import type React from 'react';
import { MapContainer, Marker, Polygon, TileLayer } from 'react-leaflet';
import { Area, CartesianGrid, ComposedChart, Line, ReferenceLine, XAxis, YAxis } from 'recharts';

import iconUrl from '../../../assets/icon.svg';
import type { SkylineChartPoint } from '../../calculator/hooks/useSkylineData';
import type { MapLayerOption } from '../../map/store/mapStore';

const stripHtml = (html: string) => {
  const tmp = document.createElement('div');
  tmp.innerHTML = html;
  return tmp.textContent || tmp.innerText || '';
};

const customMarkerHtml = `
  <div style="display: flex; align-items: center; justify-content: center; width: 32px; height: 32px;">
    <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="#f97316" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/>
      <circle cx="12" cy="10" r="3" fill="white"/>
    </svg>
  </div>
`;

const customIcon = new L.DivIcon({
  html: customMarkerHtml,
  className: '',
  iconSize: [32, 32],
  iconAnchor: [16, 32],
});

export interface ShareImageCardProps {
  position: { lat: number; lng: number };
  timezone: string;
  targetDate: string;
  sunriseTime: number | null;
  sunsetTime: number | null;
  isPolar: boolean;
  mergedData: SkylineChartPoint[];
  currentLayer: MapLayerOption;
  zoom: number;
  sectorPositions: { lat: number; lng: number }[] | null;
  pinnedAzimuth: number | null;
  t: TFunction;
  formatTime: (timestamp: number | null, tz: string) => string;
}

export const ShareImageCard: React.FC<ShareImageCardProps> = ({
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
  pinnedAzimuth,
  t,
  formatTime,
}) => {
  const formattedTargetDate = format(new Date(targetDate), 'yyyy/MM/dd');

  return (
    <div className="w-[1200px] h-[630px] bg-slate-900 relative overflow-hidden flex font-sans text-white">
      <div className="absolute top-0 bottom-0 left-0 w-[1900px] z-0">
        <MapContainer
          center={[position.lat, position.lng]}
          zoom={zoom}
          zoomControl={false}
          attributionControl={false}
          style={{ width: '100%', height: '100%' }}
        >
          <TileLayer url={currentLayer.url} crossOrigin="anonymous" />
          <Marker position={[position.lat, position.lng]} icon={customIcon} />
          {sectorPositions && (
            <Polygon
              positions={sectorPositions}
              pathOptions={{ color: '#f97316', fillColor: '#f97316', fillOpacity: 0.35, weight: 2 }}
            />
          )}
        </MapContainer>
      </div>

      <div className="absolute inset-0 w-[1200px] z-10 bg-gradient-to-r from-slate-950 via-slate-900/90 to-transparent pointer-events-none" />

      <div className="absolute bottom-2 right-4 z-30 text-[10px] text-white/60 bg-slate-900/60 px-2 py-0.5 rounded backdrop-blur-md pointer-events-none">
        {stripHtml(currentLayer.attribution)}
      </div>

      <div className="relative z-20 flex flex-col justify-between p-12 w-[700px] h-full pointer-events-none">
        <div className="flex items-center gap-6">
          <img
            src={iconUrl}
            alt="Logo"
            className="w-24 h-24 rounded-full shadow-2xl shadow-orange-500/20"
            crossOrigin="anonymous"
          />
          <div>
            <h1 className="text-5xl font-bold text-white tracking-widest">YAMAKAGE</h1>
            <p className="text-xl text-orange-400 mt-2 font-medium">{t('app_subtitle')}</p>
          </div>
        </div>

        <div className="space-y-6">
          <div className="space-y-2 text-slate-300 text-lg font-medium">
            <div className="flex items-center gap-3">
              <Calendar className="w-5 h-5 text-slate-400" />
              {t('target_date')}: {formattedTargetDate}
            </div>
            <div className="flex items-center gap-3">
              <MapPin className="w-5 h-5 text-slate-400" />
              {t('position_format', { lat: position.lat.toFixed(4), lon: position.lng.toFixed(4) })}
            </div>
            <div className="flex items-center gap-3">
              <Globe className="w-5 h-5 text-slate-400" />
              {timezone}
            </div>
          </div>

          {isPolar ? (
            <div className="bg-blue-900/40 border border-blue-500/50 p-6 rounded-2xl text-blue-200 text-2xl font-bold text-center">
              {t('polar_alert')}
            </div>
          ) : (
            <div className="grid grid-cols-2 gap-6">
              <div className="bg-slate-800/80 rounded-2xl p-6 border border-slate-700 shadow-xl backdrop-blur-md">
                <div className="flex items-center gap-3 mb-2">
                  <div className="p-3 rounded-xl bg-yellow-500/20">
                    <Sunrise className="w-8 h-8 text-yellow-500" />
                  </div>
                  <span className="text-xl text-slate-300 font-medium">{t('sunrise_label')}</span>
                </div>
                <div className="text-5xl font-bold text-white mt-4">
                  {formatTime(sunriseTime, timezone)}
                </div>
              </div>
              <div className="bg-slate-800/80 rounded-2xl p-6 border border-slate-700 shadow-xl backdrop-blur-md">
                <div className="flex items-center gap-3 mb-2">
                  <div className="p-3 rounded-xl bg-purple-500/20">
                    <Sunset className="w-8 h-8 text-purple-400" />
                  </div>
                  <span className="text-xl text-slate-300 font-medium">{t('sunset_label')}</span>
                </div>
                <div className="text-5xl font-bold text-white mt-4">
                  {formatTime(sunsetTime, timezone)}
                </div>
              </div>
            </div>
          )}
        </div>

        <div className="w-[600px] h-[180px] bg-slate-950/80 rounded-2xl p-4 border border-slate-700 shadow-xl backdrop-blur-md relative">
          <div className="absolute top-2 left-4 text-xs font-bold text-slate-400 z-10 flex items-center gap-4">
            <div className="flex items-center gap-1.5">
              <div className="w-3 h-3 bg-slate-600 rounded-sm" />
              {t('skyline_terrain')}
            </div>
            <div className="flex items-center gap-1.5">
              <div className="w-4 h-1.5 bg-orange-500 rounded-full" />
              {t('sun_path')}
            </div>
            {pinnedAzimuth !== null && (
              <div className="flex items-center gap-1.5">
                <div className="w-0.5 h-3 bg-yellow-500" />
                <span className="text-yellow-500 font-bold">
                  {t('pinned_azimuth')}: {pinnedAzimuth.toFixed(1)}°
                </span>
              </div>
            )}
          </div>

          <ComposedChart
            width={568}
            height={148}
            data={mergedData}
            margin={{ top: 18, right: 10, left: -20, bottom: 0 }}
          >
            <CartesianGrid strokeDasharray="3 3" stroke="#334155" vertical={false} />
            <XAxis
              dataKey="azimuth"
              type="number"
              domain={[0, 360]}
              ticks={[0, 90, 180, 270, 360]}
              stroke="#64748b"
              tick={{ fontSize: 12 }}
              tickFormatter={(val) => {
                if (val === 0 || val === 360) return 'N';
                if (val === 90) return 'E';
                if (val === 180) return 'S';
                if (val === 270) return 'W';
                return String(val);
              }}
            />
            <YAxis stroke="#64748b" tick={{ fontSize: 12 }} />

            <Area
              type="monotone"
              dataKey="terrain"
              fill="#475569"
              stroke="#94a3b8"
              fillOpacity={0.7}
              isAnimationActive={false}
            />
            <Line
              type="monotone"
              dataKey="sun"
              stroke="#f97316"
              strokeWidth={3}
              dot={false}
              connectNulls
              isAnimationActive={false}
            />

            {pinnedAzimuth !== null && (
              <ReferenceLine
                x={pinnedAzimuth}
                stroke="#eab308"
                strokeWidth={2}
                strokeDasharray="3 3"
                label={{
                  position: 'insideTopLeft',
                  value: `${pinnedAzimuth.toFixed(1)}°`,
                  fill: '#eab308',
                  fontSize: 14,
                  fontWeight: 'bold',
                }}
              />
            )}
          </ComposedChart>
        </div>
      </div>
    </div>
  );
};
