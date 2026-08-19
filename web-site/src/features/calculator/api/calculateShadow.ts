export interface TerrainAzimuthProfile {
  azimuthDeg: number;
  maxObstacleAngleDeg: number;
  highestPoint?: { lat: number; lng: number };
  highestAltitude?: number;
  distance?: number;
}

export interface SunPathPoint {
  time: number;
  azimuth: number;
  altitude: number;
}

export interface ShadowResult {
  sunsetTime: number | null;
  minutesToSunset: number | null;
  sunriseTime: number | null;
  minutesToSunrise: number | null;
  isPolar: boolean;
  azimuthProfiles?: TerrainAzimuthProfile[];
  sunPath?: SunPathPoint[];
  radiusMeters: number;
  currentAltitude: number;
}

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '';

export const calculateShadow = async (
  lat: number,
  lng: number,
  timestamp: number,
  turnstileToken: string,
): Promise<ShadowResult> => {
  const response = await fetch(`${API_BASE_URL}/api/v1/web/shadow`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Turnstile-Token': turnstileToken,
    },
    body: JSON.stringify({ lat, lng, time: timestamp }),
  });

  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}));
    throw new Error(errorData.error || `API request failed with status ${response.status}`);
  }

  return await response.json();
};
