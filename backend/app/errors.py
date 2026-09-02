from flask import jsonify


class APIError(Exception):
    """Raise this anywhere in the app for a clean, consistent JSON error."""

    def __init__(self, message: str, status_code: int = 400, field_errors: dict | None = None):
        super().__init__(message)
        self.message = message
        self.status_code = status_code
        self.field_errors = field_errors or {}

    def to_dict(self) -> dict:
        body = {"error": self.message}
        if self.field_errors:
            body["field_errors"] = self.field_errors
        return body


def register_error_handlers(app):
    @app.errorhandler(APIError)
    def _handle_api_error(err: APIError):
        return jsonify(err.to_dict()), err.status_code

    @app.errorhandler(404)
    def _handle_404(_err):
        return jsonify({"error": "Not found"}), 404

    @app.errorhandler(405)
    def _handle_405(_err):
        return jsonify({"error": "Method not allowed"}), 405

    @app.errorhandler(500)
    def _handle_500(_err):
        return jsonify({"error": "Internal server error"}), 500
