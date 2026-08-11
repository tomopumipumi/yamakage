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
          startLat: startLat,
          startLng: startLng,
          azimuthDeg: az,
          startDistanceMeters: 50,
          maxDistanceMeters: 1000,
          intervalMeters: 50,
        }),

        ...generateLinePoints({
          startLat: startLat,
          startLng: startLng,
          azimuthDeg: az,
          startDistanceMeters: 1100,
          maxDistanceMeters: 5000,
          intervalMeters: 100,
        }),

        ...generateLinePoints({
          startLat: startLat,
          startLng: startLng,
          azimuthDeg: az,
          startDistanceMeters: 5250,
          maxDistanceMeters: 15000,
          intervalMeters: 250,
        }),

        ...generateLinePoints({
          startLat: startLat,
          startLng: startLng,
          azimuthDeg: az,
          startDistanceMeters: 15500,
          maxDistanceMeters: 30000,
          intervalMeters: 500,
        }),
      ];

      return { azimuth: az, points };
    });
  },
};
