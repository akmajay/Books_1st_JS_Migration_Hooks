import 'dart:io';
import 'package:pocketbase/pocketbase.dart';

enum ErrorType {
  network,       // No internet, timeout
  server,        // 500, 502, 503
  auth,          // 401, 403 — token expired, unauthorized
  notFound,      // 404
  validation,    // 400 — bad request, form errors
  conflict,      // 409 — duplicate record
  rateLimited,   // 429
  unknown,       // Anything else
}

class AppError implements Exception {
  final String message;       // User-friendly message
  final String? detail;       // Technical detail for logging
  final ErrorType type;
  final int? statusCode;
  final Map<String, dynamic>? fieldErrors;  // Validation errors per field
  
  const AppError({
    required this.message,
    this.detail,
    required this.type,
    this.statusCode,
    this.fieldErrors,
  });
  
  bool get isRetryable => type == ErrorType.network || type == ErrorType.server;
  bool get isAuthError => type == ErrorType.auth;
  bool get isValidationError => type == ErrorType.validation;
  
  factory AppError.fromClientException(ClientException e, {String? context}) {
    final status = e.statusCode;
    final ctx = context != null ? ' while $context' : '';
    
    // Check for network issues (SocketException is common in originalError)
    if (status == 0 || e.originalError is SocketException) {
      return AppError(
        message: 'No internet connection$ctx',
        detail: e.toString(),
        type: ErrorType.network,
        statusCode: 0,
      );
    }
    
    switch (status) {
      case 400:
        return AppError(
          message: 'Invalid data$ctx',
          detail: e.response['message'],
          type: ErrorType.validation,
          statusCode: 400,
          fieldErrors: _extractFieldErrors(e),
        );
      case 401:
        return const AppError(
          message: 'Session expired. Please sign in again.',
          type: ErrorType.auth,
          statusCode: 401,
        );
      case 403:
        return AppError(
          message: 'You don\'t have permission$ctx',
          type: ErrorType.auth,
          statusCode: 403,
        );
      case 404:
        return AppError(
          message: 'Content not found$ctx',
          type: ErrorType.notFound,
          statusCode: 404,
        );
      case 429:
        return const AppError(
          message: 'Too many requests. Please wait a moment.',
          type: ErrorType.rateLimited,
          statusCode: 429,
        );
      default:
        if (status >= 500) {
          return AppError(
            message: 'Server error$ctx. Please try again.',
            type: ErrorType.server,
            statusCode: status,
          );
        }
        return AppError(
          message: 'Something went wrong$ctx',
          detail: e.toString(),
          type: ErrorType.unknown,
          statusCode: status,
        );
    }
  }

  static Map<String, dynamic>? _extractFieldErrors(ClientException e) {
    try {
      final data = e.response['data'];
      if (data is Map<String, dynamic>) return data;
    } catch (_) {}
    return null;
  }

  @override
  String toString() => 'AppError: $message ($type)';
}
