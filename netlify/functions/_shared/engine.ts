import type { SupabaseClient } from "@supabase/supabase-js";
import type { Hunt, Player, PlayerState, LeaderboardEntry } from "./types";
import { drawQuestion, questionForClient } from "./questions";

// ─── Assign questions for all players at hunt start ──────────────────────────

export async function assignQuestionsForHunt(db: SupabaseClient, hunt: Hunt): Promise<void> {
  const { data: players } = await db
    .from("players")
    .select("id")
    .eq("hunt_id", hunt.id);

  if (!players || players.length === 0) return;

  const topics: string[] = JSON.parse(hunt.topics);
  const audience = hunt.age_group;

  for (const player of players) {
    const usedIds: number[] = [];
    const rounds = [];

    for (let round = 1; round <= hunt.total_rounds; round++) {
      const q = await drawQuestion(db, topics, audience, usedIds);
      if (!q) {
        throw new Error(
          `Not enough questions in topics [${topics.join(", ")}] for audience '${audience}'. ` +
          `Need ${hunt.total_rounds} unique questions per player.`
        );
      }
      usedIds.push(q.id);
      rounds.push({
        player_id: player.id,
        hunt_id: hunt.id,
        round_number: round,
        question_id: q.id,
      });
    }

    await db.from("player_rounds").insert(rounds);
  }
}

// ─── Get current state for a player ─────────────────────────────────────────

export async function getPlayerState(db: SupabaseClient, player: Player): Promise<PlayerState> {
  const { data: hunt } = await db
    .from("hunts")
    .select("*")
    .eq("id", player.hunt_id)
    .single();

  if (!hunt) throw new Error("Hunt not found");

  const totalRounds = hunt.total_rounds;
  const huntMode = hunt.mode as "single" | "multi";
  const playerAge = hunt.age_group as "child" | "teen";

  if (hunt.status === "lobby" || player.current_round === 0) {
    return { phase: "waiting", round: 0, totalRounds, huntMode, playerAge };
  }

  if (player.current_phase === "finished") {
    return {
      phase: "finished",
      round: totalRounds,
      totalRounds,
      huntMode,
      playerAge,
      gift: player.gift,
      rank: player.finish_rank ?? undefined,
      leaderboard: await getLeaderboard(db, player.hunt_id),
    };
  }

  const phase = player.current_phase as "trivia" | "clue";

  if (phase === "trivia") {
    const { data: roundRow } = await db
      .from("player_rounds")
      .select("question_id")
      .eq("player_id", player.id)
      .eq("round_number", player.current_round)
      .single();

    let question = undefined;
    if (roundRow?.question_id) {
      const { data: q } = await db
        .from("question_bank")
        .select("id, topic, question, option_a, option_b, option_c, option_d")
        .eq("id", roundRow.question_id)
        .single();
      if (q) question = questionForClient(q as any);
    }

    return {
      phase: "trivia",
      round: player.current_round,
      totalRounds,
      huntMode,
      playerAge,
      question,
      leaderboard: huntMode === "multi" ? await getLeaderboard(db, player.hunt_id) : undefined,
    };
  } else {
    const { data: clue } = await db
      .from("clues")
      .select("text")
      .eq("hunt_id", player.hunt_id)
      .eq("round_number", player.current_round)
      .single();

    return {
      phase: "clue",
      round: player.current_round,
      totalRounds,
      huntMode,
      playerAge,
      clue: clue ? { text: clue.text } : undefined,
      leaderboard: huntMode === "multi" ? await getLeaderboard(db, player.hunt_id) : undefined,
    };
  }
}

// ─── Advance player from trivia → clue ──────────────────────────────────────

export async function advanceToClue(db: SupabaseClient, player: Player): Promise<void> {
  await db
    .from("player_rounds")
    .update({ trivia_answered: true, answered_at: Date.now() })
    .eq("player_id", player.id)
    .eq("round_number", player.current_round);

  await db
    .from("players")
    .update({ current_phase: "clue" })
    .eq("id", player.id);
}

// ─── Advance player from clue → next round or finish ────────────────────────

export async function advanceFromClue(
  db: SupabaseClient,
  player: Player
): Promise<{ finished: boolean; rank?: number; gift: string }> {
  const now = Date.now();

  await db
    .from("player_rounds")
    .update({ clue_found: true, found_at: now })
    .eq("player_id", player.id)
    .eq("round_number", player.current_round);

  const { data: hunt } = await db
    .from("hunts")
    .select("total_rounds")
    .eq("id", player.hunt_id)
    .single();

  const totalRounds = hunt?.total_rounds ?? 0;
  const nextRound = player.current_round + 1;

  if (nextRound > totalRounds) {
    const rank = await computeFinishRank(db, player.hunt_id);

    await db
      .from("players")
      .update({ current_phase: "finished", finished_at: now, finish_rank: rank })
      .eq("id", player.id);

    // Check if all players finished
    const { count } = await db
      .from("players")
      .select("id", { count: "exact", head: true })
      .eq("hunt_id", player.hunt_id)
      .is("finished_at", null);

    if (count === 0) {
      await db.from("hunts").update({ status: "finished" }).eq("id", player.hunt_id);
    }

    return { finished: true, rank, gift: player.gift };
  } else {
    await db
      .from("players")
      .update({ current_round: nextRound, current_phase: "trivia" })
      .eq("id", player.id);
    return { finished: false, gift: "" };
  }
}

// ─── Start a hunt ────────────────────────────────────────────────────────────

export async function startHunt(db: SupabaseClient, hunt: Hunt): Promise<void> {
  await assignQuestionsForHunt(db, hunt);
  await db
    .from("players")
    .update({ current_round: 1, current_phase: "trivia" })
    .eq("hunt_id", hunt.id);
  await db
    .from("hunts")
    .update({ status: "active", started_at: Date.now() })
    .eq("id", hunt.id);
}

// ─── Leaderboard ─────────────────────────────────────────────────────────────

export async function getLeaderboard(db: SupabaseClient, huntId: string): Promise<LeaderboardEntry[]> {
  const { data: hunt } = await db
    .from("hunts")
    .select("total_rounds")
    .eq("id", huntId)
    .single();

  const { data: players } = await db
    .from("players")
    .select("name, current_round, current_phase, finished_at, finish_rank")
    .eq("hunt_id", huntId)
    .order("finish_rank", { ascending: true, nullsFirst: false });

  if (!players) return [];

  // Sort: finished first (by rank), then by round desc
  const sorted = players.sort((a, b) => {
    if (a.finished_at && !b.finished_at) return -1;
    if (!a.finished_at && b.finished_at) return 1;
    if (a.finish_rank && b.finish_rank) return a.finish_rank - b.finish_rank;
    return b.current_round - a.current_round;
  });

  return sorted.map((p) => ({
    name: p.name,
    round: p.current_round,
    totalRounds: hunt?.total_rounds ?? 0,
    phase: p.current_phase,
    finishRank: p.finish_rank ?? undefined,
  }));
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

async function computeFinishRank(db: SupabaseClient, huntId: string): Promise<number> {
  const { count } = await db
    .from("players")
    .select("id", { count: "exact", head: true })
    .eq("hunt_id", huntId)
    .not("finished_at", "is", null);
  return (count ?? 0) + 1;
}

export function generateJoinCode(): string {
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
  let code = "";
  for (let i = 0; i < 6; i++) code += chars[Math.floor(Math.random() * chars.length)];
  return code;
}
