import 'package:flutter/material.dart';

/// A wrapper that provides a subtle fade-in and slide-up animation for its child.
class EntranceAnimation extends StatelessWidget {
  final Widget child;
  final Duration delay;

  const EntranceAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Padding(
          padding: EdgeInsets.only(top: 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: FutureBuilder(
        future: Future.delayed(delay),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return child;
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
