import { subscribeToHunt } from "/shared/supabase-client.js";

// ─── DOM helpers ──────────────────────────────────────────────────────────────
const $ = (id) => document.getElementById(id);
const show = (id) => $(id).classList.remove("hidden");
const hide = (id) => $(id).classList.add("hidden");

// ─── Session ──────────────────────────────────────────────────────────────────
const sessionToken = localStorage.getItem("eh_session_token") ?? "";
const huntId       = localStorage.getItem("eh_hunt_id") ?? "";

if (!sessionToken || !huntId) location.replace("/join");

// ─── Topic label helper ───────────────────────────────────────────────────────
const TOPIC_LABELS = {
  movies: "🎬 Movies", forestry: "🌲 Forestry", travel: "✈️ Travel",
  geography: "🌍 Geography", philosophy: "🤔 Philosophy",
  animals: "🐾 Animals", nature: "🌿 Nature", fairytales: "🧚 Fairy Tales",
};

// ─── Render state ─────────────────────────────────────────────────────────────
function renderState(state) {
  if (state.playerAge) localStorage.setItem("eh_player_age", state.playerAge);

  hide("waiting-section");
  hide("trivia-section");
  hide("clue-section");

  // Progress bar
  const pct = state.totalRounds > 0 ? ((state.round - 1) / state.totalRounds * 100) : 0;
  $("progress-fill").style.width = `${Math.max(0, pct)}%`;
  $("progress-label").textContent = `Round ${state.round || "–"} of ${state.totalRounds}`;
  $("round-label").textContent    = `Round ${state.round || "–"}`;

  if (state.phase === "waiting") {
    show("waiting-section");
    return;
  }

  if (state.phase === "finished") {
    if (state.gift)  localStorage.setItem("eh_gift", state.gift);
    if (state.rank)  localStorage.setItem("eh_rank", String(state.rank));
    localStorage.setItem("eh_hunt_mode", state.huntMode);
    location.replace("/win");
    return;
  }

  if (state.phase === "trivia" && state.question) {
    renderTrivia(state.question, state.huntMode, state.playerAge);
  }
  if (state.phase === "clue" && state.clue) {
    renderClue(state.clue.text, state.playerAge);
  }
  if (state.huntMode === "multi" && state.leaderboard) {
    renderMiniLeaderboard(state.leaderboard);
  }
}

// ─── Trivia panel ─────────────────────────────────────────────────────────────
function renderTrivia(question, _huntMode, _playerAge) {
  const badge = $("phase-badge");
  badge.className = "phase-badge phase-trivia";
  badge.textContent = "🎯 Trivia";

  const topicBadge = $("topic-badge");
  topicBadge.className = `topic-badge topic-${question.topic}`;
  topicBadge.textContent = TOPIC_LABELS[question.topic] ?? question.topic;

  $("question-text").textContent = question.question;
  $("question-num").textContent  = "";

  const grid = $("option-grid");
  grid.innerHTML = "";
  ["a", "b", "c", "d"].forEach((letter) => {
    const btn = document.createElement("button");
    btn.className = "option-btn";
    btn.innerHTML = `<span class="option-letter">${letter.toUpperCase()}</span>${question.options[letter]}`;
    btn.addEventListener("click", () => submitAnswer(letter, grid));
    grid.appendChild(btn);
  });

  hide("answer-feedback");
  show("trivia-section");
  hide("clue-section");
}

// ─── Clue panel ───────────────────────────────────────────────────────────────
function renderClue(text, playerAge) {
  const badge = $("phase-badge");
  badge.className = "phase-badge phase-clue";
  badge.textContent = "🗺️ Find the Clue";

  $("clue-text").textContent = text;
  hide("trivia-section");
  show("clue-section");

  if (playerAge === "child") {
    show("tap-found");
    hide("hold-found");
  } else {
    hide("tap-found");
    show("hold-found");
  }
}

// ─── Mini leaderboard ─────────────────────────────────────────────────────────
function renderMiniLeaderboard(players) {
  show("mini-lb-wrap");
  const list = $("mini-lb-list");
  list.innerHTML = players.slice(0, 5).map((p, i) => {
    const rank = p.finishRank ?? (i + 1);
    const prog = p.phase === "finished"
      ? `<span style="color:var(--forest); font-weight:700">✓ #${p.finishRank}</span>`
      : `${p.round}/${p.totalRounds}`;
    return `<div class="mini-lb-row">
      <span style="width:1.2rem; text-align:center; font-weight:800; color:var(--text-muted)">${rank}</span>
      <span class="mini-lb-name">${p.name}</span>
      <span class="mini-lb-progress">${prog}</span>
    </div>`;
  }).join("");
}

// ─── Submit answer ────────────────────────────────────────────────────────────
async function submitAnswer(letter, grid) {
  const btns = grid.querySelectorAll(".option-btn");
  btns.forEach((b) => b.disabled = true);

  const res  = await fetch("/api/game/answer", {
    method: "POST",
    headers: { "Content-Type": "application/json", "X-Session-Token": sessionToken },
    body: JSON.stringify({ answer: letter }),
  });
  const data = await res.json();
  const fb   = $("answer-feedback");

  if (data.correct) {
    fb.className = "alert alert-success";
    fb.textContent = "✅ Correct! Now find the hidden clue…";
    fb.classList.remove("hidden");
    setTimeout(() => { hide("answer-feedback"); refreshState(); }, 1000);
  } else {
    fb.className = "alert alert-error";
    fb.textContent = "❌ Not quite — try again!";
    fb.classList.remove("hidden");
    // Shake animation
    const section = $("trivia-section");
    section.id = "wrong-shake";
    setTimeout(() => { section.id = "trivia-section"; }, 400);
    btns.forEach((b) => b.disabled = false);
  }
}

// ─── Confirm clue found ───────────────────────────────────────────────────────
async function confirmClueFound() {
  const data = await fetch("/api/game/found-clue", {
    method: "POST",
    headers: { "X-Session-Token": sessionToken },
  }).then((r) => r.json());

  if (data.finished) {
    localStorage.setItem("eh_gift", data.gift ?? "");
    localStorage.setItem("eh_rank", String(data.rank ?? 0));
    localStorage.setItem("eh_hunt_mode", localStorage.getItem("eh_hunt_mode") ?? "multi");
    location.replace("/win");
  } else {
    refreshState();
  }
}

// Instant-tap button (children)
$("tap-found").addEventListener("click", () => {
  $("tap-found").disabled = true;
  confirmClueFound();
});

// Hold-to-confirm button (teens)
let holdTimer = null;
const holdBtn  = $("hold-found");
const holdFill = $("hold-fill");

function startHold() {
  holdFill.classList.add("holding");
  holdTimer = setTimeout(() => { holdTimer = null; confirmClueFound(); }, 2000);
}
function cancelHold() {
  if (holdTimer) { clearTimeout(holdTimer); holdTimer = null; }
  holdFill.classList.remove("holding");
}

holdBtn.addEventListener("mousedown", startHold);
holdBtn.addEventListener("touchstart", (e) => { e.preventDefault(); startHold(); });
holdBtn.addEventListener("mouseup",    cancelHold);
holdBtn.addEventListener("mouseleave", cancelHold);
holdBtn.addEventListener("touchend",   cancelHold);
holdBtn.addEventListener("touchcancel", cancelHold);

// ─── Fetch latest state ───────────────────────────────────────────────────────
async function refreshState() {
  const res = await fetch("/api/game/state", { headers: { "X-Session-Token": sessionToken } });
  if (!res.ok) { location.replace("/join"); return; }
  renderState(await res.json());
}

// ─── Realtime updates ─────────────────────────────────────────────────────────
subscribeToHunt(huntId, (payload) => {
  if (payload.event === "hunt_started")   refreshState();
  if (payload.event === "winner" || payload.event === "player_finished") refreshState();
  if (payload.event === "leaderboard") {
    if (localStorage.getItem("eh_hunt_mode") === "multi") {
      renderMiniLeaderboard(payload.data?.players ?? []);
    }
  }
});

// ─── Initial load ─────────────────────────────────────────────────────────────
refreshState();
