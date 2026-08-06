import React from 'react';

const BASE_STYLE = "w-full py-3 px-4 rounded-lg font-bold transition-all disabled:opacity-50 disabled:cursor-not-allowed flex justify-center items-center gap-2 cursor-pointer";
const PRIMARY_STYLE="bg-blue-600 hover:bg-blue-500 text-white shadow-lg";
const SECONDARY_STYLE="bg-slate-700 hover:bg-slate-600 text-white";

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary';
  isLoading?: boolean;
}

export const Button: React.FC<ButtonProps> = ({ 
  children, 
  variant = 'primary', 
  isLoading, 
  className = '',
  ...props 
}) => {
  
  const variants = {
    primary: PRIMARY_STYLE,
    secondary:SECONDARY_STYLE
  };

  return (
    <button className={`${BASE_STYLE} ${variants[variant]} ${className}`} disabled={isLoading || props.disabled} {...props}>
      {isLoading ? (
        <span className="animate-spin h-5 w-5 border-2 border-white border-t-transparent rounded-full" />
      ) : children}
    </button>
  );
};