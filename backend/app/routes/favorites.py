from flask import Blueprint, jsonify, request
from flask_jwt_extended import get_jwt_identity, jwt_required

from ..extensions import db
from ..errors import APIError
from ..models import FavoriteTeam
from ..validation import require_fields

favorites_bp = Blueprint("favorites", __name__)


@favorites_bp.get("")
@jwt_required()
def list_favorites():
    user_id = get_jwt_identity()
    favorites = FavoriteTeam.query.filter_by(user_id=user_id).all()
    return jsonify({"favorites": [f.to_dict() for f in favorites]}), 200


@favorites_bp.post("")
@jwt_required()
def add_favorite():
    user_id = get_jwt_identity()
    payload = request.get_json(silent=True) or {}
    require_fields(payload, "team_id")

    team_id = payload["team_id"]
    if FavoriteTeam.query.filter_by(user_id=user_id, team_id=team_id).first():
        raise APIError("Team is already in favorites", status_code=409)

    favorite = FavoriteTeam(
        user_id=user_id,
        team_id=team_id,
        team_name=payload.get("team_name"),
        team_logo=payload.get("team_logo"),
    )
    db.session.add(favorite)
    db.session.commit()
    return jsonify(favorite.to_dict()), 201


@favorites_bp.delete("/<string:favorite_id>")
@jwt_required()
def remove_favorite(favorite_id: str):
    user_id = get_jwt_identity()
    favorite = FavoriteTeam.query.filter_by(id=favorite_id, user_id=user_id).first()
    if favorite is None:
        raise APIError("Favorite not found", status_code=404)

    db.session.delete(favorite)
    db.session.commit()
    return jsonify({"message": "Removed"}), 200
