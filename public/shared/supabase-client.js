// ─── Supabase Frontend Client ─────────────────────────────────────────────────
// Wraps the Supabase JS SDK (loaded via CDN) for use across all pages.

let _client = null;

export function getSupabaseClient() {
  if (_client) return _client;
  const url = window.SUPABASE_URL;
  const key = window.SUPABASE_ANON_KEY;
  if (!url || url.startsWith("REPLACE")) {
    console.error("Supabase not configured. Edit public/_env.js with your project URL and anon key.");
    return null;
  }
  _client = window.supabase.createClient(url, key);
  return _client;
}

/**
 * Subscribe to real-time events for a hunt.
 * @param {string} huntId
 * @param {function} onUpdate  — called with the payload object on every update
 * @returns channel (call .unsubscribe() to clean up)
 */
export function subscribeToHunt(huntId, onUpdate) {
  const sb = getSupabaseClient();
  if (!sb) return null;

  const channel = sb
    .channel(`hunt:${huntId}`)
    .on("broadcast", { event: "update" }, ({ payload }) => onUpdate(payload))
    .subscribe();

  return channel;
}
