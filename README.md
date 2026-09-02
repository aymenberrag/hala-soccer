# Hala Soccer 2.0

A rebuild of Hala Soccer with a clean Flutter architecture, a real auth
backend, and the same brand identity and football data source as v1.

## What changed from v1

- **New architecture** — `lib/core`, `lib/data`, `lib/features`,
  `lib/shared` (see below). The old `lib/pages`, `lib/screens`,
  `lib/widgets`, `lib/services` structure is preserved in git history on
  `master` and in earlier commits of this branch.
- **Real authentication** — v1 had no auth API (the Account screen was a
  stub). This rebuild adds a small Flask backend (`backend/`) for
  signup/login/JWT/favorites, since API-Sports.io (the football data
  provider) never had one.
- **Football data is untouched** — same API-Sports.io endpoints,
  same tracked leagues, same fixture-status logic as v1. One real bug
  fixed: the season was hardcoded to `2022`; it's now computed from the
  current date.
- **State management**: Riverpod (v1 had none — just `setState`).
- **Routing**: go_router, with the startup flow: unknown session → splash,
  not onboarded → onboarding, onboarded+authenticated → home,
  onboarded+unauthenticated → login.
- **Design system**: colors ported directly from v1's actual hardcoded
  values (teal→green gradient, navy accent) so it still looks like Hala
  Soccer, just cleaned up into `lib/core/theme`.

## Project layout

```
lib/
├── core/        constants, theme, routing, network, storage
├── data/        models, services (API clients), repositories
├── features/    splash, onboarding, auth, home, matches, competitions, favorites, profile
├── shared/      reusable widgets
└── main.dart

backend/         Flask auth + favorites API (see backend/README below)
```

## Running the app

1. Football data key: copy `.env.example` to `.env` in the repo root and
   add your API-Sports.io key (free tier at
   https://dashboard.api-football.com/register).
2. Backend: see `backend/README.md` — run it locally, then point the app
   at it with `--dart-define=BACKEND_BASE_URL=http://<your-ip>:5050`
   (defaults to the Android emulator's `10.0.2.2:5050`).
3. `flutter pub get`
4. `flutter run`

## Known gaps / not yet built

- Match detail screen (events, lineups, stats) — API-Sports supports
  this data; the UI isn't built yet.
- Competitions → standings/top-scorers drill-down — repository methods
  exist (`FootballRepository.leagueStandings`, `.leagueTopScorers`),
  screen doesn't yet.
- Offline caching of previously-loaded data.
- "Forgot password" email delivery — the backend endpoint exists but
  doesn't send an email yet; needs a provider (SendGrid/SES/etc.) wired
  up before shipping.
- This code has not been run through `flutter analyze` or compiled —
  no Flutter SDK was available in the environment it was written in.
  Run `flutter pub get && flutter analyze` before trusting it fully.
