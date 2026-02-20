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
        setState(() {}); // Trigger a rebuild to show the video
      }
    }).catchError((error) {
      debugPrint("VideoPlay Error: $error");
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background fallback
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // ── 1. Video Background Hero Section (HTML lines 72-79) ──
            Positioned.fill(
              child: Container(
                color: const Color(0xFF101922), // bg-slate-900 from HTML fallback
                child: _videoController != null && _videoController!.value.isInitialized
                    ? SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _videoController!.value.size.width,
                            height: _videoController!.value.size.height,
                            child: VideoPlayer(_videoController!),
                          ),
                        ),
                      )
                    : Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuCpfYExzimRuv4hjLT10Z2JxdZcExBKAbpkbpOON_PBB5EDXvdaWleXd9Z8wWFx8EitH2r4PSBkryhJiVOKnzDLY_toG7h8SNQa-XKdkxqBN6RkZs-AlW7b929W1EgHZ-oHDCaBtljJ6-CyWtT2CfGs6hdZL7LGJJeXHYaxNr0nD-YR8Ha13tD6zJWxkKoMLOe0oYF2Z1siNtW0vcy14R1PKrHp8VZORESAcq7lGPrhw1Gy_yAdF2oyMlvRW2w0qT7NyBVfyxdRDLE',
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            
            // Gradient Overlay (HTML lines 76-77)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF101922).withOpacity(0.2),
                      const Color(0xFF101922).withOpacity(0.6),
                      const Color(0xFF101922), // Solid dark at bottom for seamless transition
                    ],
                  ),
                ),
              ),
            ),

            // ── Background Decorative Elements (HTML lines 138-140) ──
            Positioned(
              top: MediaQuery.of(context).size.height * 0.2,
              right: -80,
              child: Container(
                width: 256,
                height: 256,
                decoration: BoxDecoration(
                  color: AppColors.skyBlue.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.1,
              left: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  color: AppColors.skyBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

            // ── 2. iOS Status Bar Simulation Area (Top Bar) (HTML lines 56-68) ──
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo Replace
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
                      // Daxil ol -> Qonaq olaraq davam et
                      InkWell(
                        onTap: () {
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
                                  Icon(Icons.person_outline_rounded, color: Colors.black87, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── 3. Hero Content (Bottom Aligned) (HTML lines 80-111) ──
            Positioned(
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).size.height * 0.15, // Adjusted to leave room for bottom nav if needed
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Floating Badge (HTML lines 82-86)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(
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
                            const Text(
                              '500+ PREMİUM KURS MÖVCUDDUR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Headline (HTML lines 87-90)
                  Text(
                    'Biliklə\nGələcəyini Qur',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Description (HTML lines 91-94)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Azərbaycanın ən qabaqcıl mütəxəssislərindən premium dərslər və peşəkar sertifikatlar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFE2E8F0), // text-slate-200
                        fontSize: 18,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Primary Action Card (Glassmorphism) (HTML lines 95-110)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24), // rounded-xl in tailwind
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () => context.go('/signup'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.skyBlue,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 56), // py-4
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)), // rounded-full
                                elevation: 8, // shadow-lg
                                shadowColor: AppColors.skyBlue.withOpacity(0.3),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Təlimlərə Başla', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 24),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Alumni Proof (HTML lines 101-109)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildAvatarGroup(),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'MƏZUN TƏRƏFİNDƏN TÖVSİYƏ EDİLİR',
                                    textAlign: TextAlign.right,
                                    maxLines: 2,
                                    style: TextStyle(
                                      color: Color(0xFF64748B), // text-slate-500
                                      fontSize: 10, // text-xs approx
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.0, // tracking-widest
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarGroup() {
    return SizedBox(
      width: 80,
      height: 32,
      child: Stack(
        children: [
          _buildAvatarItem(0, 'https://lh3.googleusercontent.com/aida-public/AB6AXuBovvNyvMDo7ID0SKFx0SP7BA_XDedgPqkjVF6YW99V4hK37dNbQt3cxkTsyG01pMGeVpyYv9PXB2-zFEeixYlpyFIwREZcK1rbM6B9P_Kojb8vA9y4i3L234ci_wj-MjzcHId8Vc82XaIkSSw_95sBulM989vEdZ2IOGbjYyPYS6BC1QIDbmhvp0NIHA7lqIdnMJyzMB0qDQ2M_phJ_1eOGd7wvehVcJw-M3VLTG9PtGp5TKJzi66fQMKJWzLoDK6yRRtByFAfK1o'),
          _buildAvatarItem(1, 'https://lh3.googleusercontent.com/aida-public/AB6AXuBgFyfeupPW249VuEwfZ2iYVP0EMdF88Aa6WShFyTaggWvaWppasMwOBK9qOCTbHwLREYaPbJPGQry3kkGFZPLCF-nP-8aYPDySOwgWwFegRDrV3nAf6KpzJtgWpt-guJxXD-XaXsQJTnJCqwrc1pOWpTEykmhXpn-FMZ4YAbyOqbAj19zBuSvbftgS4h6Ew-2f0kbl0wc9SCtVU7vIAHdtzK3QW71RYND3426SXnUsHSwlnQyx_X3UrotKrYiFUED9YhdwlhjuWQg'),
          _buildAvatarItem(2, 'https://lh3.googleusercontent.com/aida-public/AB6AXuCc8rCioTIelH89Q7nNK0ZV2mqjNBztdRpjLCzfiRnxOgNH3Zx1RfYSxuzWKtyQ_z_kJyxFsBKrD0uuXuN2OCAilnaXfBcefEOGb1UPdic4HFBtZJRythE545P8kBeHCixtdByi1vEYwZ_QhHldIPbQGkhG7Kc6JIuKCIeFU8a3k1JeA5wSnyXkeu0Muo2i0IeHwvwDQlowGjIOQyB33rpXX_ALzKChaOJIOIHkYsqmwTMvL6oxiBySzVKF32Hje6ghh0XDWipjg_Y'),
          Positioned(
            left: 48,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0), // bg-slate-200
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
      left: index * 16.0, // -space-x-2 in tailwind
      child: Container(
        width: 32, // w-8
        height: 32, // h-8
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
