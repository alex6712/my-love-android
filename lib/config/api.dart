class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.my-love-application.ru',
  );
  static const String apiPrefix = '/v1';

  static String get apiUrl => '$baseUrl$apiPrefix';
}
