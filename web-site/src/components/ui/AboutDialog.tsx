import { AlertTriangle, ExternalLink, Info } from 'lucide-react';
import type React from 'react';
import { useTranslation } from 'react-i18next';
import { FaGithub } from 'react-icons/fa';
import { useUiStore } from '../../store/uiStore';
import { BaseDialog } from './BaseDialog';

export const AboutDialog: React.FC = () => {
  const { t } = useTranslation();
  const { isAboutOpen, setAboutOpen } = useUiStore();

  const steps = ['1', '2', '3', '4', '5'];
  const notes = ['altitude', 'flatland_pins', 'reclaimed_land'];

  return (
    <BaseDialog
      isOpen={isAboutOpen}
      onClose={() => setAboutOpen(false)}
      title={t('about.title')}
      icon={<Info className="w-5 h-5 text-blue-500" />}
      maxWidth="max-w-2xl"
    >
      <div className="space-y-8">
        {steps.map((step) => (
          <div key={step} className="space-y-3">
            <h3 className="text-lg font-bold text-orange-400">{t(`about.steps.${step}.title`)}</h3>
            <p className="text-slate-300 leading-relaxed text-sm md:text-base">
              {t(`about.steps.${step}.desc`)}
            </p>
          </div>
        ))}
      </div>

      <div className="mt-10 pt-8 border-t border-slate-700/60">
        <h3 className="text-lg font-bold text-yellow-500 flex items-center gap-2 mb-5">
          <AlertTriangle className="w-5 h-5" />
          {t('about.notes_title')}
        </h3>
        <div className="space-y-4 mb-8">
          {notes.map((note) => (
            <div key={note} className="bg-slate-800/40 rounded-xl p-4 border border-slate-700/50">
              <h4 className="text-sm font-bold text-slate-200 mb-1.5">
                {t(`about.notes.${note}.title`)}
              </h4>
              <p className="text-slate-400 text-sm leading-relaxed">
                {t(`about.notes.${note}.desc`)}
              </p>
            </div>
          ))}
        </div>

        {/* GitHubリンク セクション */}
        <div className="p-4 rounded-xl bg-slate-800/50 border border-slate-700/50 hover:border-slate-600 transition-all flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
          <div className="flex items-center gap-3">
            <div className="p-2 rounded-lg bg-slate-700/50 text-slate-200">
              <FaGithub className="w-5 h-5" />
            </div>
            <div>
              <p className="text-sm font-medium text-slate-200 whitespace-pre-line">
                {t('about.link.title')}
              </p>
              <p className="text-xs text-slate-400 mt-1">Explore the source code and contribute</p>
            </div>
          </div>
          <a
            href={t('about.link.href')}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center justify-center gap-1.5 px-3.5 py-2 rounded-lg bg-blue-600/20 hover:bg-blue-600/30 text-blue-400 text-sm font-medium transition-colors border border-blue-500/20"
          >
            <span>View Repository</span>
            <ExternalLink className="w-4 h-4" />
          </a>
        </div>
      </div>
    </BaseDialog>
  );
};
