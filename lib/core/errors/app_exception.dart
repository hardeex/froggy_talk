sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

final class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection.']);
}

final class ApiException extends AppException {
  const ApiException(super.message, {this.statusCode});
  final int? statusCode;
}

final class ValidationException extends AppException {
  const ValidationException(super.message, {this.fieldErrors});
  final Map<String, String>? fieldErrors;
}

final class UnknownException extends AppException {
  const UnknownException([
    super.message = 'An unexpected error occurred. Please try again.',
  ]);
}
