export class ApiException extends Error {
  statusCode: number | null;
  fieldErrors: Record<string, string> | null;

  constructor(message: string, statusCode: number | null = null, fieldErrors: Record<string, string> | null = null) {
    super(message);
    this.name = "ApiException";
    this.statusCode = statusCode;
    this.fieldErrors = fieldErrors;
  }

  get isAuthError() {
    return this.statusCode === 401;
  }

  get isNetworkError() {
    return this.statusCode === null;
  }
}
