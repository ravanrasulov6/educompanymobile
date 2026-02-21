import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/haptic_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? shadow;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.blur = 15,
    this.color,
    this.border,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ?? Border.all(color: Colors.black.withValues(alpha: 0.05)),
            boxShadow: shadow ?? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class PremiumSegmentedControl extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final Function(int) onValueChanged;

  const PremiumSegmentedControl({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Slate-100
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)), // Slate-200
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onValueChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ] : null,
                ),
                child: Text(
                  items[index],
                  style: AppTextStyles.titleSmall.copyWith(
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class StatChipsRow extends StatelessWidget {
  final List<StatChipItem> stats;
  const StatChipsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: stats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = stats[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticService.light();
                item.onTap?.call();
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: item.color.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, color: item.color, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      item.label,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: item.color.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.value,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: const Color(0xFF0F172A), // Slate-900
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


class StatChipItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  StatChipItem({
    required this.label, 
    required this.value, 
    required this.icon, 
    required this.color,
    this.onTap,
  });
}

class StepperPill extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  const StepperPill({super.key, required this.totalSteps, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        return Container(
          width: index == currentStep ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.white24,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class PremiumActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  const PremiumActionTile({super.key, required this.title, required this.subtitle, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: AppTextStyles.titleMedium.copyWith(color: const Color(0xFF0F172A))),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF64748B))),
        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
      ),
    );
  }
}

class ExamCard extends StatelessWidget {
  final String title;
  final String time;
  final int questionCount;
  final VoidCallback onTap;
  const ExamCard({super.key, required this.title, required this.time, required this.questionCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE2E8F0)), // Slate-200
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.assignment_rounded, color: AppColors.accent, size: 20),
          ),
          const Spacer(),
          Text(title, style: AppTextStyles.titleMedium.copyWith(color: const Color(0xFF0F172A))),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(time, style: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF64748B))),
            ],
          ),
        ],
      ),
    );
  }
}

class DraftAutosaveIndicator extends StatelessWidget {
  final bool isSaving;
  const DraftAutosaveIndicator({super.key, required this.isSaving});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isSaving 
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
              const SizedBox(width: 8),
              Text('Yadda saxlanılır...', style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.success),
              const SizedBox(width: 8),
              Text('Yadda saxlanıldı', style: AppTextStyles.bodySmall.copyWith(color: AppColors.success)),
            ],
          ),
    );
  }
}

class ChatComposer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const ChatComposer({super.key, required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Color(0xFF0F172A)),
              decoration: const InputDecoration(
                hintText: 'Mesajınızı yazın...',
                hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: onSend,
            icon: const Icon(Icons.send_rounded, color: AppColors.primary),
            style: IconButton.styleFrom(backgroundColor: AppColors.primary.withValues(alpha: 0.1)),
          ),
        ],
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final val = Curves.easeInOut.transform((_controller.value + delay) % 1.0);
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2 + (val * 0.5)),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

class WizardScaffold extends StatelessWidget {
  final String title;
  final int totalSteps;
  final int currentStep;
  final Widget body;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final bool isLastStep;

  const WizardScaffold({
    super.key,
    required this.title,
    required this.totalSteps,
    required this.currentStep,
    required this.body,
    required this.onNext,
    required this.onBack,
    this.isLastStep = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(title, style: AppTextStyles.titleLarge.copyWith(color: const Color(0xFF0F172A))),
        centerTitle: true,
        leading: currentStep > 0 ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack, color: const Color(0xFF0F172A)) : null,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: StepperPill(totalSteps: totalSteps, currentStep: currentStep),
          ),
          Expanded(child: body),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(isLastStep ? 'Bitir' : 'Növbəti', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QuestionEditor extends StatelessWidget {
  final String label;
  final String value;
  final Function(String) onChanged;
  final String hint;

  const QuestionEditor({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint = 'Cavabınızı bura yazın...',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
        const SizedBox(height: 12),
        GlassCard(
          padding: EdgeInsets.zero,
          child: TextField(
            onChanged: onChanged,
            maxLines: 6,
            style: const TextStyle(color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String content;
  final bool isMe;
  final DateTime timestamp;

  const MessageBubble({
    super.key,
    required this.content,
    required this.isMe,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
          border: isMe ? null : Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content, style: TextStyle(color: isMe ? Colors.white : const Color(0xFF0F172A), fontSize: 15)),
            const SizedBox(height: 4),
            Text(
              '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(color: isMe ? Colors.white70 : const Color(0xFF64748B), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
