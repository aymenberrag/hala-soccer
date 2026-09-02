class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? fieldErrors;

  ApiException(this.message, {this.statusCode, this.fieldErrors});

  bool get isAuthError => statusCode == 401;
  bool get isNetworkError => statusCode == null;

  @override
  String toString() => message;
}
