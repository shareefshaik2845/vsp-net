import 'dart:io';

class _SslPinningHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) {
        if (host == 'localhost' || host == '10.0.2.2') return true;
        return false;
      };
  }
}

void configureSslPinning() {
  HttpOverrides.global = _SslPinningHttpOverrides();
}
