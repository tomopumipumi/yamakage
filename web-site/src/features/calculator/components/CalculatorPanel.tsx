import React, { useEffect, useRef } from 'react';
import { useCalculatorStore } from '../store/calculatorStore';
import { type TurnstileInstance } from '@marsidev/react-turnstile';
import { usePanelDrag } from '../hooks/usePanelDrag';
import { CalculatorHeader } from './CalculatorHeader';
import { CalculatorForm } from './CalculatorForm';
import { CalculatorResults } from './CalculatorResults';

export const CalculatorPanel: React.FC = () => {
  const { 
    calculate, setTurnstileToken, turnstileToken, sunsetTime, isLoading 
  } = useCalculatorStore();

  const turnstileRef = useRef<TurnstileInstance>(null);
  const { isMobile, isMinimized, setIsMinimized, isDragging, currentTranslateY, handlers } = usePanelDrag();

  const handleCalculate = async () => {
    await calculate();
    turnstileRef.current?.reset();
    setTurnstileToken(null);
  };

  useEffect(() => {
    const urlParams = new URLSearchParams(window.location.search);
    if (turnstileToken && urlParams.has('lat') && urlParams.has('lon') && !sunsetTime && !isLoading) {
      calculate();
    }
  }, [turnstileToken, calculate, sunsetTime, isLoading]);

  return (
    <div 
      className={`absolute z-50 flex flex-col bg-slate-900/95 backdrop-blur-md shadow-2xl border border-slate-700/50 overflow-hidden 
        bottom-0 left-0 w-full max-h-[65vh] rounded-t-3xl border-b-0
        md:top-4 md:bottom-auto md:left-4 md:w-96 md:max-h-[calc(100vh-2rem)] md:rounded-2xl md:border-b
        ${!isDragging ? 'transition-transform duration-300' : ''}
      `}
      style={{
        transform: isMobile ? `translateY(${currentTranslateY})` : 'none'
      }}
    >
      <CalculatorHeader 
        handlers={handlers} 
        onClickBg={() => {
          if (isMinimized) setIsMinimized(false);
        }} 
      />

      <div className="flex-1 overflow-y-auto p-5 md:p-6 space-y-5 md:space-y-6">
        <CalculatorForm 
          turnstileRef={turnstileRef} 
          onCalculate={handleCalculate} 
        />
        <CalculatorResults />
      </div>
    </div>
  );
};