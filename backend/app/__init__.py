"""
Hala Soccer backend — application factory.

This service owns ONLY authentication + user profile + favorites.
It intentionally does NOT proxy football data — the Flutter app keeps
calling API-Sports.io directly for fixtures/standings/scorers, exactly
as it did before. This backend exists to fill the gap the old app never
had: real user accounts.
"""
from flask import Flask
from flask_cors import CORS

from .config import get_config
from .extensions import db, migrate, bcrypt, jwt


def create_app(config_name: str | None = None) -> Flask:
    app = Flask(__name__)
    app.config.from_object(get_config(config_name))

    # --- extensions ---
    db.init_app(app)
    migrate.init_app(app, db)
    bcrypt.init_app(app)
    jwt.init_app(app)
    CORS(app, resources={r"/api/*": {"origins": app.config["CORS_ORIGINS"]}})

    # --- models must be imported before create_all/migrations pick them up ---
    from . import models  # noqa: F401

    @jwt.token_in_blocklist_loader
    def _is_token_revoked(_jwt_header, jwt_payload):
        jti = jwt_payload["jti"]
        return db.session.query(
            models.TokenBlocklist.query.filter_by(jti=jti).exists()
        ).scalar()

    # --- blueprints ---
    from .routes.auth import auth_bp
    from .routes.profile import profile_bp
    from .routes.favorites import favorites_bp
    from .routes.health import health_bp

    app.register_blueprint(health_bp)
    app.register_blueprint(auth_bp, url_prefix="/api/auth")
    app.register_blueprint(profile_bp, url_prefix="/api/profile")
    app.register_blueprint(favorites_bp, url_prefix="/api/favorites")

    # --- error handlers (consistent JSON shape for the Flutter client) ---
    from .errors import register_error_handlers
    register_error_handlers(app)

    return app
