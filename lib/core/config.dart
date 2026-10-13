class AppConfig {
  static const appName = 'OpenFlix';
  static const appVersion = '1.0.0+1';

  static const pbUrl = String.fromEnvironment(
    'PB_URL',
    defaultValue: 'http://10.0.2.2:8090',
  );
}
