import { Activity, ExternalLink, Watch } from 'lucide-react';
import type React from 'react';
import { useTranslation } from 'react-i18next';
import { useUiStore } from '../../store/uiStore';
import { BaseDialog } from './BaseDialog';

export const SmartwatchDialog: React.FC = () => {
  const { t } = useTranslation();
  const { isSmartwatchOpen, setSmartwatchOpen } = useUiStore();

  return (
    <BaseDialog
      isOpen={isSmartwatchOpen}
      onClose={() => setSmartwatchOpen(false)}
      title={t('smartwatch.title')}
      icon={<Watch className="w-5 h-5 text-emerald-400" />}
      maxWidth="max-w-2xl"
    >
      <div className="space-y-6">
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
        </div>
      </div>
    </BaseDialog>
  );
};
