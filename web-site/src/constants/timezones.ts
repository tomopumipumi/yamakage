export interface TimezoneOption {
  value: string;
  labelKey: string;
}

export const TIMEZONE_OPTIONS: TimezoneOption[] = [
  { value: 'UTC', labelKey: 'timezones.utc' },

  { value: 'Asia/Tokyo', labelKey: 'timezones.asia_tokyo' },
  { value: 'Asia/Seoul', labelKey: 'timezones.asia_seoul' },
  { value: 'Asia/Shanghai', labelKey: 'timezones.asia_shanghai' },
  { value: 'Asia/Taipei', labelKey: 'timezones.asia_taipei' },
  { value: 'Asia/Hong_Kong', labelKey: 'timezones.asia_hong_kong' },
  { value: 'Asia/Singapore', labelKey: 'timezones.asia_singapore' },
  { value: 'Asia/Bangkok', labelKey: 'timezones.asia_bangkok' },
  { value: 'Asia/Kolkata', labelKey: 'timezones.asia_kolkata' },
  { value: 'Asia/Dubai', labelKey: 'timezones.asia_dubai' },
  { value: 'Australia/Sydney', labelKey: 'timezones.australia_sydney' },
  { value: 'Australia/Perth', labelKey: 'timezones.australia_perth' },
  { value: 'Pacific/Auckland', labelKey: 'timezones.pacific_auckland' },
  { value: 'Pacific/Honolulu', labelKey: 'timezones.pacific_honolulu' },

  { value: 'Europe/London', labelKey: 'timezones.europe_london' },
  { value: 'Europe/Paris', labelKey: 'timezones.europe_paris' },
  { value: 'Europe/Berlin', labelKey: 'timezones.europe_berlin' },
  { value: 'Europe/Rome', labelKey: 'timezones.europe_rome' },
  { value: 'Europe/Kyiv', labelKey: 'timezones.europe_kyiv' },
  { value: 'Europe/Istanbul', labelKey: 'timezones.europe_istanbul' },
  { value: 'Africa/Cairo', labelKey: 'timezones.africa_cairo' },
  { value: 'Africa/Johannesburg', labelKey: 'timezones.africa_johannesburg' },

  { value: 'America/New_York', labelKey: 'timezones.america_new_york' },
  { value: 'America/Chicago', labelKey: 'timezones.america_chicago' },
  { value: 'America/Denver', labelKey: 'timezones.america_denver' },
  { value: 'America/Los_Angeles', labelKey: 'timezones.america_la' },
  { value: 'America/Anchorage', labelKey: 'timezones.america_anchorage' },
  { value: 'America/Vancouver', labelKey: 'timezones.america_vancouver' },
  { value: 'America/Toronto', labelKey: 'timezones.america_toronto' },
  { value: 'America/Sao_Paulo', labelKey: 'timezones.america_sao_paulo' },
  { value: 'America/Argentina/Buenos_Aires', labelKey: 'timezones.america_buenos_aires' },
];
