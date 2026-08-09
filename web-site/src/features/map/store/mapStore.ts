import { create } from 'zustand';
import { useCalculatorStore } from '../../calculator/store/calculatorStore';

export const MapLayerType = {
  OSM: 'osm',
  SATELLITE: 'satellite',
  DARK: 'dark',
} as const;

export interface MapLayerOption {
  id: string;
  name: string;
  url: string;
  attribution: string;
}

export interface Position {
  lat: number;
  lng: number;
}

export const MAP_LAYERS: MapLayerOption[] = [
  {
    id: MapLayerType.OSM,
    name: 'Standard',
    url: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    attribution:
      '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
  },
  {
    id: MapLayerType.SATELLITE,
    name: 'Satellite',
    url: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    attribution:
      'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community',
  },
  {
    id: MapLayerType.DARK,
    name: 'Dark Mode',
    url: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
    attribution:
      '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>',
  },
];

interface MapState {
  currentLayerId: string;
  isMenuOpen: boolean;
  currentLayer: MapLayerOption;

  getPosition: () => Position | null;

  setCurrentLayerId: (id: string) => void;
  setIsMenuOpen: (isOpen: boolean) => void;
}

export const useMapStore = create<MapState>((set, _get) => ({
  currentLayerId: MapLayerType.OSM,
  isMenuOpen: false,
  currentLayer: MAP_LAYERS[0],

  getPosition: () => useCalculatorStore.getState().position,

  setCurrentLayerId: (id) => {
    const activeLayer = MAP_LAYERS.find((l) => l.id === id) || MAP_LAYERS[0];
    set({
      currentLayerId: id,
      currentLayer: activeLayer,
    });
  },

  setIsMenuOpen: (isOpen) => {
    set({ isMenuOpen: isOpen });
  },
}));
