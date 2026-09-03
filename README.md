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
- **AI curation** (new headline feature) — `lib/data/services/ai/`:
  `AiCurationService` combines what the user favorited with a rule-based
  "real-world football importance" scorer (`FootballImportance`: derbies
  like Real Madrid–Barcelona, Champions League/knockout rounds, top
  leagues) and, when `OPENROUTER_API_KEY` is set, asks a free Qwen model
  via OpenRouter to pick/rank the Home feed and league list on top of
  that. The AI provider is swappable (`AiProviderFactory` +
  `AI_PROVIDER`/`AI_MODEL` in `.env`) and the whole thing always falls
  back to the rule-based ranking if the AI call fails or isn't
  configured — Home never breaks because of it.
- **Full onboarding flow** — intro carousel → login/signup → user info
  (country/age/gender) → favorite teams (search + multi-select) →
  favorite leagues (search + multi-select) → Home, bulk-saved via
  `POST /api/profile/onboarding-preferences`. Router redirect gates on
  `AppUser.preferencesComplete` so returning users skip straight to Home.
- **Fixture Details, League Details** — events/stats/lineups/H2H for a
  match; standings/fixtures/top scorers & assists for a league.
- **Favorites** — now shows favorite leagues (not just teams) plus
  upcoming/recent matches involving favorites, and Profile can add/remove
  both teams and leagues after onboarding.

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

- Offline caching of previously-loaded data.
- "Forgot password" email delivery — the backend endpoint exists but
  doesn't send an email yet; needs a provider (SendGrid/SES/etc.) wired
  up before shipping.
- Notifications/language/theme toggles mentioned as optional in the spec
  are not implemented (spec: "if implemented").
- **This code has not been run through `flutter analyze`, compiled, or
  run on a device/emulator** — no Flutter SDK, Android emulator, or
  network access to api-football.com was available in the environment
  it was written in. It was written carefully against the existing
  codebase's own conventions and cross-checked by hand, but **you must
  run `flutter pub get && flutter analyze` and exercise the app on a
  real device before trusting it in production.** Highest-risk areas to
  test first: the onboarding → preferences redirect flow in
  `core/routing/app_router.dart`, and the AI curation JSON parsing in
  `data/services/ai/curation_service.dart` (falls back safely, but worth
  confirming the fallback actually triggers cleanly offline).
