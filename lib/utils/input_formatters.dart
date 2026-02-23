import 'package:flutter/services.dart';

class AppInputFormatters {
  /// Price formatter: only digits and commas
  static TextInputFormatter price() => FilteringTextInputFormatter.allow(
    RegExp(r'[\d,]'),
  );
  
  /// Phone formatter: only digits, max 10
  static TextInputFormatter phone() => FilteringTextInputFormatter.allow(
    RegExp(r'\d'),
  );
  
  /// Pin code: only digits, max 6
  static TextInputFormatter pinCode() => LengthLimitingTextInputFormatter(6);
  
  /// ISBN: digits and hyphens
  static TextInputFormatter isbn() => FilteringTextInputFormatter.allow(
    RegExp(r'[\d\-]'),
  );
  
  /// Name: letters and spaces only
  static TextInputFormatter nameOnly() => FilteringTextInputFormatter.allow(
    RegExp(r'[a-zA-Z\s]'),
  );
  
  /// No special characters
  static TextInputFormatter alphanumeric() => FilteringTextInputFormatter.allow(
    RegExp(r'[a-zA-Z0-9\s]'),
  );
  
  /// Max length
  static TextInputFormatter maxLen(int max) =>
    LengthLimitingTextInputFormatter(max);
}
