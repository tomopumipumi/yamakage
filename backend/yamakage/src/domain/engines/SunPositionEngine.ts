import * as SunCalc from 'suncalc';
import type { SunPosition } from '../models/types';

export const SunPositionEngine = {
  getPosition: (date: Date, lat: number, lng: number): SunPosition => {
    const position = SunCalc.getPosition(date, lat, lng);

    const altitudeDeg = position.altitude;

    const azimuthDeg = ((position.azimuth % 360) + 360) % 360;

    return {
      altitudeRad: altitudeDeg * (Math.PI / 180),
      azimuthRad: azimuthDeg * (Math.PI / 180),
      altitudeDeg,
      azimuthDeg,
    };
  },
};
