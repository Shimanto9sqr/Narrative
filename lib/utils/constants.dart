
class AppConstants {
  static const String newsApiKey = 'API_KEY_HERE';
  static const String newsApiBaseUrl = 'https://newsapi.org/v2';

  static const String dbName = 'news_app.db';
  static const int dbVersion = 1;
  static const String preferencesTable = 'user_preferences';

  static const String appName = 'Personalized News';
  static const int articlesPerPage = 20;

  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Network error. Please check your connection.';
  static const String authError = 'Authentication failed. Please try again.';
  static const String noArticlesError = 'No articles found. Try selecting more categories.';

  static const String loginSuccess = 'Login successful!';
  static const String registrationSuccess = 'Registration successful!';
  static const String preferencesUpdated = 'Preferences updated successfully!';
}