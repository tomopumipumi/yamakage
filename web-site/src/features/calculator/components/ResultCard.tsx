import React from 'react';
import { format, toZonedTime } from 'date-fns-tz';

interface Props {
  icon: React.ReactNode;
  label: string;
  timestamp: number | null;
  color: string;
  timezone: string;
}

export const ResultCard: React.FC<Props> = ({ icon, label, timestamp, color, timezone }) => {
  let timeString = '--:--';

  if (timestamp) {
    const date = new Date(timestamp * 1000);
    const zonedDate = toZonedTime(date, timezone);
    timeString = format(zonedDate, 'HH:mm', { timeZone: timezone });
  }

  return (
    <div className="bg-slate-800/80 rounded-xl p-4 flex items-center justify-between border border-slate-700">
      <div className="flex items-center gap-3">
        <div className={`p-2 rounded-lg ${color} bg-opacity-20`}>
          {icon}
        </div>
        <span className="text-slate-300 font-medium">{label}</span>
      </div>
      <span className="text-2xl font-bold text-white">{timeString}</span>
    </div>
  );
};