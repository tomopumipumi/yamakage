import React, { useEffect, useMemo, useState } from 'react';
import { MapContainer, TileLayer, Marker, Polygon, useMapEvents, useMap } from 'react-leaflet';
import L from 'leaflet';
import { Layers } from 'lucide-react';
import { useCalculatorStore } from '../../calculator/store/calculatorStore';
import { createSectorPoints } from '../utils/geoUtils';

const customIcon = new L.Icon({
  iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41],
});

interface MapLayerOption {
  id: string;
  name: string;
  url: string;
  attribution: string;
}

const MAP_LAYERS: MapLayerOption[] = [
  {
    id: 'osm',
    name: 'Standard',
    url: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
  },
  {
    id: 'satellite',
    name: 'Satellite',
    url: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    attribution: 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community',
  },
  {
    id: 'dark',
    name: 'Dark Mode',
    url: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>',
  },
];

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

  const [currentLayerId, setCurrentLayerId] = useState<string>('osm');
  const [isMenuOpen, setIsMenuOpen] = useState<boolean>(false);

  const activeLayer = useMemo(() => {
    return MAP_LAYERS.find((l) => l.id === currentLayerId) || MAP_LAYERS[0];
  }, [currentLayerId]);

  const initialCenter: [number, number] = position ? [position.lat, position.lng] : [35.3606, 138.7274];

  const sectorPositions = useMemo(() => {
    if (!position || hoveredAzimuth === null) return null;
    return createSectorPoints(position.lat, position.lng, hoveredAzimuth);
  }, [position, hoveredAzimuth]);

  return (
    <div className="relative w-full h-full">
      <div className="absolute top-4 right-4 z-[1000]">
        <div className="relative">
          <button
            onClick={() => setIsMenuOpen(!isMenuOpen)}
            className="flex items-center gap-2 bg-slate-900/90 hover:bg-slate-800 text-white px-3.5 py-2.5 rounded-xl shadow-xl border border-slate-700 backdrop-blur-md transition-all cursor-pointer font-medium text-sm"
            aria-label="Switch Map Layer"
          >
            <Layers className="w-4 h-4 text-orange-500" />
            <span className="hidden md:inline">{activeLayer.name}</span>
          </button>

          {isMenuOpen && (
            <div className="absolute right-0 mt-2 w-48 bg-slate-900 border border-slate-700 rounded-xl shadow-2xl overflow-hidden py-1.5 backdrop-blur-md">
              <div className="px-3 py-1 text-[10px] font-bold text-slate-400 uppercase tracking-wider border-b border-slate-800 mb-1">
                Select Map Type
              </div>
              {MAP_LAYERS.map((layer) => (
                <button
                  key={layer.id}
                  onClick={() => {
                    setCurrentLayerId(layer.id);
                    setIsMenuOpen(false);
                  }}
                  className={`w-full text-left px-3.5 py-2 text-sm transition-colors flex items-center justify-between cursor-pointer ${
                    currentLayerId === layer.id
                      ? 'bg-orange-600/20 text-orange-400 font-semibold'
                      : 'text-slate-300 hover:bg-slate-800 hover:text-white'
                  }`}
                >
                  {layer.name}
                  {currentLayerId === layer.id && <span className="w-1.5 h-1.5 rounded-full bg-orange-500" />}
                </button>
              ))}
            </div>
          )}
        </div>
      </div>

      <MapContainer 
        center={initialCenter} 
        zoom={11} 
        className="w-full h-full"
        zoomControl={false}
      >
        <TileLayer
          key={activeLayer.id}
          attribution={activeLayer.attribution}
          url={activeLayer.url}
          maxZoom={19}
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
    </div>
  );
};