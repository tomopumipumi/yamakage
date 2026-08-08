import { useEffect, useRef, useState } from 'react';

export const usePanelDrag = () => {
  const [isMobile, setIsMobile] = useState(
    typeof window !== 'undefined' ? window.innerWidth < 768 : true,
  );
  const [isMinimized, setIsMinimized] = useState(false);
  const [dragY, setDragY] = useState(0);
  const touchStartRef = useRef<{ y: number; isMinimized: boolean } | null>(null);

  useEffect(() => {
    const handleResize = () => setIsMobile(window.innerWidth < 768);
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  const handleTouchStart = (e: React.TouchEvent) => {
    if (!isMobile) return;
    touchStartRef.current = { y: e.touches[0].clientY, isMinimized };
  };

  const handleTouchMove = (e: React.TouchEvent) => {
    if (!touchStartRef.current) return;
    const deltaY = e.touches[0].clientY - touchStartRef.current.y;

    if (!touchStartRef.current.isMinimized && deltaY > 0) {
      setDragY(deltaY);
    } else if (touchStartRef.current.isMinimized && deltaY < 0) {
      setDragY(deltaY);
    }
  };

  const handleTouchEnd = () => {
    if (!touchStartRef.current) return;

    if (!isMinimized && dragY > 50) {
      setIsMinimized(true);
    } else if (isMinimized && dragY < -50) {
      setIsMinimized(false);
    }

    setDragY(0);
    touchStartRef.current = null;
  };

  const currentTranslateY = isMinimized ? `calc(100% - 120px + ${dragY}px)` : `${dragY}px`;

  return {
    isMobile,
    isMinimized,
    setIsMinimized,
    isDragging: touchStartRef.current !== null,
    currentTranslateY,
    handlers: {
      onTouchStart: handleTouchStart,
      onTouchMove: handleTouchMove,
      onTouchEnd: handleTouchEnd,
    },
  };
};
