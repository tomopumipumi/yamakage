import type { SamplingPoint } from '../models/types';

const EARTH_RADIUS_M = 6371e3;

const generateLinePoints = (
  startLat: number,
  startLng: number,
  azimuthDeg: number,
  intervalMeters: number = 100,
  maxDistanceMeters: number = 10000,
): SamplingPoint[] => {
  const points: SamplingPoint[] = [];
  const startLatRad = startLat * (Math.PI / 180);
  const startLngRad = startLng * (Math.PI / 180);
  const azimuthRad = azimuthDeg * (Math.PI / 180);

  for (let distance = intervalMeters; distance <= maxDistanceMeters; distance += intervalMeters) {
    const angularDistance = distance / EARTH_RADIUS_M;
    const latRad = Math.asin(
      Math.sin(startLatRad) * Math.cos(angularDistance) +
        Math.cos(startLatRad) * Math.sin(angularDistance) * Math.cos(azimuthRad),
    );
    const lngRad =
      startLngRad +
      Math.atan2(
        Math.sin(azimuthRad) * Math.sin(angularDistance) * Math.cos(startLatRad),
        Math.cos(angularDistance) - Math.sin(startLatRad) * Math.sin(latRad),
      );

    points.push({
      lat: latRad * (180 / Math.PI),
      lng: lngRad * (180 / Math.PI),
      distance,
    });
  }

  return points;
};

export interface TerrainProfile {
  azimuth: number;
  points: SamplingPoint[];
}

export const TerrainSamplingEngine = {
  generateFullPanorama: (
    startLat: number,
    startLng: number,
    stepDeg: number = 15,
  ): TerrainProfile[] => {
    const panorama = [];
    for (let az = 0; az < 360; az += stepDeg) {
      const points: SamplingPoint[] = [];

      // 0-500m: 100m interval (5 points)
      points.push(...generateLinePoints(startLat, startLng, az, 100, 500));

      // 500-2km: 300m interval (5 points)
      points.push(
        ...generateLinePoints(startLat, startLng, az, 300, 2000).filter((p) => p.distance > 500),
      );

      // 2-10km: 2000m interval (4 points)
      points.push(
        ...generateLinePoints(startLat, startLng, az, 2000, 10000).filter((p) => p.distance > 2000),
      );

      // 10-20km: 5000m interval (4 points)
      points.push(
        ...generateLinePoints(startLat, startLng, az, 5000, 20000).filter(
          (p) => p.distance > 10000,
        ),
      );

      panorama.push({
        azimuth: az,
        points,
      });
    }
    return panorama;
  },
};
