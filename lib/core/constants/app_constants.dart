class AppConstants {
  // Stripe Configuration (Test Mode - Free)
  // Replace with your own Stripe publishable key for production
  static const String stripePublishableKey = 'pk_test_your_stripe_publishable_key';
  
  // App Info
  static const String appName = 'BlissCoders App';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String userKey = 'user_data';
  static const String cartKey = 'cart_data';
  static const String isLoggedInKey = 'is_logged_in';
  
  // API Endpoints (Mock for demo)
  static const String baseUrl = 'https://api.example.com';
  
  // Currency
  static const String currencySymbol = '\$';
  static const String currencyCode = 'USD';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
}
