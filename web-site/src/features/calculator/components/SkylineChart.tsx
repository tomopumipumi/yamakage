import type React from 'react';
import { useRef } from 'react';
import { useTranslation } from 'react-i18next';
import {
  Area,
  CartesianGrid,
  ComposedChart,
  Line,
  ReferenceLine,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';
import type { SunPathPoint, TerrainAzimuthProfile } from '../api/calculateShadow';
import { useSkylineData } from '../hooks/useSkylineData';
import { useCalculatorStore } from '../store/calculatorStore';

interface Props {
  azimuthProfiles: TerrainAzimuthProfile[];
  sunPath: SunPathPoint[];
}

interface RechartsEvent {
  activeLabel?: string | number | null;
  activePayload?: Array<{
    value?: number | string | null;
    name?: string | number;
    dataKey?: string | number;
    payload?: Record<string, unknown>;
  }>;
  isTooltipActive?: boolean;
  [key: string]: unknown;
}

export const SkylineChart: React.FC<Props> = ({ azimuthProfiles, sunPath }) => {
  const { t } = useTranslation();
  const { setHoveredAzimuth, pinnedAzimuth, setPinnedAzimuth } = useCalculatorStore();
  const mergedData = useSkylineData(azimuthProfiles, sunPath);

  const lastTouchTime = useRef<number>(0);

  const handleMouseMove = (e: RechartsEvent | null | undefined) => {
    if (e && e.activeLabel !== undefined && e.activeLabel !== null) {
      setHoveredAzimuth(Number(e.activeLabel));
    }
  };

  const handleMouseLeave = () => {
    setHoveredAzimuth(null);
  };

  const handleTouch = (e: RechartsEvent | null | undefined) => {
    lastTouchTime.current = Date.now();
    if (e && e.activeLabel !== undefined && e.activeLabel !== null) {
      const az = Number(e.activeLabel);
      setHoveredAzimuth(az);
      setPinnedAzimuth(az);
    }
  };

  const handleClick = (e: RechartsEvent | null | undefined) => {
    if (Date.now() - lastTouchTime.current < 500) return;

    if (e && e.activeLabel !== undefined && e.activeLabel !== null) {
      const az = Number(e.activeLabel);
      setPinnedAzimuth(pinnedAzimuth === az ? null : az);
    }
  };

  if (!mergedData.length) return null;

  return (
    <div className="w-full h-40 mt-4 bg-slate-950 rounded-xl p-2 border border-slate-700 relative overflow-hidden group touch-pan-y">
      <div className="absolute top-2 left-3 text-xs font-bold text-slate-400 z-10 flex flex-wrap items-center gap-3">
        <div className="flex items-center gap-1">
          <div className="w-3 h-3 bg-slate-600 rounded-sm" />
          {t('skyline_terrain')}
        </div>
        <div className="flex items-center gap-1">
          <div className="w-3 h-1 bg-orange-500 rounded-full" />
          {t('sun_path')}
        </div>
        {pinnedAzimuth !== null && (
          <div className="flex items-center gap-1">
            <div className="w-0.5 h-3 bg-yellow-500" />
            <span className="text-yellow-500">{pinnedAzimuth.toFixed(1)}°</span>
          </div>
        )}
      </div>

      <ResponsiveContainer width="100%" height="100%">
        <ComposedChart
          data={mergedData}
          margin={{ top: 20, right: 10, left: -25, bottom: 0 }}
          onMouseMove={handleMouseMove}
          onMouseLeave={handleMouseLeave}
          onClick={handleClick}
          onTouchStart={handleTouch}
          onTouchMove={handleTouch}
          onTouchEnd={handleMouseLeave}
        >
          <CartesianGrid strokeDasharray="3 3" stroke="#334155" vertical={false} />
          <XAxis
            dataKey="azimuth"
            type="number"
            domain={[0, 360]}
            ticks={[0, 90, 180, 270, 360]}
            tickFormatter={(val) => {
              if (val === 0 || val === 360) return 'N';
              if (val === 90) return 'E';
              if (val === 180) return 'S';
              if (val === 270) return 'W';
              return String(val);
            }}
            stroke="#64748b"
            tick={{ fontSize: 10 }}
          />
          <YAxis stroke="#64748b" tick={{ fontSize: 10 }} />
          <Tooltip
            contentStyle={{
              backgroundColor: 'rgba(15, 23, 42, 0.8)',
              borderColor: '#334155',
              color: '#fff',
              borderRadius: '8px',
              backdropFilter: 'blur(4px)',
            }}
            labelFormatter={(label) => `${t('azimuth')}: ${Number(label).toFixed(0)}°`}
            formatter={(value, name) => [
              value !== undefined && value !== null ? `${Number(value).toFixed(1)}°` : '',
              name === 'terrain' ? t('skyline_terrain') : t('sun_path'),
            ]}
            cursor={{ stroke: '#cbd5e1', strokeWidth: 1, strokeDasharray: '5 5' }}
          />

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
            strokeWidth={2}
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
                fontSize: 10,
                fontWeight: 'bold',
              }}
            />
          )}
        </ComposedChart>
      </ResponsiveContainer>
    </div>
  );
};
