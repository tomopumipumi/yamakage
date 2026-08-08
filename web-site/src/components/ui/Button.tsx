import React from 'react';

type ButtonVariant = 'primary' | 'secondary';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  isLoading?: boolean;
}

const VARIANTS: Record<ButtonVariant, string> = {
  primary: "bg-blue-600 hover:bg-blue-500 text-white shadow-lg",
  secondary: "bg-slate-700 hover:bg-slate-600 text-white"
};

export const Button: React.FC<ButtonProps> = ({ 
  children, 
  variant = 'primary', 
  isLoading, 
  className = '',
  disabled,
  ...props 
}) => {
  return (
    <button 
      className={`w-full py-3 px-4 rounded-lg font-bold transition-all disabled:opacity-50 disabled:cursor-not-allowed flex justify-center items-center gap-2 cursor-pointer ${VARIANTS[variant]} ${className}`}
      disabled={isLoading || disabled} 
      {...props}
    >
      {isLoading ? (
        <span className="animate-spin h-5 w-5 border-2 border-white border-t-transparent rounded-full" />
      ) : children}
    </button>
  );
};