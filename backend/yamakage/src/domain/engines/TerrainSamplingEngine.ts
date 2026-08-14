import type { SamplingPoint } from '../models/types';

const EARTH_RADIUS_M = 6371e3;

interface GenerateLinePointsContext {
  startLat: number;
  startLng: number;
  azimuthDeg: number;
  startDistanceMeters: number;
  maxDistanceMeters: number;
  intervalMeters: number;
}

const generateLinePoints = ({
  startLat,
  startLng,
  azimuthDeg,
  startDistanceMeters,
  maxDistanceMeters,
  intervalMeters,
}: GenerateLinePointsContext): SamplingPoint[] => {
  const startLatRad = startLat * (Math.PI / 180);
  const startLngRad = startLng * (Math.PI / 180);
  const azimuthRad = azimuthDeg * (Math.PI / 180);

  const points: SamplingPoint[] = [];

  for (
    let distance = startDistanceMeters;
    distance <= maxDistanceMeters;
    distance += intervalMeters
  ) {
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
    const numAzimuths = Math.floor(360 / stepDeg);

    return Array.from({ length: numAzimuths }, (_, index) => {
      const az = index * stepDeg;

      const points: SamplingPoint[] = [
        ...generateLinePoints({
          startLat,
          startLng,
          azimuthDeg: az,
          startDistanceMeters: 100,
          maxDistanceMeters: 2000,
          intervalMeters: 30,
        }),
        ...generateLinePoints({
          startLat,
          startLng,
          azimuthDeg: az,
          startDistanceMeters: 2090,
          maxDistanceMeters: 10000,
          intervalMeters: 90,
        }),
        ...generateLinePoints({
          startLat,
          startLng,
          azimuthDeg: az,
          startDistanceMeters: 10200,
          maxDistanceMeters: 30000,
          intervalMeters: 200,
        }),
      ];

      return { azimuth: az, points };
    });
  },
};
