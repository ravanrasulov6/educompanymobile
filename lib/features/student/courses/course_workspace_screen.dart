import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/haptic_service.dart';
import 'course_resources_screen.dart';
import 'package:provider/provider.dart';
import '../../../providers/student_provider.dart';

class CourseWorkspaceScreen extends StatefulWidget {
  final String courseId;
  final String lessonId;

  const CourseWorkspaceScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  @override
  State<CourseWorkspaceScreen> createState() => _CourseWorkspaceScreenState();
}

class _CourseWorkspaceScreenState extends State<CourseWorkspaceScreen> {
  int _selectedIndex = 0;
  final List<String> _tabs = ['Xülasə', 'Fayllar', 'Sual-Cavab'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().logActivity(
        type: 'lesson_view',
        courseId: widget.courseId,
        description: 'Dərsi izləməyə başladı',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Video background
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Video Player Area
            _buildVideoPlayer(),
            
            // Custom Segmented Control & Content Area (White/Dark Surface)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildSegmentedControl(),
                    const Divider(height: 32, thickness: 1),
                    Expanded(
                      child: _buildTabContent(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: Colors.black,
            child: const Center(
              child: Icon(Icons.play_circle_fill, color: Colors.white54, size: 72),
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 32),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedControl() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (_selectedIndex != index) {
                  HapticService.light();
                  setState(() => _selectedIndex = index);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? (isDark ? AppColors.darkSurface : Colors.white) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  _tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected 
                      ? (isDark ? Colors.white : Colors.black) 
                      : Colors.grey.shade500,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildFilesTab();
      case 2:
        return _buildQATab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          'Introduction to React Hooks',
          style: AppTextStyles.headlineMedium.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Dərs 1',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            const Text('14:30', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Detailed explanation of the lesson...',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildFilesTab() {
    // This connects to the File ingestion pipeline conceptually (UI part)
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      physics: const BouncingScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final files = ['Dərs Qeydləri.pdf', 'Tapşırıq_1.docx', 'Prezentasiya.pptx'];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.03) : Colors.grey.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(files[index], style: AppTextStyles.titleLarge.copyWith(fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('2.4 MB • AI tərəfindən oxunub', style: AppTextStyles.labelSmall.copyWith(color: AppColors.success)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  HapticService.light();
                  // Trigger download
                },
                icon: const Icon(Icons.download_rounded, color: AppColors.primary),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQATab() {
    // Embedded real chat experience component
    return const WorkspaceChatInterface();
  }
}

class WorkspaceChatInterface extends StatefulWidget {
  const WorkspaceChatInterface({super.key});

  @override
  State<WorkspaceChatInterface> createState() => _WorkspaceChatInterfaceState();
}

class _WorkspaceChatInterfaceState extends State<WorkspaceChatInterface> {
  final TextEditingController _messageController = TextEditingController();
  bool _isAiMode = true;
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Salam! Mən sizin AI Köməkçinizəm. Faylları və dərsi analiz etmişəm. Nə kimi sualınız var?',
      'isUser': false,
      'isAi': true,
      'sources': null,
    }
  ];

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    HapticService.light();
    setState(() {
      _messages.add({
        'text': text,
        'isUser': true,
      });
    });
    _messageController.clear();

    if (_isAiMode) {
      // Simulate streaming AI response
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          _messages.add({
            'text': '...',
            'isUser': false,
            'isAi': true,
            'isThinking': true,
          });
        });
        
        Future.delayed(const Duration(milliseconds: 1500), () {
            if (!mounted) return;
            setState(() {
              _messages.removeLast();
              _messages.add({
                'text': 'Bu sualınızın cavabı dərs qeydlərinin 2-ci səhifəsində izah edilmişdir. React Hooks state idarəetməsini funksional komponentlərə əlavə edir.',
                'isUser': false,
                'isAi': true,
                'sources': ['Dərs Qeydləri.pdf - Səhifə 2'],
              });
              HapticService.success();
            });
        });
      });
    } else {
      // Teacher mode message thread
      HapticService.success();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mode Toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildModeToggle(
                title: 'AI Köməkçi',
                icon: Icons.smart_toy_rounded,
                isSelected: _isAiMode,
                onTap: () {
                  HapticService.light();
                  setState(() => _isAiMode = true);
                },
              ),
              const SizedBox(width: 12),
              _buildModeToggle(
                title: 'Müəllimə Yaz',
                icon: Icons.person_rounded,
                isSelected: !_isAiMode,
                onTap: () {
                  HapticService.light();
                  setState(() => _isAiMode = false);
                },
              ),
            ],
          ),
        ),
        
        // Chat List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              return _buildChatBubble(msg);
            },
          ),
        ),
        
        // Input Area
        _buildInputArea(),
      ],
    );
  }

  Widget _buildModeToggle({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isSelected 
        ? AppColors.primary 
        : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1));
    final fgColor = isSelected 
        ? Colors.white 
        : (isDark ? Colors.white70 : Colors.black87);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: fgColor),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: fgColor, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> msg) {
    final isUser = msg['isUser'] == true;
    final isAi = msg['isAi'] == true;
    final isThinking = msg['isThinking'] == true;
    final sources = msg['sources'] as List<String>?;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser 
                    ? AppColors.primary 
                    : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1)),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
              ),
              child: isThinking
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? Colors.white54 : Colors.black54),
                        ),
                        const SizedBox(width: 10),
                        Text('AI yazır...', style: TextStyle(fontStyle: FontStyle.italic, color: isDark ? Colors.white54 : Colors.black54)),
                      ],
                    )
                  : Text(
                      msg['text'],
                      style: TextStyle(
                        color: isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
                        height: 1.4,
                        fontSize: 15,
                      ),
                    ),
            ),
            
            // Sources citation
            if (isAi && sources != null && sources.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.dataset_linked_rounded, size: 14, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text(
                      'Mənbə: ${sources[0]}',
                      style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () => HapticService.light(),
            icon: const Icon(Icons.attach_file_rounded),
            color: Colors.grey,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: _isAiMode ? 'Sualını yaz...' : 'Müəllimə yaz...',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
