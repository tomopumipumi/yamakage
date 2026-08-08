import React, { useEffect, useMemo } from 'react';
import { MapContainer, TileLayer, Marker, Polygon, useMapEvents, useMap } from 'react-leaflet';
import L from 'leaflet';
import { useCalculatorStore } from '../../calculator/store/calculatorStore';
import { createSectorPoints } from '../utils/geoUtils';

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

export const YamakageMap: React.FC = () => {
  const position = useCalculatorStore((state) => state.position);
  const hoveredAzimuth = useCalculatorStore((state) => state.hoveredAzimuth);

  const initialCenter: [number, number] = position ? [position.lat, position.lng] : [35.3606, 138.7274];

  const sectorPositions = useMemo(() => {
    if (!position || hoveredAzimuth === null) return null;
    return createSectorPoints(position.lat, position.lng, hoveredAzimuth);
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