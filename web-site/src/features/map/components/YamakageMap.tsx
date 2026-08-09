import L from 'leaflet';
import type React from 'react';
import { useEffect, useMemo } from 'react';
import { MapContainer, Marker, Polygon, TileLayer, useMap, useMapEvents } from 'react-leaflet';
import { useCalculatorStore } from '../../calculator/store/calculatorStore';
import { useMapStore } from '../store/mapStore';
import { createSectorPoints } from '../utils/geoUtils';
import { LayerSelecter } from './LayerSelecter';

const MapUpdater: React.FC<{ position: { lat: number; lng: number } | null }> = ({ position }) => {
  const map = useMap();
  useEffect(() => {
    if (position) map.panTo([position.lat, position.lng], { animate: true });
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

const customIcon = new L.Icon({
  iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41],
});

const PinMarker: React.FC<{ position: { lat: number; lng: number } }> = ({ position }) => {
  return <Marker position={[position.lat, position.lng]} icon={customIcon} />;
};

// YamakageMap-----
export const YamakageMap = () => {
  const position = useCalculatorStore((state) => state.position);
  const currentLayer = useMapStore((state) => state.currentLayer);
  const hoveredAzimuth = useCalculatorStore((state) => state.hoveredAzimuth);

  const initialCenter: [number, number] = position
    ? [position.lat, position.lng]
    : [35.3606, 138.7274];

  const sectorPositions = useMemo(() => {
    return position && hoveredAzimuth !== null
      ? createSectorPoints(position.lat, position.lng, hoveredAzimuth)
      : null;
  }, [position, hoveredAzimuth]);

  return (
    <div className="relative w-full h-full">
      <LayerSelecter />

      <MapContainer center={initialCenter} zoom={11} className="w-full h-full" zoomControl={false}>
        <TileLayer
          key={currentLayer.id}
          attribution={currentLayer.attribution}
          url={currentLayer.url}
          maxZoom={19}
        />
        <MapEvents />
        <MapUpdater position={position} />
        {position && <PinMarker position={position} />}
        {sectorPositions && (
          <Polygon
            positions={sectorPositions}
            pathOptions={{
              color: '#f97316',
              fillColor: '#f97316',
              fillOpacity: 0.35,
              weight: 2,
            }}
          />
        )}
      </MapContainer>
    </div>
  );
};
