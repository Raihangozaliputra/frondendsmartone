class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException: $message (Status Code: $statusCode)';
    }
    return 'ApiException: $message';
  }
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() {
    return 'NetworkException: $message';
  }
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({String message = 'Unauthorized access'})
    : super(message, statusCode: 401);
}

class NotFoundException extends ApiException {
  NotFoundException({String message = 'Resource not found'})
    : super(message, statusCode: 404);
}

class ServerException extends ApiException {
  ServerException({String message = 'Server error'})
    : super(message, statusCode: 500);
}
