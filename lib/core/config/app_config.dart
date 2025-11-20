class AppConfig {
  const AppConfig._();

  static const socketBaseUrl = String.fromEnvironment(
    'SOCKET_BASE_URL',
    defaultValue: 'http://121.67.187.138:3001',
  );
}
