import { subscribeToHunt } from "/shared/supabase-client.js";

// ─── DOM helpers ──────────────────────────────────────────────────────────────
const $ = (id) => document.getElementById(id);
const show = (id) => $(id).classList.remove("hidden");
const hide = (id) => $(id).classList.add("hidden");
const showErr = (id, msg) => { const el = $(id); el.textContent = msg; el.classList.remove("hidden"); };

// ─── Pre-fill code from URL ───────────────────────────────────────────────────
const codeParam = new URLSearchParams(location.search).get("code") ?? "";
if (codeParam) $("join-code").value = codeParam.toUpperCase();

// ─── Resume existing session ──────────────────────────────────────────────────
const savedToken   = localStorage.getItem("eh_session_token");
const savedHuntId  = localStorage.getItem("eh_hunt_id");
const savedName    = localStorage.getItem("eh_player_name");

if (savedToken && savedHuntId) {
  fetch("/api/game/state", { headers: { "X-Session-Token": savedToken } })
    .then((r) => r.json())
    .then((state) => {
      if (state.phase === "trivia" || state.phase === "clue") {
        location.replace("/game");
      } else if (state.phase === "finished") {
        location.replace("/win");
      } else if (state.phase === "waiting") {
        $("hunt-name-display").textContent = savedName ?? "Easter Hunt";
        hide("join-section");
        show("lobby-section");
        $("self-item").textContent = savedName ?? "You";
        listenForStart(savedHuntId, savedToken);
      }
    })
    .catch(() => {});
}

// ─── Join button ──────────────────────────────────────────────────────────────
$("join-btn").addEventListener("click", joinHunt);
$("join-code").addEventListener("keydown", (e) => { if (e.key === "Enter") joinHunt(); });
$("player-name").addEventListener("keydown", (e) => { if (e.key === "Enter") joinHunt(); });

async function joinHunt() {
  const code = $("join-code").value.trim().toUpperCase();
  const name = $("player-name").value.trim();
  if (!code) return showErr("join-error", "Please enter your join code.");
  if (!name) return showErr("join-error", "Please enter your name.");

  const btn = $("join-btn");
  btn.disabled = true;
  btn.textContent = "Joining…";

  try {
    const res  = await fetch("/api/game/join", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ joinCode: code, playerName: name }),
    });
    const data = await res.json();
    if (!res.ok) {
      showErr("join-error", data.error ?? "Could not join. Check your code.");
      btn.disabled = false;
      btn.textContent = "Join Hunt 🐰";
      return;
    }

    localStorage.setItem("eh_session_token", data.sessionToken);
    localStorage.setItem("eh_hunt_id",       data.huntId);
    localStorage.setItem("eh_player_name",   data.playerName);
    localStorage.setItem("eh_hunt_mode",     data.huntMode);

    $("hunt-name-display").textContent = data.huntName ?? "Easter Hunt";
    hide("join-section");
    show("lobby-section");
    $("self-item").textContent = data.playerName;
    listenForStart(data.huntId, data.sessionToken);
  } catch {
    showErr("join-error", "Network error. Please try again.");
    btn.disabled = false;
    btn.textContent = "Join Hunt 🐰";
  }
}

// ─── Wait for hunt to start ───────────────────────────────────────────────────
function listenForStart(huntId, _sessionToken) {
  subscribeToHunt(huntId, (payload) => {
    if (payload.event === "player_joined") {
      // Another player joined — add them to the visible list
      const name = payload.data?.name;
      const list = $("lobby-list");
      if (name && !list.querySelector(`[data-name="${name}"]`)) {
        const li = document.createElement("li");
        li.className = "player-item";
        li.dataset.name = name;
        li.textContent = name;
        list.appendChild(li);
      }
    }
    if (payload.event === "hunt_started") {
      location.replace("/game");
    }
  });
}
