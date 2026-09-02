import re

from email_validator import validate_email, EmailNotValidError

from .errors import APIError

PASSWORD_MIN_LEN = 8
_PASSWORD_RE = re.compile(r"^(?=.*[A-Za-z])(?=.*\d).+$")  # at least 1 letter + 1 digit


def require_fields(payload: dict, *fields: str) -> None:
    missing = [f for f in fields if not payload.get(f)]
    if missing:
        raise APIError(
            "Missing required fields",
            field_errors={f: "This field is required." for f in missing},
        )


def clean_email(raw_email: str) -> str:
    try:
        result = validate_email(raw_email, check_deliverability=False)
        return result.normalized.lower()
    except EmailNotValidError as exc:
        raise APIError("Invalid email address", field_errors={"email": str(exc)}) from exc


def check_password_strength(password: str) -> None:
    if len(password) < PASSWORD_MIN_LEN:
        raise APIError(
            "Password too weak",
            field_errors={"password": f"Must be at least {PASSWORD_MIN_LEN} characters."},
        )
    if not _PASSWORD_RE.match(password):
        raise APIError(
            "Password too weak",
            field_errors={"password": "Must contain at least one letter and one number."},
        )
