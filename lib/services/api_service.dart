import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import '../models/app_error.dart';
import '../router/app_router.dart';
import 'pocketbase_service.dart';

class ApiService {
  final PocketBase pb;
  
  ApiService(this.pb);
  
  /// Generic API call wrapper with error mapping and retry logic
  Future<T> call<T>(Future<T> Function() apiCall, {
    int maxRetries = 2,
    String? errorContext,
  }) async {
    int attempt = 0;
    
    while (true) {
      try {
        return await apiCall();
      } on ClientException catch (e) {
        attempt++;
        
        final appError = AppError.fromClientException(e, context: errorContext);
        
        // Handle 401: clear auth and notify app (usually via navigation redirect in logic)
        if (appError.statusCode == 401) {
          pb.authStore.clear();
          AppRouter.router.go('/'); 
          throw appError;
        }

        // Don't retry on auth or validation errors
        if (appError.isAuthError || appError.isValidationError) {
          throw appError;
        }
        
        // Retry on retryable errors (network/server)
        if (attempt <= maxRetries && appError.isRetryable) {
          final waitMs = 500 * attempt; // 500ms, 1000ms
          debugPrint('API Retry Attempt $attempt in ${waitMs}ms...');
          await Future.delayed(Duration(milliseconds: waitMs));
          continue;
        }
        
        throw appError;
      } catch (e) {
        // Wrap unexpected errors
        if (e is AppError) rethrow;
        throw AppError(
          message: 'Something went wrong',
          detail: e.toString(),
          type: ErrorType.unknown,
        );
      }
    }
  }

  /// Specialized call that returns data or null instead of throwing for simple fetches
  Future<T?> tryCall<T>(Future<T> Function() apiCall, {String? errorContext}) async {
    try {
      return await call(apiCall, errorContext: errorContext);
    } catch (e) {
      debugPrint('TryCall failed: $e');
      return null;
    }
  }
}

/// Convenience getter
ApiService get api => ApiService(pb);
