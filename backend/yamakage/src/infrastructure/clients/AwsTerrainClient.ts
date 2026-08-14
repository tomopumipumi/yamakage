import { Effect } from 'effect';
import { ElevationFetchError } from '../../application/errors';

export const fetchTileFromAWS = (z: number, x: number, y: number) => {
  const tryLogic = async () => {
    const url = `https://s3.amazonaws.com/elevation-tiles-prod/terrarium/${z}/${x}/${y}.png`;
    const res = await fetch(url);
    if (!res.ok) {
      if (res.status === 404 || res.status === 403) return null;
      throw new Error(`Failed to fetch tile ${z}/${x}/${y}: ${res.status} ${res.statusText}`);
    }
    return await res.arrayBuffer();
  };

  return Effect.tryPromise({
    try: tryLogic,
    catch: (e) => new ElevationFetchError(`AWS fetch failed for tile ${z}/${x}/${y}`, e),
  });
};
