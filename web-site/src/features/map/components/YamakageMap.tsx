import React, { useEffect, useMemo } from 'react';
import { MapContainer, TileLayer, Marker, Polygon, useMapEvents, useMap } from 'react-leaflet';
import L from 'leaflet';
import { useCalculatorStore } from '../../calculator/store/calculatorStore';

const customIcon = new L.Icon({
  iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41]
});

const MapUpdater: React.FC<{ position: { lat: number; lng: number } | null }> = ({ position }) => {
  const map = useMap();
  useEffect(() => {
    if (position) {
      map.panTo([position.lat, position.lng], { animate: true });
    }
  }, [position, map]);
  return null;
};

const MapEvents = () => {
  const setPosition = useCalculatorStore((state) => state.setPosition);
  
  useMapEvents({
    click(e) {
      setPosition({ lat: e.latlng.lat, lng: e.latlng.lng });
    },
  });
  return null;
};

function getDestinationPoint(lat: number, lng: number, brng: number, dist: number) {
  const R = 6371000;
  const rad = Math.PI / 180;
  const lat1 = lat * rad;
  const lon1 = lng * rad;
  const brngRad = brng * rad;
  const dR = dist / R;

  const lat2 = Math.asin(
    Math.sin(lat1) * Math.cos(dR) +
    Math.cos(lat1) * Math.sin(dR) * Math.cos(brngRad)
  );
  const lon2 = lon1 + Math.atan2(
    Math.sin(brngRad) * Math.sin(dR) * Math.cos(lat1),
    Math.cos(dR) - Math.sin(lat1) * Math.sin(lat2)
  );
  return {
    lat: lat2 / rad,
    lng: lon2 / rad
  };
}

function createSectorPoints(centerLat: number, centerLng: number, centerAzimuth: number, radiusMeters: number = 20000, spreadDeg: number = 15, steps: number = 12): [number, number][] {
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

export const YamakageMap: React.FC = () => {
  const position = useCalculatorStore((state) => state.position);
  const hoveredAzimuth = useCalculatorStore((state) => state.hoveredAzimuth);

  const initialCenter: [number, number] = position ? [position.lat, position.lng] : [35.3606, 138.7274];

  const sectorPositions = useMemo(() => {
    if (!position || hoveredAzimuth === null) return null;
    return createSectorPoints(position.lat, position.lng, hoveredAzimuth, 20000, 15, 12);
  }, [position, hoveredAzimuth]);

  return (
    <MapContainer 
      center={initialCenter} 
      zoom={11} 
      className="w-full h-full"
      zoomControl={false}
    >
      <TileLayer
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      />
      <MapEvents />
      <MapUpdater position={position} />
      {position && (
        <Marker position={[position.lat, position.lng]} icon={customIcon} />
      )}
      {sectorPositions && (
        <Polygon
          positions={sectorPositions}
          pathOptions={{
            color: '#f97316',
            fillColor: '#f97316',
            fillOpacity: 0.35,
            weight: 2
          }}
        />
      )}
    </MapContainer>
  );
};