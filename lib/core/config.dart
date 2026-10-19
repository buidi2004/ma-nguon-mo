class AppConfig {
  static const appName = 'OpenFlix';
  static const appVersion = '11.0.0+11';

  static const pbUrl = String.fromEnvironment(
    'PB_URL',
    defaultValue: 'http://10.0.2.2:8090',
  );

  /// Google OAuth 2.0 Web Client ID dùng cho Credential Manager / Google Sign-In & Backend
  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '984465122134-i3qs48s873uh6bgfk56ua889alrt4jmc.apps.googleusercontent.com',
  );

  /// ImageKit Cloud Media CDN & Storage API
  static const imageKitPublicKey = String.fromEnvironment(
    'IMAGEKIT_PUBLIC_KEY',
    defaultValue: 'public_2TM2elL5pi2eb6tA1wclrG3ADk8=',
  );

  static const imageKitPrivateKey = String.fromEnvironment(
    'IMAGEKIT_PRIVATE_KEY',
    defaultValue: 'private_ZNhiaB7c2FJ3ajreTwHME02ciIQ=',
  );

  static const imageKitUrlEndpoint = String.fromEnvironment(
    'IMAGEKIT_URL_ENDPOINT',
    defaultValue: 'https://ik.imagekit.io/j9clftudq5',
  );

  static const imageKitId = String.fromEnvironment(
    'IMAGEKIT_ID',
    defaultValue: 'KKEIERMTRA',
  );
}
