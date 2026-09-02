from flask import Blueprint, jsonify, request
from flask_jwt_extended import get_jwt_identity, jwt_required

from ..extensions import bcrypt, db
from ..errors import APIError
from ..models import User
from ..validation import check_password_strength, require_fields

profile_bp = Blueprint("profile", __name__)


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
