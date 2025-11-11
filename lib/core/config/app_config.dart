class AppConfig {
  const AppConfig._();

  static const socketBaseUrl = String.fromEnvironment(
    'SOCKET_BASE_URL',
    defaultValue: 'http://localhost:3001',
  );
}
