class ApiEndpoints {
  // Base URL (placeholder, easy to swap based on environment)
  static const String baseUrl = 'https://api.carelink.example.com';

  // Endpoints
  static const String centers = '/centers';
  static const String news = '/news';
  static const String donorsEligibility = '/donors/eligibility';
  static const String donationRequests = '/donationRequests';
  static const String appointments = '/appointments';

  // API Keys (Ideally sourced from .env)
  // static const String googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
}
