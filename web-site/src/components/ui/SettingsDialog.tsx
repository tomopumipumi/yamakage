import { Globe2 } from 'lucide-react';
import type React from 'react';
import { useTranslation } from 'react-i18next';
import { useUiStore } from '../../store/uiStore';
import { BaseDialog } from './BaseDialog';

export const SettingsDialog: React.FC = () => {
  const { t, i18n } = useTranslation();
  const { isSettingsOpen, setSettingsOpen } = useUiStore();

  const currentLang = i18n.language?.startsWith('ja') ? 'ja' : 'en';

  return (
    <BaseDialog
      isOpen={isSettingsOpen}
      onClose={() => setSettingsOpen(false)}
      title={t('settings')}
      icon={<Globe2 className="w-5 h-5 text-orange-500" />}
      maxWidth="max-w-sm"
    >
      <div className="space-y-2">
        <label htmlFor="lang-select" className="text-sm text-slate-400 font-medium">
          {t('language')}
        </label>
        <div className="relative">
          <select
            id="lang-select"
            value={currentLang}
            onChange={(e) => i18n.changeLanguage(e.target.value)}
            className="w-full bg-slate-800 text-white rounded-lg p-3 border border-slate-700 focus:outline-none focus:border-orange-500 transition-colors appearance-none cursor-pointer"
          >
            <option value="ja">日本語</option>
            <option value="en">English</option>
          </select>
        </div>
      </div>
    </BaseDialog>
  );
};
