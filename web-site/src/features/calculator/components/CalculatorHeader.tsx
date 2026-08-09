import { Info, Settings, Share2, Watch } from 'lucide-react';
import type React from 'react';
import { useTranslation } from 'react-i18next';
import iconUrl from '../../../assets/icon.svg';
import { IconButton } from '../../../components/ui/IconButton';
import { useUiStore } from '../../../store/uiStore';

interface CalculatorHeaderProps {
  handlers?: {
    onTouchStart: (e: React.TouchEvent) => void;
    onTouchMove: (e: React.TouchEvent) => void;
    onTouchEnd: () => void;
  };
  onClickBg?: () => void;
}

export const CalculatorHeader: React.FC<CalculatorHeaderProps> = ({ handlers, onClickBg }) => {
  const { t } = useTranslation();
  const { setSmartwatchOpen, setAboutOpen, setSettingsOpen, setShareOpen } = useUiStore();

  return (
    <div className="shrink-0 bg-gradient-to-r from-orange-600 to-purple-700 p-5 md:p-6 flex items-center justify-between relative">
      <button
        type="button"
        className="absolute inset-0 md:hidden touch-none z-0 cursor-pointer"
        {...handlers}
        onClick={onClickBg}
      />
      <div className="absolute top-2 left-1/2 -translate-x-1/2 w-12 h-1.5 bg-white/30 rounded-full md:hidden pointer-events-none z-10" />

      <div className="flex items-center gap-3 relative z-20 pointer-events-none">
        <img
          src={iconUrl}
          alt="YAMAKAGE Logo"
          className="w-20 h-20 rounded-full shadow-lg shadow-orange-500/20 object-cover relative z-10"
        />
        <div>
          <h1 className="text-lg md:text-xl font-bold text-white tracking-wider">
            {t('app_title')}
          </h1>
          <p className="text-orange-100 text-[10px] md:text-xs mt-0.5">{t('app_subtitle')}</p>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-1.5 md:gap-2 relative z-20">
        <IconButton
          Icon={Watch}
          onClick={() => setSmartwatchOpen(true)}
          ariaLabel={t('smartwatch.menu_title')}
        />
        <IconButton
          Icon={Share2}
          onClick={() => setShareOpen(true)}
          ariaLabel={t('share.menu_title')}
        />
        <IconButton
          Icon={Info}
          onClick={() => setAboutOpen(true)}
          ariaLabel={t('about.menu_title')}
        />
        <IconButton
          Icon={Settings}
          onClick={() => setSettingsOpen(true)}
          ariaLabel={t('settings')}
        />
      </div>
    </div>
  );
};
