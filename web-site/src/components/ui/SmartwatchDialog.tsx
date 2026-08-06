import React from 'react';
import { X, Watch, ExternalLink, Activity } from 'lucide-react';
import { useTranslation } from 'react-i18next';
import { useUiStore } from '../../store/uiStore';

export const SmartwatchDialog: React.FC = () => {
  const { t } = useTranslation();
  const { isSmartwatchOpen, setSmartwatchOpen } = useUiStore();

  if (!isSmartwatchOpen) return null;

  return (
    <div className="fixed inset-0 z-[99999] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm transition-opacity">
      <div className="bg-slate-900 border border-slate-700 rounded-2xl w-full max-w-2xl max-h-[85vh] flex flex-col shadow-2xl animate-in zoom-in-95 duration-200">
        
        <div className="shrink-0 flex items-center justify-between p-4 border-b border-slate-800">
          <h2 className="text-lg font-bold text-white flex items-center gap-2">
            <Watch className="w-5 h-5 text-emerald-400" />
            {t('smartwatch.title')}
          </h2>
          <button onClick={() => setSmartwatchOpen(false)} className="text-slate-400 hover:text-white transition-colors">
            <X className="w-5 h-5 cursor-pointer" />
          </button>
        </div>
        
        <div className="flex-1 overflow-y-auto p-6 space-y-6">
          <p className="text-slate-300 text-sm md:text-base leading-relaxed">
            {t('smartwatch.description')}
          </p>

          <div className="grid gap-4 md:grid-cols-1">
            
            <div className="bg-gradient-to-br from-slate-800 to-slate-900 border border-emerald-500/30 rounded-xl p-5 flex flex-col relative overflow-hidden group">
              <div className="absolute top-0 right-0 w-24 h-24 bg-emerald-500/10 rounded-bl-full -mr-4 -mt-4 transition-transform group-hover:scale-110" />
              <div className="flex items-center gap-3 mb-3 relative z-10">
                <div className="p-2 bg-emerald-500/20 rounded-lg">
                  <Activity className="w-6 h-6 text-emerald-400" />
                </div>
                <h3 className="font-bold text-white text-lg">{t('smartwatch.garmin.title')}</h3>
              </div>
              <p className="text-slate-400 text-sm mb-6 flex-1 relative z-10">
                {t('smartwatch.garmin.desc')}
              </p>
              <a 
                href={t('smartwatch.garmin.url')}
                target="_blank"
                rel="noopener noreferrer"
                className="w-full py-3 px-4 bg-emerald-600 hover:bg-emerald-500 text-white text-sm font-bold rounded-lg transition-colors flex items-center justify-center gap-2 cursor-pointer relative z-10 shadow-lg"
              >
                {t('smartwatch.garmin.button')}
                <ExternalLink className="w-4 h-4" />
              </a>
            </div>

            {/* <div className="bg-slate-800/40 border border-slate-700/50 rounded-xl p-5 flex flex-col opacity-80">
              <div className="flex items-center gap-3 mb-3">
                <div className="p-2 bg-slate-700/50 rounded-lg">
                  <Watch className="w-6 h-6 text-slate-400" />
                </div>
                <h3 className="font-bold text-slate-300 text-lg">{t('smartwatch.others.title')}</h3>
              </div>
              <p className="text-slate-500 text-sm flex-1">
                {t('smartwatch.others.desc')}
              </p>
            </div> */}

          </div>
        </div>

        <div className="shrink-0 p-4 border-t border-slate-800 bg-slate-800/50 flex justify-end">
          <button 
            onClick={() => setSmartwatchOpen(false)}
            className="px-5 py-2 bg-slate-700 hover:bg-slate-600 text-white rounded-lg font-bold transition-colors shadow-lg cursor-pointer"
          >
            {t('close')}
          </button>
        </div>

      </div>
    </div>
  );
};