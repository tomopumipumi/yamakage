import type { LucideIcon } from 'lucide-react';
import type React from 'react';

interface IconButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  Icon: LucideIcon;
  ariaLabel: string;
}

export const IconButton: React.FC<IconButtonProps> = ({
  Icon,
  ariaLabel,
  className = '',
  ...props
}) => {
  return (
    <button
      className={`p-2 bg-white/10 hover:bg-white/20 rounded-full transition-colors cursor-pointer flex items-center justify-center ${className}`}
      aria-label={ariaLabel}
      {...props}
    >
      <Icon className="w-5 h-5 text-white" />
    </button>
  );
};
