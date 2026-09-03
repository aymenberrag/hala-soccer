from flask import Blueprint, jsonify, request
from flask_jwt_extended import get_jwt_identity, jwt_required

from ..extensions import bcrypt, db
from ..errors import APIError
from ..models import FavoriteLeague, FavoriteTeam, User
from ..validation import check_password_strength, require_fields

profile_bp = Blueprint("profile", __name__)

_ALLOWED_GENDERS = {"male", "female", "prefer_not_to_say"}


def _current_user() -> User:
    user = User.query.get(get_jwt_identity())
    if user is None:
        raise APIError("User not found", status_code=404)
    return user


@profile_bp.get("")
@jwt_required()
def get_profile():
    return jsonify(_current_user().to_dict()), 200


@profile_bp.patch("")
@jwt_required()
def update_profile():
    user = _current_user()
    payload = request.get_json(silent=True) or {}

    if "name" in payload:
        name = (payload["name"] or "").strip()
        if len(name) < 2:
            raise APIError("Invalid name", field_errors={"name": "Must be at least 2 characters."})
        user.name = name

    if "country" in payload:
        user.country = (payload["country"] or "").strip() or None

    if "age" in payload and payload["age"] is not None:
        try:
            age = int(payload["age"])
        except (TypeError, ValueError):
            raise APIError("Invalid age", field_errors={"age": "Must be a number."})
        if not (5 <= age <= 120):
            raise APIError("Invalid age", field_errors={"age": "Enter a realistic age."})
        user.age = age

    if "gender" in payload:
        gender = payload["gender"]
        if gender is not None and gender not in _ALLOWED_GENDERS:
            raise APIError("Invalid gender", field_errors={"gender": "Unrecognized value."})
        user.gender = gender

    db.session.commit()
    return jsonify(user.to_dict()), 200


@profile_bp.post("/onboarding-preferences")
@jwt_required()
def save_onboarding_preferences():
    """
    Bulk-saves the whole "user information -> favorite teams -> favorite
    leagues" onboarding sequence (spec section 3) in one call, and marks
    the account as ready for the Home screen's AI curation to use.
    Idempotent: replaces the existing favorite sets rather than appending,
    since the onboarding UI submits the user's full final selection.
    """
    user = _current_user()
    payload = request.get_json(silent=True) or {}

    if "country" in payload:
        user.country = (payload["country"] or "").strip() or None
    if "age" in payload and payload["age"] is not None:
        try:
            user.age = int(payload["age"])
        except (TypeError, ValueError):
            raise APIError("Invalid age", field_errors={"age": "Must be a number."})
    if "gender" in payload:
        gender = payload["gender"]
        if gender is not None and gender not in _ALLOWED_GENDERS:
            raise APIError("Invalid gender", field_errors={"gender": "Unrecognized value."})
        user.gender = gender

    teams = payload.get("favorite_teams") or []
    leagues = payload.get("favorite_leagues") or []

    FavoriteTeam.query.filter_by(user_id=user.id).delete()
    for t in teams:
        db.session.add(
            FavoriteTeam(
                user_id=user.id,
                team_id=t["team_id"],
                team_name=t.get("team_name"),
                team_logo=t.get("team_logo"),
            )
        )

    FavoriteLeague.query.filter_by(user_id=user.id).delete()
    for l in leagues:
        db.session.add(
            FavoriteLeague(
                user_id=user.id,
                league_id=l["league_id"],
                league_name=l.get("league_name"),
                league_logo=l.get("league_logo"),
                league_country=l.get("league_country"),
            )
        )

    user.preferences_complete = True
    db.session.commit()
    return jsonify(user.to_dict()), 200


@profile_bp.post("/change-password")
@jwt_required()
def change_password():
    user = _current_user()
    payload = request.get_json(silent=True) or {}
    require_fields(payload, "current_password", "new_password")

    if not user.check_password(payload["current_password"]):
        raise APIError(
            "Current password is incorrect",
            status_code=401,
            field_errors={"current_password": "Incorrect password."},
        )

    check_password_strength(payload["new_password"])
    user.set_password(payload["new_password"])
    db.session.commit()
    return jsonify({"message": "Password updated"}), 200
