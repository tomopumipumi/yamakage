export const fetchTileFromAWS = async (
  z: number,
  x: number,
  y: number,
): Promise<ArrayBuffer | null> => {
  const url = `https://s3.amazonaws.com/elevation-tiles-prod/terrarium/${z}/${x}/${y}.png`;
  const res = await fetch(url);
  if (!res.ok) {
    if (res.status === 404 || res.status === 403) return null;
    throw new Error(`Failed to fetch tile ${z}/${x}/${y}: ${res.status} ${res.statusText}`);
  }
  return await res.arrayBuffer();
};
