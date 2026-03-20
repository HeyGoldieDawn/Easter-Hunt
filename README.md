# 🐣 Easter Hunt App

A real-time multiplayer Easter egg hunt for the whole family. Combines **physical clue hunting** (players find real-world locations) with **trivia questions** on Movies, Forestry, Travel, Geography, and Philosophy.

Supports two modes:
- **Multiplayer Race** — first to finish wins; live leaderboard for older teens & young adults
- **Single Player** — self-paced adventure for younger children with kid-friendly questions

---

## Quick Start (Local)

```bash
# Install Bun (if not already installed)
curl -fsSL https://bun.sh/install | bash

cd easter-hunt
bun install
bun run build:frontend
bun run dev
# Open http://localhost:3000/admin
```

---

## How to Run a Hunt

### 1. Open the Admin screen
Go to `/admin` and complete the setup wizard:

1. **Hunt Setup** — name the hunt, choose Single/Multi mode, age group (child/teen), number of rounds (1–15), and trivia topics
2. **Write Clues** — enter a riddle for each round pointing to a real physical location (fridge, clock, bookshelf, garden, etc.)
3. **Add Players** — enter each player's name and their real gift description (revealed only when they finish)
4. **Launch** — get the 6-character join code + shareable URL

### 2. Players join
Share the URL: `https://your-app.railway.app/join?code=ABCDE1`

Players open it on their phone, enter their name, and wait in the lobby.

### 3. Start!
Hit **Start the Hunt** in the admin screen. All players begin simultaneously.

**Game loop (per round):**
- Answer a trivia question correctly → unlock the physical clue
- Find the real-world location → tap/hold "I Found It!" → unlock next trivia
- Repeat for all rounds
- First to complete all rounds wins!

---

## Deployment (Railway — Recommended)

1. Push the repo to GitHub
2. Create a new Railway project → **Deploy from GitHub repo**
3. Set **Root Directory** to `easter-hunt`
4. Add a **Volume** mounted at `/data` (for SQLite persistence)
5. Set environment variables:
   - `DATABASE_URL` = `/data/hunt.db`
   - `PORT` = `3000` (Railway injects `$PORT` automatically)
6. Railway gives you a public HTTPS URL — share it with players on Easter morning

**Cost:** Free tier or ~$5 for a one-day event.

### Fly.io alternative
```bash
cd easter-hunt
fly launch
fly volumes create hunt_data --size 1
# Edit fly.toml to add mount: source=hunt_data, destination=/data
fly deploy
```

---

## Question Bank

185 questions across 8 topics:

| Audience | Topics | Count |
|---|---|---|
| Teens/Adults | Movies, Forestry, Travel, Geography, Philosophy | 25 each = 125 |
| Children | Animals, Nature, Fairy Tales | 20 each = 60 |

Questions are randomly assigned per player at hunt start — no two players get the same question simultaneously.

---

## Project Structure

```
easter-hunt/
├── src/
│   ├── server.ts              # Bun HTTP + WebSocket server
│   ├── types.ts               # Shared TypeScript types
│   ├── db/                    # SQLite (schema, client, seeder)
│   ├── routes/                # admin, game, static
│   ├── ws/                    # WebSocket handler + broadcast
│   └── game/                  # engine + question logic
├── public/                    # Vanilla TS frontend (compiled to .js)
│   ├── admin/                 # Multi-step admin setup
│   ├── lobby/                 # Player join + waiting room
│   ├── game/                  # Main game screen (trivia + clues)
│   └── win/                   # Win/completion screen + confetti
└── questions/bank.ts          # Full question bank
```

---

## Tech Stack
- **Bun** — runtime, HTTP server, WebSockets, SQLite (no npm, no Express, no ORM)
- **TypeScript** — throughout
- **Vanilla HTML/CSS** — mobile-first, no framework, <20KB per page
- **SQLite** (Bun native) — local or `/data` volume in production
