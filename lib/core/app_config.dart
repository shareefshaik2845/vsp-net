/// Central runtime configuration for the app.
///
/// Override at build/run time with:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
///   flutter run --dart-define=PINNED_CERT_HASH=sha256fingerprint
class AppConfig {
  AppConfig._();

  /// Base URL of the Spring Boot backend. Defaults to
  /// `http://localhost:8080`. When running on the Android emulator, use
  /// `--dart-define=API_BASE_URL=http://10.0.2.2:8080` since `localhost`
  /// inside the emulator refers to the emulator itself, not the host.
  /// In production, set `--dart-define=API_BASE_URL=https://your-api.com`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const String apiV1 = '$apiBaseUrl/api/v1';

  /// SHA-256 certificate fingerprint for SSL pinning.
  /// Set via `--dart-define=PINNED_CERT_HASH=sha256hash`.
  /// Leave empty to skip pinning (e.g. local dev).
  static const String pinnedCertHash = String.fromEnvironment(
    'PINNED_CERT_HASH',
    defaultValue: '',
  );
}
