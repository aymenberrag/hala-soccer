from flask import Blueprint, jsonify, request
from flask_jwt_extended import (
    create_access_token,
    create_refresh_token,
    get_jwt,
    get_jwt_identity,
    jwt_required,
)

from ..extensions import db
from ..errors import APIError
from ..models import TokenBlocklist, User
from ..validation import check_password_strength, clean_email, require_fields

auth_bp = Blueprint("auth", __name__)


def _tokens_for(user: User) -> dict:
    return {
        "access_token": create_access_token(identity=user.id),
        "refresh_token": create_refresh_token(identity=user.id),
        "user": user.to_dict(),
    }


@auth_bp.post("/signup")
def signup():
    payload = request.get_json(silent=True) or {}
    require_fields(payload, "name", "email", "password", "confirm_password")

    name = payload["name"].strip()
    email = clean_email(payload["email"].strip())
    password = payload["password"]
    confirm_password = payload["confirm_password"]

    if len(name) < 2:
        raise APIError("Invalid name", field_errors={"name": "Must be at least 2 characters."})

    if password != confirm_password:
        raise APIError(
            "Passwords do not match",
            field_errors={"confirm_password": "Must match the password field."},
        )

    check_password_strength(password)

    if User.query.filter_by(email=email).first():
        raise APIError(
            "An account with this email already exists",
            status_code=409,
            field_errors={"email": "Already registered. Try logging in instead."},
        )

    user = User(name=name, email=email)
    user.set_password(password)
    db.session.add(user)
    db.session.commit()

    return jsonify(_tokens_for(user)), 201


@auth_bp.post("/login")
def login():
    payload = request.get_json(silent=True) or {}
    require_fields(payload, "email", "password")

    email = payload["email"].strip().lower()
    password = payload["password"]

    user = User.query.filter_by(email=email).first()
    if user is None or not user.check_password(password):
        # Deliberately generic — don't reveal whether the email exists.
        raise APIError("Invalid email or password", status_code=401)

    return jsonify(_tokens_for(user)), 200


@auth_bp.post("/refresh")
@jwt_required(refresh=True)
def refresh():
    user_id = get_jwt_identity()
    user = User.query.get(user_id)
    if user is None:
        raise APIError("User no longer exists", status_code=401)
    return jsonify({"access_token": create_access_token(identity=user.id)}), 200


@auth_bp.post("/logout")
@jwt_required(verify_type=False)
def logout():
    jti = get_jwt()["jti"]
    db.session.add(TokenBlocklist(jti=jti))
    db.session.commit()
    return jsonify({"message": "Logged out"}), 200


@auth_bp.get("/me")
@jwt_required()
def me():
    user = User.query.get(get_jwt_identity())
    if user is None:
        raise APIError("User not found", status_code=404)
    return jsonify(user.to_dict()), 200


# Note on "forgot password": a real implementation needs an email/SMS
# provider (SendGrid, SES, etc.) to deliver a reset link, which is an
# infra/credentials decision for you to make. The endpoint below issues
# a short-lived reset token so the Flutter UI can be built against a
# real contract now; wire up an email provider before shipping this.
@auth_bp.post("/forgot-password")
def forgot_password():
    payload = request.get_json(silent=True) or {}
    require_fields(payload, "email")
    email = payload["email"].strip().lower()
    user = User.query.filter_by(email=email).first()

    # Always return 200 regardless of whether the user exists, to avoid
    # leaking which emails are registered.
    if user is not None:
        # TODO: generate a real reset token + email it via a provider.
        pass

    return jsonify(
        {"message": "If that email is registered, a reset link has been sent."}
    ), 200
