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
import { getObstacleColor, getObstacleIcon, getObstacleType } from '../utils/obstacleUtils';
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

const PinMarker: React.FC<{ position: { lat: number; lng: number } }> = ({ position }) => {
  return <Marker position={[position.lat, position.lng]} icon={customIcon} />;
};

export const YamakageMap = () => {
  const {
    position,
    hoveredAzimuth,
    pinnedAzimuth,
    azimuthProfiles,
    radiusMeters,
    currentAltitude,
  } = useCalculatorStore();
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

  const targetProfile = useMemo(() => {
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

    return closestProfile;
  }, [activeAzimuth, azimuthProfiles]);

  const highestObstaclePoint = targetProfile?.highestPoint || null;

  const targetPoint = targetProfile
    ? {
        azimuth: targetProfile.azimuthDeg,
        terrain: targetProfile.maxObstacleAngleDeg,
        highestAltitude: targetProfile.highestAltitude,
      }
    : undefined;

  const obstacleType = getObstacleType(targetPoint, currentAltitude);

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
            pathOptions={{
              color: getObstacleColor(obstacleType),
              dashArray: '5, 5',
              weight: 2,
            }}
          />
        )}
        {highestObstaclePoint && (
          <Marker
            position={[highestObstaclePoint.lat, highestObstaclePoint.lng]}
            icon={getObstacleIcon(obstacleType)}
          />
        )}
      </MapContainer>
    </div>
  );
};
