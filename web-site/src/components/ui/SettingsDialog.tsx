import React from 'react';
import { X, Globe2 } from 'lucide-react';
import { useTranslation } from 'react-i18next';
import { useUiStore } from '../../store/uiStore';

export const SettingsDialog: React.FC = () => {
  const { t, i18n } = useTranslation();
  const { isSettingsOpen, setSettingsOpen } = useUiStore();

  if (!isSettingsOpen) return null;

  const currentLang = i18n.language?.startsWith('ja') ? 'ja' : 'en';

  return (
    <div className="fixed inset-0 z-[99999] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm transition-opacity">
      <div className="bg-slate-900 border border-slate-700 rounded-2xl w-full max-w-sm shadow-2xl overflow-hidden animate-in zoom-in-95 duration-200">
        
        <div className="flex items-center justify-between p-4 border-b border-slate-800">
          <h2 className="text-lg font-bold text-white flex items-center gap-2">
            <Globe2 className="w-5 h-5 text-orange-500" />
            {t('settings')}
          </h2>
          <button onClick={() => setSettingsOpen(false)} className="text-slate-400 hover:text-white transition-colors">
            <X className="w-5 h-5" />
          </button>
        </div>
        
        <div className="p-6 space-y-4">
          <div className="space-y-2">
            <label className="text-sm text-slate-400 font-medium">{t('language')}</label>
            <div className="relative">
              <select
                value={currentLang}
                onChange={(e) => i18n.changeLanguage(e.target.value)}
                className="w-full bg-slate-800 text-white rounded-lg p-3 border border-slate-700 focus:outline-none focus:border-orange-500 transition-colors appearance-none cursor-pointer"
              >
                <option value="ja">日本語</option>
                <option value="en">English</option>
              </select>
            </div>
          </div>
        </div>

        <div className="p-4 border-t border-slate-800 bg-slate-800/50 flex justify-end">
          <button 
            onClick={() => setSettingsOpen(false)}
            className="px-5 py-2 bg-slate-700 hover:bg-slate-600 text-white rounded-lg font-bold transition-colors shadow-lg cursor-pointer"
          >
            {t('close')}
          </button>
        </div>

      </div>
    </div>
  );
};