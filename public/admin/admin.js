import { subscribeToHunt } from "/shared/supabase-client.js";

// ─── State ────────────────────────────────────────────────────────────────────
let currentStep = 1;
let huntId = "";
let adminToken = "";
let joinCode = "";
let huntMode = "multi";
let numRounds = 5;
let realtimeChannel = null;

// ─── Topic lists ─────────────────────────────────────────────────────────────
const TEEN_TOPICS  = [
  { id: "movies",     label: "🎬 Movies" },
  { id: "forestry",   label: "🌲 Forestry" },
  { id: "travel",     label: "✈️ Travel" },
  { id: "geography",  label: "🌍 Geography" },
  { id: "philosophy", label: "🤔 Philosophy" },
];
const CHILD_TOPICS = [
  { id: "animals",    label: "🐾 Animals" },
  { id: "nature",     label: "🌿 Nature" },
  { id: "fairytales", label: "🧚 Fairy Tales" },
];

// ─── DOM helpers ──────────────────────────────────────────────────────────────
const $ = (id) => document.getElementById(id);
const show = (id) => $(id).classList.remove("hidden");
const hide = (id) => $(id).classList.add("hidden");
const showErr = (id, msg) => { const el = $(id); el.textContent = msg; el.classList.remove("hidden"); };
const clearErr = (id) => $(id).classList.add("hidden");

// ─── Step navigation ──────────────────────────────────────────────────────────
function goToStep(n) {
  for (let i = 1; i <= 4; i++) {
    const section = $(`step-${i}`);
    if (section) section.classList.toggle("hidden", i !== n);
    const dot = $(`dot-${i}`);
    if (!dot) continue;
    dot.classList.toggle("active", i === n);
    dot.classList.toggle("done", i < n);
  }
  currentStep = n;
}

// ─── Topic checkboxes ─────────────────────────────────────────────────────────
function renderTopics() {
  const age = $("player-age").value;
  const topics = age === "child" ? CHILD_TOPICS : TEEN_TOPICS;
  const group = $("topics-group");
  group.innerHTML = "";
  topics.forEach(({ id, label }) => {
    const lbl = document.createElement("label");
    lbl.className = "chip-label";
    lbl.innerHTML = `<input type="checkbox" value="${id}" />${label}`;
    const cb = lbl.querySelector("input");
    cb.addEventListener("change", () => lbl.classList.toggle("checked", cb.checked));
    group.appendChild(lbl);
  });
}

// ─── Clue fields ─────────────────────────────────────────────────────────────
function renderClues() {
  numRounds = parseInt($("num-rounds").value, 10) || 5;
  const container = $("clues-container");
  container.innerHTML = "";
  for (let r = 1; r <= numRounds; r++) {
    const div = document.createElement("div");
    div.className = "field";
    div.innerHTML = `
      <label>Round ${r} clue <span class="text-muted">— riddle pointing to a real location</span></label>
      <textarea id="clue-${r}" placeholder="e.g. I keep things cold and tall, open me to find your next call…" rows="2"></textarea>
    `;
    container.appendChild(div);
  }
}

// ─── Player rows ──────────────────────────────────────────────────────────────
function renderPlayerMode() {
  huntMode = $("hunt-mode").value;
  const hint    = $("players-hint");
  const addBtn  = $("add-player");
  const container = $("players-container");
  container.innerHTML = "";
  playerRowCount = 0;

  if (huntMode === "single") {
    hint.textContent = "Add the one player (child) and their gift.";
    addBtn.classList.add("hidden");
    addPlayerRow();
  } else {
    hint.textContent = "Add each player and describe their real gift (revealed when they finish).";
    addBtn.classList.remove("hidden");
    addPlayerRow();
  }
}

let playerRowCount = 0;
function addPlayerRow() {
  playerRowCount++;
  const n = playerRowCount;
  const container = $("players-container");
  const div = document.createElement("div");
  div.id = `player-row-${n}`;
  div.className = "player-row";
  div.innerHTML = `
    <div class="field">
      <label>Name</label>
      <input type="text" id="pname-${n}" placeholder="e.g. Jamie" maxlength="40" />
    </div>
    <div class="field">
      <label>Their gift</label>
      <input type="text" id="pgift-${n}" placeholder="e.g. A new book 📚" maxlength="100" />
    </div>
    ${n > 1 ? `<button class="btn btn-ghost btn-sm" onclick="document.getElementById('player-row-${n}').remove()">✕</button>` : ""}
  `;
  container.appendChild(div);
}

function collectPlayers() {
  const rows = document.querySelectorAll("[id^='player-row-']");
  const players = [];
  rows.forEach((row) => {
    const n    = row.id.split("-").pop();
    const name = document.getElementById(`pname-${n}`)?.value.trim();
    const gift = document.getElementById(`pgift-${n}`)?.value.trim();
    if (name) players.push({ name, gift: gift || "A surprise gift! 🎁" });
  });
  return players;
}

// ─── Leaderboard rendering ────────────────────────────────────────────────────
function renderLeaderboard(players) {
  const ul = $("live-leaderboard");
  if (!players?.length) { ul.innerHTML = ""; return; }
  ul.innerHTML = players.map((p, i) => {
    const rank = p.finishRank ?? (i + 1);
    const cls  = rank === 1 ? "gold" : rank === 2 ? "silver" : rank === 3 ? "bronze" : "";
    const prog = p.phase === "finished"
      ? `<span class="lb-done">✓ Finished #${p.finishRank}</span>`
      : `Round ${p.round}/${p.totalRounds} — ${p.phase}`;
    return `
      <li class="lb-row">
        <div class="lb-rank ${cls}">${rank}</div>
        <div class="lb-name">${p.name}</div>
        <div class="lb-progress">${prog}</div>
      </li>`;
  }).join("");
}

// ─── Lobby player list ────────────────────────────────────────────────────────
async function refreshLobbyPlayers() {
  const res = await fetch(`/api/admin/hunts/${huntId}`, {
    headers: { "X-Admin-Token": adminToken },
  }).catch(() => null);
  if (!res?.ok) return;

  const { players } = await res.json();
  const ul = $("lobby-player-list");
  ul.innerHTML = players.map((p) => `<li class="player-item">${p.name}</li>`).join("");

  const hint     = $("player-count-hint");
  const startBtn = $("start-hunt");
  if (players.length === 0) {
    hint.textContent = "Waiting for players to join…";
    startBtn.disabled = true;
  } else {
    hint.textContent = `${players.length} player${players.length > 1 ? "s" : ""} ready`;
    startBtn.disabled = false;
  }
}

// ─── Realtime subscription ────────────────────────────────────────────────────
function connectRealtime() {
  if (realtimeChannel) realtimeChannel.unsubscribe?.();
  realtimeChannel = subscribeToHunt(huntId, (payload) => {
    if (payload.event === "player_joined")  refreshLobbyPlayers();
    if (payload.event === "hunt_started")  { hide("launch-card"); show("live-section"); }
    if (payload.event === "leaderboard")   renderLeaderboard(payload.data?.players);
  });
}

// ─── Step 1 → 2 ───────────────────────────────────────────────────────────────
$("player-age").addEventListener("change", renderTopics);
renderTopics();

$("next-1").addEventListener("click", () => {
  clearErr("step1-error");
  if (!$("hunt-name").value.trim())  return showErr("step1-error", "Please enter a hunt name.");
  const rounds = parseInt($("num-rounds").value, 10);
  if (!rounds || rounds < 1 || rounds > 15) return showErr("step1-error", "Rounds must be 1–15.");
  if (document.querySelectorAll("#topics-group input:checked").length === 0)
    return showErr("step1-error", "Select at least one trivia topic.");
  renderClues();
  goToStep(2);
});

// ─── Step 2 → 3 ───────────────────────────────────────────────────────────────
$("back-2").addEventListener("click", () => goToStep(1));

$("next-2").addEventListener("click", () => {
  clearErr("step2-error");
  const rounds = parseInt($("num-rounds").value, 10);
  for (let r = 1; r <= rounds; r++) {
    if (!document.getElementById(`clue-${r}`)?.value.trim())
      return showErr("step2-error", `Please write a clue for Round ${r}.`);
  }
  renderPlayerMode();
  goToStep(3);
});

// ─── Step 3 → 4 (Create hunt) ────────────────────────────────────────────────
$("back-3").addEventListener("click", () => goToStep(2));
$("add-player").addEventListener("click", addPlayerRow);

$("create-hunt").addEventListener("click", async () => {
  clearErr("step3-error");
  const players = collectPlayers();
  if (players.length === 0) return showErr("step3-error", "Add at least one player.");

  const rounds = parseInt($("num-rounds").value, 10);
  const name   = $("hunt-name").value.trim();
  const mode   = $("hunt-mode").value;
  const age    = $("player-age").value;
  const topics = Array.from(document.querySelectorAll("#topics-group input:checked")).map((el) => el.value);
  const clues  = Array.from({ length: rounds }, (_, i) =>
    document.getElementById(`clue-${i + 1}`)?.value.trim()
  );

  const btn = $("create-hunt");
  btn.disabled = true;
  btn.textContent = "Creating…";

  try {
    const huntRes = await fetch("/api/admin/hunts", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name, numRounds: rounds, topics, mode, playerAge: age, clues }),
    });
    if (!huntRes.ok) {
      const body = await huntRes.json();
      return showErr("step3-error", body.error ?? "Failed to create hunt.");
    }
    const data = await huntRes.json();
    huntId     = data.huntId;
    adminToken = data.adminToken;
    joinCode   = data.joinCode;

    // Add players
    for (const p of players) {
      await fetch(`/api/admin/hunts/${huntId}/players`, {
        method: "POST",
        headers: { "Content-Type": "application/json", "X-Admin-Token": adminToken },
        body: JSON.stringify({ name: p.name, gift: p.gift }),
      });
    }

    // Persist for page refresh
    sessionStorage.setItem("eh_admin_huntId",  huntId);
    sessionStorage.setItem("eh_admin_token",   adminToken);
    sessionStorage.setItem("eh_admin_code",    joinCode);

    // Show join details
    $("join-code-display").textContent = joinCode;
    const joinUrl = `${location.origin}/join?code=${joinCode}`;
    $("join-url-display").textContent = joinUrl;
    $("copy-url").addEventListener("click", () => {
      navigator.clipboard.writeText(joinUrl).then(() => {
        $("copy-url").textContent = "✅ Copied!";
        setTimeout(() => { $("copy-url").textContent = "📋 Copy join link"; }, 2000);
      });
    });

    await refreshLobbyPlayers();
    connectRealtime();
    goToStep(4);
  } catch {
    showErr("step3-error", "Network error. Please try again.");
  } finally {
    btn.disabled = false;
    btn.textContent = "Create Hunt 🥚";
  }
});

// ─── Start hunt ───────────────────────────────────────────────────────────────
$("start-hunt").addEventListener("click", async () => {
  clearErr("step4-error");
  const btn = $("start-hunt");
  btn.disabled = true;
  btn.textContent = "Starting…";

  const res = await fetch(`/api/admin/hunts/${huntId}/start`, {
    method: "POST",
    headers: { "X-Admin-Token": adminToken },
  });
  if (!res.ok) {
    const body = await res.json();
    showErr("step4-error", body.error ?? "Failed to start hunt.");
    btn.disabled = false;
    btn.textContent = "Start the Hunt! 🐰";
  }
  // On success the "hunt_started" broadcast shows the live leaderboard
});

// ─── Restore session on page reload ──────────────────────────────────────────
(async () => {
  const savedId    = sessionStorage.getItem("eh_admin_huntId");
  const savedToken = sessionStorage.getItem("eh_admin_token");
  const savedCode  = sessionStorage.getItem("eh_admin_code");
  if (!savedId || !savedToken || !savedCode) return;

  const res = await fetch(`/api/admin/hunts/${savedId}`, {
    headers: { "X-Admin-Token": savedToken },
  }).catch(() => null);
  if (!res?.ok) return;

  const { hunt } = await res.json();
  huntId     = savedId;
  adminToken = savedToken;
  joinCode   = savedCode;

  $("join-code-display").textContent = joinCode;
  const joinUrl = `${location.origin}/join?code=${joinCode}`;
  $("join-url-display").textContent = joinUrl;
  $("copy-url").addEventListener("click", () => { navigator.clipboard.writeText(joinUrl); });

  await refreshLobbyPlayers();
  connectRealtime();

  if (hunt.status === "active" || hunt.status === "finished") {
    hide("launch-card");
    show("live-section");
    const lb = await fetch(`/api/admin/hunts/${huntId}/leaderboard`, {
      headers: { "X-Admin-Token": adminToken },
    }).then((r) => r.json()).catch(() => null);
    if (lb?.players) renderLeaderboard(lb.players);
  }

  goToStep(4);
})();
