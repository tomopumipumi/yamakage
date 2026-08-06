import type { LucideIcon } from "lucide-react";

interface IconButtonProps {
    Icon:LucideIcon;
    onClick: ()=> void;
    ariaLabel:string;
}

export const IconButton = ({Icon,onClick,ariaLabel}:IconButtonProps) =>{
    return (
        <button 
            onClick={() => onClick()}
            className="p-2 bg-white/10 hover:bg-white/20 rounded-full transition-colors cursor-pointer"
            aria-label={ariaLabel}
        >
            <Icon className="w-5 h-5 text-white" />
        </button>
    )
} 