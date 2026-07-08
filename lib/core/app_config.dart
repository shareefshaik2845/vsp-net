/// Central runtime configuration for the app.
///
/// Override at build/run time with:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
class AppConfig {
  AppConfig._();

  /// Base URL of the Spring Boot backend. Defaults to
  /// `http://localhost:8080`. When running on the Android emulator, use
  /// `--dart-define=API_BASE_URL=http://10.0.2.2:8080` since `localhost`
  /// inside the emulator refers to the emulator itself, not the host.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const String apiV1 = '$apiBaseUrl/api/v1';
}
