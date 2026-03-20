export interface Hunt {
  id: string;
  name: string;
  mode: "single" | "multi";
  age_group: "child" | "teen";
  total_rounds: number;
  topics: string;  // JSON array string
  status: "setup" | "lobby" | "active" | "finished";
  join_code: string;
  admin_token: string;
  started_at: number | null;
  created_at: number;
}

export interface Player {
  id: string;
  hunt_id: string;
  name: string;
  gift: string;
  session_token: string;
  current_round: number;
  current_phase: "waiting" | "trivia" | "clue" | "finished";
  finish_rank: number | null;
  finished_at: number | null;
  joined_at: number;
}

export interface Clue {
  id: number;
  hunt_id: string;
  round_number: number;
  text: string;
}

export interface PlayerRound {
  id: number;
  player_id: string;
  hunt_id: string;
  round_number: number;
  question_id: number | null;
  trivia_answered: boolean;
  clue_found: boolean;
  answered_at: number | null;
  found_at: number | null;
}

export interface Question {
  id: number;
  qid: string;
  topic: string;
  audience: string;
  question: string;
  option_a: string;
  option_b: string;
  option_c: string;
  option_d: string;
  correct: string;
}

export interface QuestionForClient {
  id: number;
  topic: string;
  question: string;
  options: { a: string; b: string; c: string; d: string };
}

export interface LeaderboardEntry {
  name: string;
  round: number;
  totalRounds: number;
  phase: string;
  finishRank?: number;
}

export interface PlayerState {
  phase: "waiting" | "trivia" | "clue" | "finished";
  round: number;
  totalRounds: number;
  huntMode: "single" | "multi";
  playerAge: "child" | "teen";
  question?: QuestionForClient;
  clue?: { text: string };
  gift?: string;
  rank?: number;
  leaderboard?: LeaderboardEntry[];
}
