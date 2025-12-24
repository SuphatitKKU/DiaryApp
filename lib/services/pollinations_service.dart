import 'dart:convert';
import 'package:http/http.dart' as http;

/// Pollinations.AI Image Generation Service
///
/// Free API for generating AI images without API key
/// Endpoint: https://image.pollinations.ai/prompt/{prompt}
class PollinationsService {
  static const String _baseUrl = 'https://image.pollinations.ai/prompt';

  /// Available style presets for cover generation
  static const List<String> stylePresets = [
    'Watercolor',
    'Minimalist',
    'Fantasy',
    'Abstract',
    'Vintage',
    'Nature',
    'Cosmic',
    'Dreamy',
  ];

  /// Generate image URL for a given prompt
  ///
  /// [prompt] - Description of the image to generate
  /// [width] - Image width in pixels (default: 800)
  /// [height] - Image height in pixels (default: 600)
  /// [seed] - Optional seed for reproducible results
  static String generateImageUrl({
    required String prompt,
    int width = 800,
    int height = 600,
    int? seed,
  }) {
    // URL encode the prompt
    final encodedPrompt = Uri.encodeComponent(prompt);

    // Build query parameters - nologo is important!
    final params = <String, String>{
      'width': width.toString(),
      'height': height.toString(),
      'nologo': 'true',
      'enhance': 'true',
    };

    if (seed != null) {
      params['seed'] = seed.toString();
    }

    final queryString = params.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    return '$_baseUrl/$encodedPrompt?$queryString';
  }

  /// Generate a diary cover URL with style
  ///
  /// [theme] - Theme or mood of the diary
  /// [style] - Art style from stylePresets
  static String generateCoverUrl({
    required String theme,
    required String style,
    int width = 800,
    int height = 600,
  }) {
    final prompt =
        'Beautiful $style book cover art, $theme, aesthetic, high quality, artistic, no text';
    return generateImageUrl(prompt: prompt, width: width, height: height);
  }

  /// Generate cover for wide banner (3:1 aspect ratio)
  static String generateBannerUrl({
    required String theme,
    required String style,
  }) {
    return generateCoverUrl(
      theme: theme,
      style: style,
      width: 900,
      height: 300,
    );
  }

  /// Generate cover for card (3:4 aspect ratio like A4)
  static String generateCardCoverUrl({
    required String theme,
    required String style,
  }) {
    return generateCoverUrl(
      theme: theme,
      style: style,
      width: 600,
      height: 800,
    );
  }

  /// Download image and convert to base64
  /// This is useful when you need to store the image locally
  static Future<Map<String, dynamic>> downloadImageAsBase64({
    required String prompt,
    String style = 'Watercolor',
    int width = 600,
    int height = 800,
  }) async {
    try {
      final fullPrompt =
          'Beautiful $style book cover art, $prompt, aesthetic, high quality, artistic, no text';
      final url = generateImageUrl(
        prompt: fullPrompt,
        width: width,
        height: height,
      );

      final response = await http
          .get(Uri.parse(url), headers: {'Accept': 'image/*'})
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final base64Image = base64Encode(response.bodyBytes);
        return {'success': true, 'imageBase64': base64Image, 'url': url};
      } else {
        return {
          'success': false,
          'error': 'Error ${response.statusCode}: ${response.reasonPhrase}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'เกิดข้อผิดพลาด: $e'};
    }
  }

  /// Test if the service is working
  static Future<bool> testConnection() async {
    try {
      final url = generateImageUrl(prompt: 'test', width: 64, height: 64);
      final response = await http
          .head(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
