import L from 'leaflet';
import type React from 'react';
import { useEffect, useMemo } from 'react';
import {
  MapContainer,
  Marker,
  Polygon,
  Polyline,
  TileLayer,
  useMap,
  useMapEvents,
} from 'react-leaflet';
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
  const setZoom = useMapStore((state) => state.setZoom);

  useMapEvents({
    click(e) {
      setPosition({ lat: e.latlng.lat, lng: e.latlng.lng });
    },
    zoomend(e) {
      setZoom(e.target.getZoom());
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

const obstacleIconHtml = `
  <div style="display: flex; align-items: center; justify-content: center; width: 32px; height: 32px;">
    <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="#ef4444" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/>
      <circle cx="12" cy="10" r="3" fill="white"/>
    </svg>
  </div>
`;

const obstacleIcon = new L.DivIcon({
  html: obstacleIconHtml,
  className: '',
  iconSize: [32, 32],
  iconAnchor: [16, 32],
});

const PinMarker: React.FC<{ position: { lat: number; lng: number } }> = ({ position }) => {
  return <Marker position={[position.lat, position.lng]} icon={customIcon} />;
};

export const YamakageMap = () => {
  const { position, hoveredAzimuth, pinnedAzimuth, azimuthProfiles, radiusMeters } =
    useCalculatorStore();
  const currentLayer = useMapStore((state) => state.currentLayer);
  const zoom = useMapStore((state) => state.zoom);

  const initialCenter: [number, number] = position
    ? [position.lat, position.lng]
    : [35.3606, 138.7274];

  const activeAzimuth = pinnedAzimuth !== null ? pinnedAzimuth : hoveredAzimuth;

  const sectorPositions = useMemo(() => {
    if (!position || activeAzimuth === null) return null;

    let spreadDeg = 7.5;
    if (azimuthProfiles && azimuthProfiles.length >= 2) {
      const step = Math.abs(azimuthProfiles[1].azimuthDeg - azimuthProfiles[0].azimuthDeg);
      spreadDeg = step / 2;
    }

    return createSectorPoints(position.lat, position.lng, activeAzimuth, radiusMeters, spreadDeg);
  }, [position, activeAzimuth, azimuthProfiles, radiusMeters]);

  const highestObstaclePoint = useMemo(() => {
    if (activeAzimuth === null || !azimuthProfiles || azimuthProfiles.length === 0) return null;

    let closestProfile = azimuthProfiles[0];
    let minDiff = 360;

    for (const profile of azimuthProfiles) {
      let diff = Math.abs(profile.azimuthDeg - activeAzimuth);
      if (diff > 180) diff = 360 - diff;
      if (diff < minDiff) {
        minDiff = diff;
        closestProfile = profile;
      }
    }

    return closestProfile.highestPoint || null;
  }, [activeAzimuth, azimuthProfiles]);

  return (
    <div className="relative w-full h-full">
      <LayerSelecter />
      <MapContainer
        center={initialCenter}
        zoom={zoom}
        className="w-full h-full"
        zoomControl={false}
      >
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

        {highestObstaclePoint && position && (
          <Polyline
            positions={[
              [position.lat, position.lng],
              [highestObstaclePoint.lat, highestObstaclePoint.lng],
            ]}
            pathOptions={{ color: '#ef4444', dashArray: '5, 5', weight: 2 }}
          />
        )}
        {highestObstaclePoint && (
          <Marker
            position={[highestObstaclePoint.lat, highestObstaclePoint.lng]}
            icon={obstacleIcon}
          />
        )}
      </MapContainer>
    </div>
  );
};
