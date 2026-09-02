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

    favorite_teams = db.relationship(
        "FavoriteTeam", backref="user", lazy=True, cascade="all, delete-orphan"
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


class TokenBlocklist(db.Model):
    """Revoked JWTs (used on logout) — checked on every protected request."""
    __tablename__ = "token_blocklist"

    id = db.Column(db.Integer, primary_key=True)
    jti = db.Column(db.String(36), nullable=False, index=True, unique=True)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
