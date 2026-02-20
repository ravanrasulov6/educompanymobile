import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/premium_button.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/widgets/entrance_animation.dart';
import '../../core/services/haptic_service.dart';

/// Premium landing screen redesign with cinematic feel and Azerbaijani localization
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset(
      'assets/videos/landingvideo.mp4',
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    
    _videoController!.initialize().then((_) {
      if (mounted) {
        _videoController!.setVolume(0.0);
        _videoController!.setLooping(true);
        _videoController!.play();
        setState(() {});
      }
    }).catchError((error) {
      debugPrint("LandingVideo Error: $error");
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Fixed Video Background
          SizedBox.expand(
            child: _videoController != null && _videoController!.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController!.value.size.width,
                      height: _videoController!.value.size.height,
                      child: VideoPlayer(_videoController!),
                    ),
                  )
                : Container(color: Colors.black),
          ),
          
          // 2. Cinematic Gradient Overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.95),
                  ],
                  stops: const [0.0, 0.4, 0.9],
                ),
              ),
            ),
          ),

          // 3. Scrollable Content Layer (Fixes Responsiveness)
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Top Row: Logo and Guest Access
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                                ),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 140),
                                  child: Image.asset(
                                    'assets/images/logo_m.png',
                                    height: 32,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                HapticService.light();
                                context.read<AuthProvider>().continueAsGuest();
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                                    ),
                                    child: const Row(
                                      children: [
                                        Text(
                                          'Qonaq kimi bax',
                                          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 13),
                                        ),
                                        SizedBox(width: 6),
                                        Icon(Icons.person, color: Colors.black87, size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const Spacer(flex: 3),
                      
                      // Floating Badge
                      EntranceAnimation(
                        child: const RotatingBadge(),
                      ),
                      const SizedBox(height: 16),

                      // Headline
                      EntranceAnimation(
                        delay: const Duration(milliseconds: 200),
                        child: const TypewriterHeadline(),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      EntranceAnimation(
                        delay: const Duration(milliseconds: 400),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'Azərbaycanın ən qabaqcıl mütəxəssislərindən premium dərslər və peşəkar sertifikatlar.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Primary Action Card
                      EntranceAnimation(
                        delay: const Duration(milliseconds: 600),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(36),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(36),
                                border: Border.all(color: Colors.white.withOpacity(0.15)),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            HapticService.medium();
                                            context.go('/signup');
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.skyBlue,
                                            foregroundColor: Colors.white,
                                            minimumSize: const Size(0, 64),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                            elevation: 0,
                                          ),
                                          child: const Text('Qeydiyyat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            HapticService.medium();
                                            context.go('/login');
                                          },
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            side: const BorderSide(color: Colors.white30),
                                            minimumSize: const Size(0, 64),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                          ),
                                          child: const Text('Daxil ol', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildAvatarGroup(),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text(
                                          'MƏZUN TƏRƏFİNDƏN TÖVSİYƏ EDİLİR',
                                          textAlign: TextAlign.right,
                                          maxLines: 2,
                                          style: TextStyle(
                                            color: Colors.white60,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarGroup() {
    return SizedBox(
      width: 80,
      height: 32,
      child: Stack(
        children: [
          _buildAvatarItem(0, 'https://picsum.photos/id/1/200/200'),
          _buildAvatarItem(1, 'https://picsum.photos/id/2/200/200'),
          _buildAvatarItem(2, 'https://picsum.photos/id/3/200/200'),
          Positioned(
            left: 48,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Center(
                child: Text(
                  '+12k',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarItem(int index, String url) {
    return Positioned(
      left: index * 16.0,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          image: DecorationImage(
            image: NetworkImage(url),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class TypewriterHeadline extends StatefulWidget {
  const TypewriterHeadline({super.key});

  @override
  State<TypewriterHeadline> createState() => _TypewriterHeadlineState();
}

class _TypewriterHeadlineState extends State<TypewriterHeadline> {
  final List<String> _words = ["Gələcəyini Qur", "Karyeranı Qur", "Xəyallarını Qur"];
  int _wordIndex = 0;
  String _currentText = "";
  bool _isDeleting = false;
  
  @override
  void initState() {
    super.initState();
    _type();
  }

  void _type() {
    final String fullText = _words[_wordIndex];
    
    setState(() {
      if (_isDeleting) {
        _currentText = fullText.substring(0, _currentText.length - 1);
      } else {
        _currentText = fullText.substring(0, _currentText.length + 1);
      }
    });

    int typeSpeed = 100;

    if (_isDeleting) {
      typeSpeed = 50;
    }

    if (!_isDeleting && _currentText == fullText) {
      _isDeleting = true;
      typeSpeed = 2000; // Wait before deleting
    } else if (_isDeleting && _currentText == "") {
      _isDeleting = false;
      _wordIndex = (_wordIndex + 1) % _words.length;
      typeSpeed = 500;
    }

    Future.delayed(Duration(milliseconds: typeSpeed), () {
      if (mounted) _type();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: size.width < 360 ? 32 : 44,
          fontWeight: FontWeight.w900,
          height: 1.0,
          letterSpacing: -1.5,
        ),
        children: [
          const TextSpan(text: 'Biliklə\n'),
          TextSpan(
            text: _currentText,
            style: const TextStyle(color: AppColors.skyBlue),
          ),
          const TextSpan(
            text: '|',
            style: TextStyle(color: Colors.transparent), // Cursor placeholder
          ),
        ],
      ),
    );
  }
}

class RotatingBadge extends StatefulWidget {
  const RotatingBadge({super.key});

  @override
  State<RotatingBadge> createState() => _RotatingBadgeState();
}

class _RotatingBadgeState extends State<RotatingBadge> {
  final List<String> _labels = [
    'CANLI DƏRSLƏR',
    'MÜKAFATLI İMTAHANLAR',
    'VİDEO DƏRSLƏR',
  ];
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _startRotation();
  }

  void _startRotation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _index = (_index + 1) % _labels.length;
        });
        _startRotation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.5),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Row(
              key: ValueKey<int>(_index),
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.skyBlue,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _labels[_index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
