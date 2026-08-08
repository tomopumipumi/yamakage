import React from 'react';
import { X } from 'lucide-react';
import { useTranslation } from 'react-i18next';

interface BaseDialogProps {
  isOpen: boolean;
  onClose: () => void;
  title: React.ReactNode;
  icon?: React.ReactNode;
  children: React.ReactNode;
  maxWidth?: string;
  footer?: React.ReactNode;
}

export const BaseDialog = ({
  isOpen,
  onClose,
  title,
  icon,
  children,
  maxWidth = 'max-w-md',
  footer
}:BaseDialogProps) => {
  const { t } = useTranslation();

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-[99999] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm transition-opacity">
      <div className={`bg-slate-900 border border-slate-700 rounded-2xl w-full ${maxWidth} max-h-[85vh] flex flex-col shadow-2xl animate-in zoom-in-95 duration-200`}>
        
        <div className="shrink-0 flex items-center justify-between p-4 border-b border-slate-800">
          <h2 className="text-lg font-bold text-white flex items-center gap-2">
            {icon}
            {title}
          </h2>
          <button onClick={onClose} className="text-slate-400 hover:text-white transition-colors">
            <X className="w-5 h-5 cursor-pointer" />
          </button>
        </div>
        
        <div className="flex-1 overflow-y-auto p-5 md:p-6">
          {children}
        </div>

        <div className="shrink-0 p-4 border-t border-slate-800 bg-slate-800/50 flex justify-end rounded-b-2xl">
          {footer ? footer : (
            <button 
              onClick={onClose}
              className="px-5 py-2 bg-slate-700 hover:bg-slate-600 text-white rounded-lg font-bold transition-colors shadow-lg cursor-pointer"
            >
              {t('close')}
            </button>
          )}
        </div>

      </div>
    </div>
  );
};