import L from 'leaflet';
import type { SkylineChartPoint } from '../../calculator/hooks/useSkylineData';

export type ObstacleType = 'horizon' | 'small' | 'mountain';

export function getObstacleType(
  targetPoint?: SkylineChartPoint,
  currentAltitude?: number | null,
): ObstacleType {
  if (!targetPoint) return 'horizon';

  if (
    targetPoint.highestAltitude !== undefined &&
    currentAltitude !== null &&
    currentAltitude !== undefined
  ) {
    const alt = targetPoint.highestAltitude;
    if (alt <= 0) return 'horizon';

    const diff = alt - currentAltitude;
    if (diff <= 100) return 'small';

    return 'mountain';
  }

  const angle = targetPoint.terrain;
  if (angle <= 0.0) return 'horizon';
  if (angle <= 3.0) return 'small';
  return 'mountain';
}

const obstacleIconHtml = `
  <div style="display: flex; align-items: center; justify-content: center; width: 32px; height: 32px;">
    <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="#ef4444" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/>
      <path d="M8 11.5 L12 7.5 L16 11.5 Z" fill="white" stroke="white" stroke-linejoin="round"/>
    </svg>
  </div>
`;

const smallObstacleIconHtml = `
  <div style="display: flex; align-items: center; justify-content: center; width: 32px; height: 32px;">
    <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="#f59e0b" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/>
      <path d="M6 13.5 Q 9 8.5 12 13.5 Z" fill="white" stroke="white" stroke-linejoin="round"/>
      <path d="M10 13.5 Q 12.5 10 15 13.5 Z" fill="white" stroke="white" stroke-linejoin="round"/>
    </svg>
  </div>
`;

const horizonIconHtml = `
  <div style="display: flex; align-items: center; justify-content: center; width: 32px; height: 32px;">
    <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="#0ea5e9" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/>
      <path d="M8 10.5c1 0 1.5-1 2.5-1s1.5 1 2.5 1 1.5-1 2.5-1" fill="none" stroke="white" stroke-width="1.5" />
      <path d="M10 13.5c1 0 1.5-1 2.5-1s1.5 1 2.5 1" fill="none" stroke="white" stroke-width="1.5" />
    </svg>
  </div>
`;

export const getObstacleIcon = (type: ObstacleType) => {
  const html =
    type === 'horizon'
      ? horizonIconHtml
      : type === 'small'
        ? smallObstacleIconHtml
        : obstacleIconHtml;
  return new L.DivIcon({
    html,
    className: '',
    iconSize: [32, 32],
    iconAnchor: [16, 32],
  });
};

export const getObstacleColor = (type: ObstacleType) => {
  return type === 'horizon' ? '#0ea5e9' : type === 'small' ? '#f59e0b' : '#ef4444';
};
