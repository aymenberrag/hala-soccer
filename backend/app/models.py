import uuid
from datetime import datetime, timezone

from .extensions import db, bcrypt


def _uuid() -> str:
    return str(uuid.uuid4())


class User(db.Model):
    __tablename__ = "users"

    id = db.Column(db.String(36), primary_key=True, default=_uuid)
    name = db.Column(db.String(120), nullable=False)
    email = db.Column(db.String(255), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(255), nullable=False)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))

    # Onboarding "user information" step (section 3 of the spec). All
    # optional — we only ask for what's actually useful for curation.
    country = db.Column(db.String(100), nullable=True)
    age = db.Column(db.Integer, nullable=True)
    gender = db.Column(db.String(30), nullable=True)
    preferences_complete = db.Column(db.Boolean, nullable=False, default=False)

    favorite_teams = db.relationship(
        "FavoriteTeam", backref="user", lazy=True, cascade="all, delete-orphan"
    )
    favorite_leagues = db.relationship(
        "FavoriteLeague", backref="user", lazy=True, cascade="all, delete-orphan"
    )

    def set_password(self, raw_password: str) -> None:
        self.password_hash = bcrypt.generate_password_hash(raw_password).decode("utf-8")

    def check_password(self, raw_password: str) -> bool:
        return bcrypt.check_password_hash(self.password_hash, raw_password)

    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "name": self.name,
            "email": self.email,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "country": self.country,
            "age": self.age,
            "gender": self.gender,
            "preferences_complete": self.preferences_complete,
            "favorite_team_ids": [t.team_id for t in self.favorite_teams],
            "favorite_league_ids": [l.league_id for l in self.favorite_leagues],
        }


class FavoriteTeam(db.Model):
    """
    A user's favorited football team. We only store the API-Sports team_id
    plus a light cache of name/logo so the app can render the favorites
    list without an extra API round trip — the source of truth for match
    data always stays API-Sports.
    """
    __tablename__ = "favorite_teams"
    __table_args__ = (
        db.UniqueConstraint("user_id", "team_id", name="uq_user_team"),
    )

    id = db.Column(db.String(36), primary_key=True, default=_uuid)
    user_id = db.Column(db.String(36), db.ForeignKey("users.id"), nullable=False)
    team_id = db.Column(db.Integer, nullable=False)
    team_name = db.Column(db.String(255))
    team_logo = db.Column(db.String(500))
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))

    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "team_id": self.team_id,
            "team_name": self.team_name,
            "team_logo": self.team_logo,
        }


class FavoriteLeague(db.Model):
    """
    A user's favorited competition. Mirrors FavoriteTeam — we cache
    name/logo/country so the app can render Favorites/onboarding summaries
    without an extra API-Sports round trip.
    """
    __tablename__ = "favorite_leagues"
    __table_args__ = (
        db.UniqueConstraint("user_id", "league_id", name="uq_user_league"),
    )

    id = db.Column(db.String(36), primary_key=True, default=_uuid)
    user_id = db.Column(db.String(36), db.ForeignKey("users.id"), nullable=False)
    league_id = db.Column(db.Integer, nullable=False)
    league_name = db.Column(db.String(255))
    league_logo = db.Column(db.String(500))
    league_country = db.Column(db.String(120))
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))

    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "league_id": self.league_id,
            "league_name": self.league_name,
            "league_logo": self.league_logo,
            "league_country": self.league_country,
        }


class TokenBlocklist(db.Model):
    """Revoked JWTs (used on logout) — checked on every protected request."""
    __tablename__ = "token_blocklist"

    id = db.Column(db.Integer, primary_key=True)
    jti = db.Column(db.String(36), nullable=False, index=True, unique=True)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
