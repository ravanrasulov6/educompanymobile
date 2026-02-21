import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/gumlet_config.dart';

/// Gumlet video upload and management service
class GumletService {
  GumletService._();
  static final GumletService instance = GumletService._();

  /// Upload a video file to Gumlet
  /// Returns the asset_id on success, null on failure
  Future<String?> uploadVideo({
    required File videoFile,
    required String title,
    ValueChanged<double>? onProgress,
  }) async {
    try {
      // Step 1: Create a direct upload URL
      final createResponse = await http.post(
        Uri.parse(GumletConfig.directUploadUrl),
        headers: {
          'Authorization': 'Bearer ${GumletConfig.apiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'collection_id': GumletConfig.collectionId,
          'title': title,
        }),
      );

      if (createResponse.statusCode != 200 &&
          createResponse.statusCode != 201) {
        debugPrint(
            'Gumlet create error: ${createResponse.statusCode} ${createResponse.body}');
        return null;
      }

      final createData = jsonDecode(createResponse.body);
      final uploadUrl = createData['upload_url'] as String;
      final assetId = createData['asset_id'] as String;

      // Step 2: Upload the file using PUT
      final videoBytes = await videoFile.readAsBytes();

      final uploadRequest = http.Request('PUT', Uri.parse(uploadUrl));
      uploadRequest.bodyBytes = videoBytes;
      uploadRequest.headers['Content-Type'] = 'video/mp4';

      final streamedResponse = await uploadRequest.send();

      if (streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201) {
        debugPrint('Video uploaded successfully: $assetId');
        return assetId;
      } else {
        debugPrint('Gumlet upload error: ${streamedResponse.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Gumlet upload exception: $e');
      return null;
    }
  }

  /// Get playback URL for a video asset
  String getPlaybackUrl(String assetId) {
    return GumletConfig.getPlaybackUrl(assetId);
  }

  /// Get thumbnail URL for a video asset
  String getThumbnailUrl(String assetId) {
    return GumletConfig.getThumbnailUrl(assetId);
  }

  /// Get video asset details from Gumlet
  Future<Map<String, dynamic>?> getAssetDetails(String assetId) async {
    try {
      final response = await http.get(
        Uri.parse('${GumletConfig.assetsUrl}/$assetId'),
        headers: {
          'Authorization': 'Bearer ${GumletConfig.apiKey}',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Gumlet asset details error: $e');
    }
    return null;
  }
}
