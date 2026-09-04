# Hala Soccer — React Web Frontend

A mobile-first React port of the Flutter app, living entirely under `frontend/`
so the Flutter app in `lib/` stays untouched. Same backend, same identity,
same information architecture as the Flutter app.

## Setup

```bash
cd frontend
npm install
cp .env.example .env.local   # fill in VITE_API_BASE_URL / VITE_FOOTBALL_API_KEY
npm run dev
```

- `npm run build` — type-checks with `tsc -b` then builds with Vite. Verified
  clean (zero errors) as of this commit.
- `npm run lint` — runs oxlint. Verified clean (zero errors; two harmless
  "context file exports a hook" style warnings) as of this commit.
- `npm run preview` — serves the production build locally; also useful for
  confirming deep-link routes survive a hard refresh (see below).

The backend is the same Flask app in `../backend` the Flutter app talks to —
run that separately and point `VITE_API_BASE_URL` at it.

## What's ported 1:1 from Flutter, and where

| Flutter source | React equivalent |
|---|---|
| `lib/core/theme/*.dart` | `src/index.css` (`:root` custom properties + Tailwind `@theme`) |
| `lib/data/models/*.dart` | `src/types/models.ts` |
| `lib/data/services/football_api_client.dart` | `src/services/footballApi.ts` |
| `lib/data/repositories/football_repository.dart` | `src/services/footballRepository.ts` |
| `lib/core/network/backend_api_client.dart` | `src/services/backendApi.ts` |
| `lib/data/repositories/auth_repository.dart` + `auth_service.dart` | `src/services/authService.ts` |
| `lib/features/favorites/favorites_providers.dart` (service half) | `src/services/favoritesService.ts` |
| `lib/data/repositories/profile_repository.dart` | `src/services/profileService.ts` |
| `lib/data/services/ai/football_importance.dart` + `curation_service.dart`'s fallback path | `src/services/curationService.ts` |
| `lib/features/auth/auth_controller.dart` | `src/context/AuthContext.tsx` |
| `lib/features/onboarding/preferences_draft_controller.dart` | `src/context/PreferencesDraftContext.tsx` |
| `lib/core/routing/app_router.dart` (`redirect()`) | `src/app/RootGate.tsx` |
| `lib/core/constants/league_constants.dart` | `src/utils/leagueConstants.ts` |
| `lib/shared/widgets/fixture_card.dart` | `src/components/matches/FixtureCard.tsx` |
| `lib/features/home/screens/home_shell.dart` | `src/components/navigation/AppShell.tsx` |
| every `lib/features/**/screens/*_screen.dart` | the matching file under `src/features/**` |

Colors, spacing, and radii in `src/index.css` are the exact hex/px values
from `app_colors.dart` / `app_dimensions.dart` — not approximations.

## Two deliberate architecture decisions (read before shipping)

The rebuild spec asked to "reuse the same football data/AI architecture"
rather than invent a new one. I followed that, but it's worth being explicit
about what it means on the web specifically, since a browser is a much more
exposed environment than a compiled mobile binary:

1. **`VITE_FOOTBALL_API_KEY` is called directly from the browser** (see the
   comment block at the top of `src/services/footballApi.ts`). This mirrors
   `football_api_client.dart` exactly, but on mobile that key ships inside a
   compiled APK; in a browser it's plainly visible in devtools' Network tab
   to anyone. Treat it as effectively public once this is deployed. Before
   real production use, consider adding a thin proxy in `../backend` that
   forwards to API-Sports with the key server-side — the Flask backend
   intentionally doesn't do this today (see `backend/app/__init__.py`).

2. **AI curation always uses the rule-based fallback, never the OpenRouter
   LLM call.** Calling an AI provider's API key from the browser has the
   same exposure problem as #1, except a leaked LLM key is more directly
   abusable (someone else racks up your usage bill). `src/services/curationService.ts`
   is a faithful port of `football_importance.dart`'s scoring — the same
   safety-net logic the Flutter app already falls back to whenever its own
   OpenRouter call is unavailable — so behavior is consistent, just without
   the LLM layer on top.

Both are flagged with `SECURITY NOTE` comments at the point of use.

## Deep links / refresh (spec section 21)

`vite dev` and `vite preview` both serve `index.html` for any unmatched path
out of the box — verified by curling `/matches/12345`, `/competitions/39`,
etc. against a `vite preview` instance and confirming each returns the SPA
shell, not a 404. For actual production hosting, static hosts don't all do
this automatically, so:

- `public/_redirects` is included for Netlify.
- `vercel.json` is included for Vercel.
- If you deploy behind nginx/Apache/something else instead, add the
  equivalent `try_files $uri /index.html;` rule yourself.

## Known gaps

- **Not manually clicked through in a real browser against a live backend.**
  `npm run build` and `npm run lint` both pass clean, and `vite preview`
  serves every route correctly, which is real evidence the app boots and
  routes work — but that's not the same as testing the actual login →
  onboarding → Home flow, form validation UX, or verifying API response
  shapes against a running Flask instance. Do that before trusting this in
  production.
- **Responsive breakpoints (320–1920px) are written mobile-first with Tailwind
  and a `md:` desktop-rail breakpoint, but not visually screenshot-tested**
  at each of the widths spec section 23 lists. Worth a manual pass in
  Chrome devtools' device toolbar.
- **No automated tests** (unit or e2e) — the spec's testing section is a
  manual checklist, which hasn't been run end-to-end.
- Session persistence uses `localStorage` (see `src/utils/storage.ts`) since
  the browser has no equivalent to Flutter's secure keychain storage —
  same tradeoff as any other web app, just worth knowing it's there.
- Match statistics rendering assumes API-Football's stat `type` strings are
  stable across leagues; untested against a real paid-tier response for
  leagues outside the free plan's typical coverage.
