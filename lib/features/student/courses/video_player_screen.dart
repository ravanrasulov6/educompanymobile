import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

/// Video player placeholder screen
class VideoPlayerScreen extends StatelessWidget {
  const VideoPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Now Playing'),
      ),
      body: Column(
        children: [
          // Video area
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.grey[900],
              child: const Center(
                child: Icon(Icons.play_circle_fill,
                    color: Colors.white54, size: 72),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Introduction to Flutter',
                  style: AppTextStyles.headlineMedium
                      .copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  '12:30 • Section 1, Lesson 1',
                  style:
                      AppTextStyles.bodySmall.copyWith(color: Colors.white54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
