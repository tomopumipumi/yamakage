import React from 'react';
import { Info } from 'lucide-react';
import { useTranslation } from 'react-i18next';
import { useUiStore } from '../../store/uiStore';
import { BaseDialog } from './BaseDialog';

export const AboutDialog: React.FC = () => {
  const { t } = useTranslation();
  const { isAboutOpen, setAboutOpen } = useUiStore();

  const steps = ['1', '2', '3', '4', '5'];

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
            <h3 className="text-lg font-bold text-orange-400">
              {t(`about.steps.${step}.title`)}
            </h3>
            <p className="text-slate-300 leading-relaxed text-sm md:text-base">
              {t(`about.steps.${step}.desc`)}
            </p>
          </div>
        ))}
      </div>
    </BaseDialog>
  );
};