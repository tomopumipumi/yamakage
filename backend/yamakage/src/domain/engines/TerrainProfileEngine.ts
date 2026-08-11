import type { SamplingPoint, TerrainAzimuthProfile } from '../models/types';

export const TerrainProfileEngine = {
  buildAzimuthProfiles: (
    currentLat: number,
    currentLng: number,
    panorama: { azimuth: number; points: SamplingPoint[] }[],
    elevationsMap: Map<string, number>,
  ): TerrainAzimuthProfile[] => {
    const getIntCoordinate = (coord: number) => Math.round(coord * 1000);
    const currentAltitude =
      elevationsMap.get(`${getIntCoordinate(currentLat)}_${getIntCoordinate(currentLng)}`) || 0;

    return panorama.map((pane) => {
      let maxAngle = -0.833;
      let highestPoint: { lat: number; lng: number } | undefined = undefined;

      for (const p of pane.points) {
        const altitude = elevationsMap.get(`${getIntCoordinate(p.lat)}_${getIntCoordinate(p.lng)}`);

        if (altitude === undefined) continue;

        const drop = ((p.distance * p.distance) / (2 * 6371e3)) * 0.86;
        const effectiveHeightDiff = altitude - currentAltitude - drop;

        const angleDeg = (Math.atan2(effectiveHeightDiff, p.distance) * 180) / Math.PI;

        if (angleDeg > maxAngle) {
          maxAngle = angleDeg;
          highestPoint = { lat: p.lat, lng: p.lng };
        }
      }

      return { azimuthDeg: pane.azimuth, maxObstacleAngleDeg: maxAngle, highestPoint };
    });
  },
};