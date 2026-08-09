import { Layers } from 'lucide-react';
import { MAP_LAYERS, type MapLayerOption, useMapStore } from '../store/mapStore';

const MenuButton = () => {
  const { isMenuOpen, setIsMenuOpen, currentLayer } = useMapStore();
  return (
    <button
      type="button"
      onClick={() => setIsMenuOpen(!isMenuOpen)}
      className="flex items-center gap-2 bg-slate-900/90 hover:bg-slate-800 text-white px-3.5 py-2.5 rounded-xl shadow-xl border border-slate-700 backdrop-blur-md transition-all cursor-pointer font-medium text-sm"
      aria-label="Switch Map Layer"
    >
      <Layers className="w-4 h-4 text-orange-500" />
      <span className="hidden md:inline">{currentLayer.name}</span>
    </button>
  );
};

const LayerRow = ({ layer }: { layer: MapLayerOption }) => {
  const { currentLayerId, setCurrentLayerId, setIsMenuOpen } = useMapStore();
  return (
    <button
      type="button"
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
  );
};

export const LayerSelecter = () => {
  const { isMenuOpen } = useMapStore();

  return (
    <div className="absolute top-4 right-4 z-[1000]">
      <div className="relative">
        <MenuButton />

        {isMenuOpen && (
          <div className="absolute right-0 mt-2 w-48 bg-slate-900 border border-slate-700 rounded-xl shadow-2xl overflow-hidden py-1.5 backdrop-blur-md">
            <div className="px-3 py-1 text-[10px] font-bold text-slate-400 uppercase tracking-wider border-b border-slate-800 mb-1">
              Select Map Type
            </div>
            {MAP_LAYERS.map((layer) => (
              <LayerRow key={layer.id} layer={layer} />
            ))}
          </div>
        )}
      </div>
    </div>
  );
};
