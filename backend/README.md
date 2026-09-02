# Hala Soccer Backend (Flask)

Auth + user profile + favorite teams. This does **not** proxy football
data — the Flutter app calls API-Sports.io directly for fixtures,
standings, scorers, exactly like v1 did.

## Setup

```bash
cd backend
python3 -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env            # then edit SECRET_KEY / JWT_SECRET_KEY
python run.py
```

Server runs on `http://0.0.0.0:5050`.

## Endpoints

| Method | Path                          | Auth | Description               |
|--------|-------------------------------|------|----------------------------|
| POST   | /api/auth/signup              | no   | Create account             |
| POST   | /api/auth/login               | no   | Log in                     |
| POST   | /api/auth/refresh             | refresh token | Get new access token |
| POST   | /api/auth/logout              | yes  | Revoke current token       |
| GET    | /api/auth/me                  | yes  | Current user               |
| POST   | /api/auth/forgot-password     | no   | Issue reset (email TODO)   |
| GET    | /api/profile                  | yes  | Get profile                |
| PATCH  | /api/profile                  | yes  | Update name                |
| POST   | /api/profile/change-password  | yes  | Change password            |
| GET    | /api/favorites                | yes  | List favorite teams        |
| POST   | /api/favorites                | yes  | Add favorite team          |
| DELETE | /api/favorites/<id>           | yes  | Remove favorite team       |

All protected endpoints expect `Authorization: Bearer <access_token>`.

## Before deploying to production

- Set real `SECRET_KEY` / `JWT_SECRET_KEY` env vars (the app refuses to
  start in `FLASK_ENV=production` without them).
- Swap SQLite for Postgres via `DATABASE_URL`.
- Run behind `gunicorn` (already in requirements.txt), not `python run.py`.
- Wire up an email provider for `/api/auth/forgot-password` — it
  currently returns a generic success message without sending anything.
- Set `CORS_ORIGINS` to your actual app origin(s) instead of `*`.
