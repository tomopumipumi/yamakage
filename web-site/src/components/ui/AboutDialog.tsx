import React from 'react';
import { X, Info } from 'lucide-react';
import { useTranslation } from 'react-i18next';
import { useUiStore } from '../../store/uiStore';

export const AboutDialog: React.FC = () => {
  const { t } = useTranslation();
  const { isAboutOpen, setAboutOpen } = useUiStore();

  if (!isAboutOpen) return null;

  const steps = ['1', '2', '3', '4', '5'];

  return (
    <div className="fixed inset-0 z-[99999] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm transition-opacity">
      <div className="bg-slate-900 border border-slate-700 rounded-2xl w-full max-w-2xl max-h-[85vh] flex flex-col shadow-2xl animate-in zoom-in-95 duration-200">
        
        <div className="shrink-0 flex items-center justify-between p-4 border-b border-slate-800">
          <h2 className="text-lg font-bold text-white flex items-center gap-2">
            <Info className="w-5 h-5 text-blue-500" />
            {t('about.title')}
          </h2>
          <button onClick={() => setAboutOpen(false)} className="text-slate-400 hover:text-white transition-colors">
            <X className="w-5 h-5 cursor-pointer" />
          </button>
        </div>
        
        <div className="flex-1 overflow-y-auto p-6 space-y-8">
          {steps.map((step) => (
            <div key={step} className="space-y-3">
              <h3 className="text-lg font-bold text-orange-400">
                {t(`about.steps.${step}.title`)}
              </h3>
              
              {/* <div className="w-full h-40 bg-slate-800/50 border border-slate-700 border-dashed rounded-lg flex items-center justify-center text-sm text-slate-500">
                <img src={`/images/step-${step}.png`} alt={`Step ${step}`} className="w-full h-full object-cover rounded-lg" />
              </div> */}
              
              <p className="text-slate-300 leading-relaxed text-sm md:text-base">
                {t(`about.steps.${step}.desc`)}
              </p>
            </div>
          ))}
        </div>

        <div className="shrink-0 p-4 border-t border-slate-800 bg-slate-800/50 flex justify-end">
          <button 
            onClick={() => setAboutOpen(false)}
            className="px-5 py-2 bg-slate-700 hover:bg-slate-600 text-white rounded-lg font-bold transition-colors shadow-lg cursor-pointer"
          >
            {t('close')}
          </button>
        </div>

      </div>
    </div>
  );
};