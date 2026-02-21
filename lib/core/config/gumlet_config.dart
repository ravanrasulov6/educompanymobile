/// Gumlet Video Hosting Configuration
class GumletConfig {
  GumletConfig._();

  /// Gumlet API Key
  static const String apiKey = 'gumlet_1d5d08eab326ae752a40827e3e11ee6f';

  /// Gumlet Video Collection ID
  static const String collectionId = '6984ca694db88a967ffedb4e';

  /// Gumlet API Base URL
  static const String apiBaseUrl = 'https://api.gumlet.com/v1';

  /// Video Assets endpoint
  static const String assetsUrl = '$apiBaseUrl/video/assets';

  /// Direct upload endpoint
  static const String directUploadUrl = '$apiBaseUrl/video/assets/upload';

  /// Get playback URL for an asset
  static String getPlaybackUrl(String assetId) =>
      'https://video.gumlet.io/embed/$collectionId/$assetId';

  /// Get thumbnail URL for an asset
  static String getThumbnailUrl(String assetId) =>
      'https://video.gumlet.io/watch/$collectionId/$assetId/thumbnail.jpg';
}
