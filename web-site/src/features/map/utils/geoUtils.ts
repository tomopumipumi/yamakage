export function getDestinationPoint(
  lat: number,
  lng: number,
  brng: number,
  distMeters: number,
): { lat: number; lng: number } {
  const R = 6371000; // Earth's radius
  const rad = Math.PI / 180;
  const lat1 = lat * rad;
  const lon1 = lng * rad;
  const brngRad = brng * rad;
  const dR = distMeters / R;

  const lat2 = Math.asin(
    Math.sin(lat1) * Math.cos(dR) + Math.cos(lat1) * Math.sin(dR) * Math.cos(brngRad),
  );
  const lon2 =
    lon1 +
    Math.atan2(
      Math.sin(brngRad) * Math.sin(dR) * Math.cos(lat1),
      Math.cos(dR) - Math.sin(lat1) * Math.sin(lat2),
    );

  return {
    lat: lat2 / rad,
    lng: lon2 / rad,
  };
}

export function createSectorPoints(
  centerLat: number,
  centerLng: number,
  centerAzimuth: number,
  radiusMeters: number = 20000,
  spreadDeg: number = 15,
  steps: number = 12,
): [number, number][] {
  const points: [number, number][] = [[centerLat, centerLng]];
  const startAz = centerAzimuth - spreadDeg;
  const endAz = centerAzimuth + spreadDeg;
  const step = (endAz - startAz) / steps;

  for (let i = 0; i <= steps; i++) {
    const az = startAz + i * step;
    const dest = getDestinationPoint(centerLat, centerLng, az, radiusMeters);
    points.push([dest.lat, dest.lng]);
  }

  return points;
}
