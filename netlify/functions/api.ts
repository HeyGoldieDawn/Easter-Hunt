import type { Handler, HandlerEvent, HandlerResponse } from "@netlify/functions";
import { getAdminClient } from "./_shared/supabase";
import { broadcastToHunt } from "./_shared/broadcast";
import {
  startHunt, getPlayerState, advanceToClue, advanceFromClue,
  getLeaderboard, generateJoinCode,
} from "./_shared/engine";
import { checkAnswer } from "./_shared/questions";
import type { Hunt, Player } from "./_shared/types";

// ─── Helpers ─────────────────────────────────────────────────────────────────

function json(body: object, status = 200): HandlerResponse {
  return {
    statusCode: status,
    headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
    body: JSON.stringify(body),
  };
}

function err(message: string, status = 400): HandlerResponse {
  return json({ error: message }, status);
}

function cors(): HandlerResponse {
  return {
    statusCode: 204,
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Headers": "Content-Type, X-Admin-Token, X-Session-Token",
      "Access-Control-Allow-Methods": "GET, POST, DELETE, OPTIONS",
    },
    body: "",
  };
}

// ─── Main Handler ─────────────────────────────────────────────────────────────

export const handler: Handler = async (event: HandlerEvent) => {
  if (event.httpMethod === "OPTIONS") return cors();

  const db = getAdminClient();

  // Strip the Netlify function prefix to get the logical path
  // /api/admin/hunts → event.path is /.netlify/functions/api/admin/hunts (via redirect)
  // but the :splat redirect gives us the part after /api/
  const rawPath = event.path;
  // Normalize: could be /api/admin/hunts or /.netlify/functions/api/admin/hunts
  const path = "/" + rawPath.replace(/^\/.netlify\/functions\/api/, "").replace(/^\/api/, "").replace(/^\//, "");
  const method = event.httpMethod;

  const body = event.body ? JSON.parse(event.body) : {};
  const adminToken = event.headers["x-admin-token"] ?? "";
  const sessionToken = event.headers["x-session-token"] ?? "";

  // ── ADMIN ROUTES ──────────────────────────────────────────────────────────

  // POST /admin/hunts — create a new hunt
  if (method === "POST" && path === "/admin/hunts") {
    const { name, numRounds, topics, mode, playerAge, clues } = body;
    if (!name || !topics?.length || !clues?.length) return err("Missing required fields");
    if (numRounds < 1 || numRounds > 15) return err("numRounds must be 1–15");
    if (clues.length < numRounds) return err("Need a clue for every round");

    // Generate unique join code
    let joinCode = generateJoinCode();
    for (let attempts = 0; attempts < 10; attempts++) {
      const { data } = await db.from("hunts").select("id").eq("join_code", joinCode).maybeSingle();
      if (!data) break;
      joinCode = generateJoinCode();
    }

    const adminTok = crypto.randomUUID();

    const { data: hunt, error } = await db
      .from("hunts")
      .insert({
        name,
        join_code: joinCode,
        admin_token: adminTok,
        total_rounds: numRounds,
        topics: JSON.stringify(topics),
        mode: mode ?? "multi",
        age_group: playerAge ?? "teen",
        status: "lobby",
      })
      .select()
      .single();

    if (error || !hunt) return err(error?.message ?? "Failed to create hunt", 500);

    // Insert clues
    const clueRows = clues.slice(0, numRounds).map((text: string, i: number) => ({
      hunt_id: hunt.id,
      round_number: i + 1,
      text,
    }));
    await db.from("clues").insert(clueRows);

    return json({ huntId: hunt.id, joinCode, adminToken: adminTok });
  }

  // GET /admin/hunts/:huntId — get hunt + players
  const getHuntMatch = path.match(/^\/admin\/hunts\/([^/]+)$/);
  if (method === "GET" && getHuntMatch) {
    const huntId = getHuntMatch[1];
    const { data: hunt } = await db.from("hunts").select("*").eq("id", huntId).eq("admin_token", adminToken).single();
    if (!hunt) return err("Unauthorized", 401);
    const { data: players } = await db.from("players").select("id, name, gift, current_round, current_phase, finished_at, finish_rank").eq("hunt_id", huntId);
    return json({ hunt, players: players ?? [] });
  }

  // POST /admin/hunts/:huntId/players — add a player
  const addPlayerMatch = path.match(/^\/admin\/hunts\/([^/]+)\/players$/);
  if (method === "POST" && addPlayerMatch) {
    const huntId = addPlayerMatch[1];
    const { data: hunt } = await db.from("hunts").select("*").eq("id", huntId).eq("admin_token", adminToken).single();
    if (!hunt) return err("Unauthorized", 401);
    if (hunt.status !== "lobby") return err("Hunt already started");
    const { name, gift } = body;
    if (!name) return err("name is required");
    const { data: player, error } = await db
      .from("players")
      .insert({ hunt_id: huntId, name, gift: gift ?? "A surprise gift! 🎁", current_round: 0, current_phase: "waiting" })
      .select()
      .single();
    if (error || !player) return err(error?.message ?? "Failed to add player", 500);
    return json({ playerId: player.id, sessionToken: player.session_token });
  }

  // DELETE /admin/hunts/:huntId/players/:playerId
  const deletePlayerMatch = path.match(/^\/admin\/hunts\/([^/]+)\/players\/([^/]+)$/);
  if (method === "DELETE" && deletePlayerMatch) {
    const huntId = deletePlayerMatch[1];
    const playerId = deletePlayerMatch[2];
    const { data: hunt } = await db.from("hunts").select("status, admin_token").eq("id", huntId).eq("admin_token", adminToken).single();
    if (!hunt) return err("Unauthorized", 401);
    if (hunt.status !== "lobby") return err("Hunt already started");
    await db.from("players").delete().eq("id", playerId).eq("hunt_id", huntId);
    return json({ ok: true });
  }

  // POST /admin/hunts/:huntId/start
  const startMatch = path.match(/^\/admin\/hunts\/([^/]+)\/start$/);
  if (method === "POST" && startMatch) {
    const huntId = startMatch[1];
    const { data: hunt } = await db.from("hunts").select("*").eq("id", huntId).eq("admin_token", adminToken).single();
    if (!hunt) return err("Unauthorized", 401);
    if (hunt.status !== "lobby") return err("Hunt already started or not in lobby");

    const { count } = await db.from("players").select("id", { count: "exact", head: true }).eq("hunt_id", huntId);
    if (!count || count === 0) return err("Add at least one player before starting");

    try {
      await startHunt(db, hunt as Hunt);
    } catch (e) {
      return err((e as Error).message, 500);
    }

    await broadcastToHunt(huntId, { event: "hunt_started", data: { startedAt: Date.now() } });
    return json({ ok: true });
  }

  // GET /admin/hunts/:huntId/leaderboard
  const lbMatch = path.match(/^\/admin\/hunts\/([^/]+)\/leaderboard$/);
  if (method === "GET" && lbMatch) {
    const huntId = lbMatch[1];
    const { data: hunt } = await db.from("hunts").select("admin_token").eq("id", huntId).eq("admin_token", adminToken).single();
    if (!hunt) return err("Unauthorized", 401);
    const players = await getLeaderboard(db, huntId);
    return json({ players });
  }

  // ── GAME ROUTES ───────────────────────────────────────────────────────────

  // POST /game/join
  if (method === "POST" && path === "/game/join") {
    const { joinCode, playerName } = body;
    if (!joinCode || !playerName) return err("joinCode and playerName are required");

    const { data: hunt } = await db.from("hunts").select("*").eq("join_code", joinCode.toUpperCase()).single();
    if (!hunt) return err("Hunt not found", 404);
    if (hunt.status === "finished") return err("This hunt has already finished");

    // Single player: find pre-created player by name (allowed even when hunt is active)
    if (hunt.mode === "single") {
      const { data: existing } = await db
        .from("players")
        .select("*")
        .eq("hunt_id", hunt.id)
        .ilike("name", playerName)
        .single();
      if (!existing) return err("Player name not found. Ask the organiser to add you.", 404);
      return json({
        playerId: existing.id, sessionToken: existing.session_token,
        huntId: hunt.id, playerName: existing.name, huntName: hunt.name, huntMode: hunt.mode,
      });
    }

    // Multi: self-join (block if already started)
    if (hunt.status === "active") return err("This hunt has already started");
    const { data: player, error } = await db
      .from("players")
      .insert({ hunt_id: hunt.id, name: playerName, gift: "", current_round: 0, current_phase: "waiting" })
      .select()
      .single();

    if (error || !player) return err(error?.message ?? "Failed to join", 500);

    const { count: totalPlayers } = await db
      .from("players")
      .select("id", { count: "exact", head: true })
      .eq("hunt_id", hunt.id);

    await broadcastToHunt(hunt.id, { event: "player_joined", data: { name: playerName, totalPlayers } });

    return json({
      playerId: player.id, sessionToken: player.session_token,
      huntId: hunt.id, playerName: player.name, huntName: hunt.name, huntMode: hunt.mode,
    });
  }

  // GET /game/state
  if (method === "GET" && path === "/game/state") {
    if (!sessionToken) return err("Unauthorized", 401);
    const { data: player } = await db.from("players").select("*").eq("session_token", sessionToken).single();
    if (!player) return err("Unauthorized", 401);
    const state = await getPlayerState(db, player as Player);
    return json(state);
  }

  // POST /game/answer
  if (method === "POST" && path === "/game/answer") {
    if (!sessionToken) return err("Unauthorized", 401);
    const { data: player } = await db.from("players").select("*").eq("session_token", sessionToken).single() as { data: Player | null };
    if (!player) return err("Unauthorized", 401);
    if (player.current_phase !== "trivia") return err("Not in trivia phase");
    if (player.current_round === 0) return err("Hunt not started yet");

    const { answer } = body;
    const { data: roundRow } = await db
      .from("player_rounds")
      .select("question_id")
      .eq("player_id", player.id)
      .eq("round_number", player.current_round)
      .single();

    if (!roundRow?.question_id) return err("Round not found", 500);

    const correct = await checkAnswer(db, roundRow.question_id, answer);

    if (correct) {
      await advanceToClue(db, player);
      const lb = await getLeaderboard(db, player.hunt_id);
      await broadcastToHunt(player.hunt_id, { event: "leaderboard", data: { players: lb } });
      return json({ correct: true, nextPhase: "clue" });
    } else {
      return json({ correct: false });
    }
  }

  // POST /game/found-clue
  if (method === "POST" && path === "/game/found-clue") {
    if (!sessionToken) return err("Unauthorized", 401);
    const { data: player } = await db.from("players").select("*").eq("session_token", sessionToken).single() as { data: Player | null };
    if (!player) return err("Unauthorized", 401);
    if (player.current_phase !== "clue") return err("Not in clue phase");

    const result = await advanceFromClue(db, player);
    const lb = await getLeaderboard(db, player.hunt_id);
    await broadcastToHunt(player.hunt_id, { event: "leaderboard", data: { players: lb } });

    if (result.finished) {
      if (result.rank === 1) {
        await broadcastToHunt(player.hunt_id, { event: "winner", data: { name: player.name } });
      } else {
        await broadcastToHunt(player.hunt_id, { event: "player_finished", data: { name: player.name, rank: result.rank } });
      }
    }

    return json(result);
  }

  return err("Not found", 404);
};
