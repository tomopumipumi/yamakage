import { Check, Copy, Image as ImageIcon, Loader2, Share2, X } from 'lucide-react';
import type React from 'react';

import { BaseDialog } from '../../../components/ui/BaseDialog';
import { useUiStore } from '../../../store/uiStore';
import { useShare } from '../hooks/useShare';
import { ShareImageCard } from './ShareImageCard';

export const ShareDialog: React.FC = () => {
  const { isShareOpen, setShareOpen } = useUiStore();

  const {
    t,
    isCalculated,
    cardProps,
    activeFormat,
    setActiveFormat,
    shareContent,
    previewContainerRef,
    previewScale,
    isGenerating,
    isCopied,
    handleCopy,
    handleShareX,
    handleShareImage,
  } = useShare();

  return (
    <BaseDialog
      isOpen={isShareOpen}
      onClose={() => setShareOpen(false)}
      title={t('share.title')}
      icon={<Share2 className="w-5 h-5 text-blue-400" />}
      maxWidth="max-w-xl"
    >
      {cardProps && isShareOpen && (
        <div className="fixed top-[200vh] left-[200vw] pointer-events-none">
          <div id="capture-target">
            <ShareImageCard {...cardProps} />
          </div>
        </div>
      )}

      <div className="space-y-4">
        {!isCalculated ? (
          <div className="text-center py-10 text-slate-400">{t('share.not_calculated')}</div>
        ) : (
          <>
            <div className="flex bg-slate-800 rounded-lg p-1 border border-slate-700">
              {(['image', 'text', 'json'] as const).map((fmt) => (
                <button
                  key={fmt}
                  type="button"
                  onClick={() => setActiveFormat(fmt)}
                  className={`flex-1 py-2 text-sm font-bold rounded-md transition-all cursor-pointer ${
                    activeFormat === fmt
                      ? 'bg-slate-700 text-white shadow'
                      : 'text-slate-400 hover:text-slate-200'
                  }`}
                >
                  {t(`share.format_${fmt}`, fmt.toUpperCase())}
                </button>
              ))}
            </div>

            {activeFormat === 'image' && cardProps ? (
              <div
                ref={previewContainerRef}
                className="w-full aspect-[1200/630] bg-slate-900 rounded-xl border border-slate-700 relative overflow-hidden"
              >
                <div
                  className="absolute top-0 left-0 origin-top-left pointer-events-none"
                  style={{ transform: `scale(${previewScale})` }}
                >
                  <ShareImageCard {...cardProps} />
                </div>
              </div>
            ) : (
              <textarea
                readOnly
                value={shareContent}
                className="w-full h-48 bg-slate-950 text-slate-300 rounded-xl p-4 border border-slate-700 font-mono text-sm resize-none focus:outline-none"
              />
            )}

            <div className="flex gap-3">
              {activeFormat === 'image' ? (
                <button
                  type="button"
                  onClick={handleShareImage}
                  disabled={isGenerating}
                  className="flex-1 py-3 px-4 bg-blue-600 hover:bg-blue-500 text-white rounded-lg font-bold transition-colors flex items-center justify-center gap-2 cursor-pointer disabled:opacity-50"
                >
                  {isGenerating ? (
                    <Loader2 className="w-5 h-5 animate-spin" />
                  ) : (
                    <ImageIcon className="w-5 h-5" />
                  )}
                  {isGenerating ? t('share.generating') : t('share.save_image')}
                </button>
              ) : (
                <>
                  <button
                    type="button"
                    onClick={handleCopy}
                    className="flex-1 py-3 px-4 bg-slate-800 hover:bg-slate-700 border border-slate-600 text-white rounded-lg font-bold transition-colors flex items-center justify-center gap-2 cursor-pointer"
                  >
                    {isCopied ? (
                      <Check className="w-5 h-5 text-emerald-400" />
                    ) : (
                      <Copy className="w-5 h-5" />
                    )}
                    {isCopied ? t('share.copied') : t('share.copy_button')}
                  </button>
                  {activeFormat === 'text' && (
                    <button
                      type="button"
                      onClick={handleShareX}
                      className="flex-1 py-3 px-4 bg-blue-600 hover:bg-blue-500 text-white rounded-lg font-bold transition-colors flex items-center justify-center gap-2 cursor-pointer"
                    >
                      <X className="w-5 h-5 fill-current" /> {t('share.share_x')}
                    </button>
                  )}
                </>
              )}
            </div>
          </>
        )}
      </div>
    </BaseDialog>
  );
};
