// Broadcasts a message to all subscribers of a hunt channel via Supabase Realtime REST API.
// No persistent WebSocket connection needed — works from serverless functions.

export async function broadcastToHunt(huntId: string, payload: object): Promise<void> {
  const url = process.env.SUPABASE_URL;
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!url || !key) return;

  try {
    await fetch(`${url}/realtime/v1/api/broadcast`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "apikey": key,
        "Authorization": `Bearer ${key}`,
      },
      body: JSON.stringify({
        messages: [
          { topic: `hunt:${huntId}`, event: "update", payload }
        ],
      }),
    });
  } catch {
    // Non-fatal — broadcast failure doesn't break the game
  }
}
