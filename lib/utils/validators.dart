

class AppValidators {
  static String? required(String? value, [String message = 'This field is required']) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length != 10) return 'Enter a valid 10-digit number';
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.isEmpty) return null;
    final price = double.tryParse(value);
    if (price == null || price <= 0) return 'Enter a valid price';
    return null;
  }

  // Composable versions
  static String? Function(String?) requiredFn(String message) => (v) => required(v, message);
  static String? Function(String?) priceFn() => (v) => price(v);
}
