class DeepLinkConfig {
  static const String domain = 'books.jayganga.com';
  static const String baseUrl = 'https://$domain';
  
  // URL Patterns
  static String bookUrl(String id) => '$baseUrl/book/$id';
  static String sellerUrl(String id) => '$baseUrl/seller/$id';
  static String referralUrl(String code) => '$baseUrl/ref/$code';
  static String txnUrl(String id) => '$baseUrl/txn/$id';
}
