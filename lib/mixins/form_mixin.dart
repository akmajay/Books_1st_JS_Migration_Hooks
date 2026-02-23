import 'package:flutter/material.dart';
import '../models/app_error.dart';

mixin FormMixin<T extends StatefulWidget> on State<T> {
  final formKey = GlobalKey<FormState>();
  bool isSubmitting = false;
  
  /// Map to hold server-side errors
  final Map<String, String> _serverErrors = {};

  /// Validate and submit
  Future<void> submitForm(Future<void> Function() onSubmit) async {
    // Clear previous server errors
    _serverErrors.clear();
    
    if (!formKey.currentState!.validate()) {
      _scrollToFirstError();
      return;
    }
    
    setState(() => isSubmitting = true);
    
    try {
      await onSubmit();
    } on AppError catch (e) {
      if (e.isValidationError && e.fieldErrors != null) {
        _applyServerErrors(e.fieldErrors!);
      } else {
        _showErrorSnackbar(e.message);
      }
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }
  
  void _applyServerErrors(Map<String, dynamic> errors) {
    setState(() {
      errors.forEach((key, value) {
        if (value is Map && value.containsKey('message')) {
          _serverErrors[key] = value['message'].toString();
        } else {
          _serverErrors[key] = value.toString();
        }
      });
    });
    // Trigger validation to show the errors
    formKey.currentState!.validate();
    _scrollToFirstError();
  }

  String? serverValidator(String fieldName, String? value) {
    if (_serverErrors.containsKey(fieldName)) {
      return _serverErrors[fieldName];
    }
    return null;
  }

  void _scrollToFirstError() {
    // Logic to scroll to the first field with an error
    // In Flutter, this usually involves findRenderObject or specific ScrollControllers
    // For now, we rely on the framework showing errors, but we can enhance this
    // if a ScrollController is provided in the state.
  }
  
  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
