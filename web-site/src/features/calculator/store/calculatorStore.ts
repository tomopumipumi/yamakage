import { format } from 'date-fns';
import { fromZonedTime, toZonedTime } from 'date-fns-tz';
import tz_lookup from 'tz-lookup';
import { create } from 'zustand';
import {
  calculateShadow,
  type SunPathPoint,
  type TerrainAzimuthProfile,
} from '../api/calculateShadow';

function detectTimezone(lat: number, lng: number): string {
  try {
    const normalizedLng = ((((lng + 180) % 360) + 360) % 360) - 180;
    return tz_lookup(lat, normalizedLng);
  } catch (_e) {
    return Intl.DateTimeFormat().resolvedOptions().timeZone || 'Asia/Tokyo';
  }
}

function getInitialParams() {
  if (typeof window === 'undefined') {
    return { lat: 35.3606, lng: 138.7274, tz: 'Asia/Tokyo' };
  }

  const urlParams = new URLSearchParams(window.location.search);
  const latStr = urlParams.get('lat');
  const lngStr = urlParams.get('lng');

  const lat = latStr && !Number.isNaN(parseFloat(latStr)) ? parseFloat(latStr) : 35.3606;
  const lng = lngStr && !Number.isNaN(parseFloat(lngStr)) ? parseFloat(lngStr) : 138.7274;

  const tz = urlParams.get('tz') || detectTimezone(lat, lng);

  return { lat, lng, tz };
}

const initialParams = getInitialParams();
const defaultTimezone = Intl.DateTimeFormat().resolvedOptions().timeZone || 'Asia/Tokyo';
const nowZoned = toZonedTime(new Date(), defaultTimezone);
const initialDate = format(nowZoned, "yyyy-MM-dd'T'HH:mm");

interface Position {
  lat: number;
  lng: number;
}

interface CalculatorState {
  position: Position | null;
  targetDate: string;
  timezone: string;
  turnstileToken: string | null;
  isLoading: boolean;
  error: string | null;
  sunsetTime: number | null;
  sunriseTime: number | null;
  isPolar: boolean;
  azimuthProfiles: TerrainAzimuthProfile[];
  sunPath: SunPathPoint[];
  hoveredAzimuth: number | null;

  setPosition: (pos: Position) => void;
  setTargetDate: (date: string) => void;
  setTimezone: (tz: string) => void;
  setTurnstileToken: (token: string | null) => void;
  setHoveredAzimuth: (azimuth: number | null) => void;
  calculate: () => Promise<void>;
}

const RESET_RESULT_STATE = {
  error: null,
  sunsetTime: null,
  sunriseTime: null,
  isPolar: false,
  azimuthProfiles: [],
  sunPath: [],
  hoveredAzimuth: null,
};

export const useCalculatorStore = create<CalculatorState>((set, get) => ({
  position: { lat: initialParams.lat, lng: initialParams.lng },
  targetDate: initialDate,
  timezone: defaultTimezone,
  turnstileToken: null,
  isLoading: false,
  error: null,
  sunsetTime: null,
  sunriseTime: null,
  isPolar: false,
  azimuthProfiles: [],
  sunPath: [],
  hoveredAzimuth: null,

  setPosition: (pos) => {
    const detectedTz = detectTimezone(pos.lat, pos.lng);
    set({
      position: pos,
      timezone: detectedTz,
      ...RESET_RESULT_STATE,
    });
  },

  setTargetDate: (date) =>
    set({
      targetDate: date,
      ...RESET_RESULT_STATE,
    }),

  setTimezone: (tz) =>
    set({
      timezone: tz,
      error: null,
      isPolar: false,
    }),

  setTurnstileToken: (token) => set({ turnstileToken: token }),
  setHoveredAzimuth: (azimuth) => set({ hoveredAzimuth: azimuth }),

  calculate: async () => {
    const { position, targetDate, timezone, turnstileToken } = get();

    if (!position) {
      set({ error: 'error_no_position' });
      return;
    }
    if (!turnstileToken) {
      set({ error: 'error_no_turnstile' });
      return;
    }

    set({ isLoading: true, error: null });
    try {
      const targetUnix = Math.floor(fromZonedTime(targetDate, timezone).getTime() / 1000);
      const normalizedLng = ((((position.lng + 180) % 360) + 360) % 360) - 180;

      const result = await calculateShadow(position.lat, normalizedLng, targetUnix, turnstileToken);

      set({
        sunsetTime: result.sunsetTime,
        sunriseTime: result.sunriseTime,
        isPolar: result.isPolar,
        azimuthProfiles: result.azimuthProfiles || [],
        sunPath: result.sunPath || [],
        isLoading: false,
      });
    } catch (e) {
      console.error('Shadow calculation error:', e);
      set({ error: 'error_calculation_failed', isLoading: false });
    }
  },
}));
