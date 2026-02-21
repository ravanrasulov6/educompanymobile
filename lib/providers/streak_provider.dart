import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StreakModel {
  final int currentStreak;
  final int longestStreak;
  final List<DateTime> history;
  final DateTime? lastActivityDate;

  StreakModel({
    required this.currentStreak,
    required this.longestStreak,
    required this.history,
    this.lastActivityDate,
  });

  factory StreakModel.fromJson(Map<String, dynamic> json) {
    return StreakModel(
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      history: (json['streak_history'] as List?)
          ?.map((d) => DateTime.parse(d as String))
          .toList() ?? [],
      lastActivityDate: json['last_activity_date'] != null 
          ? DateTime.parse(json['last_activity_date']) 
          : null,
    );
  }
}

class StreakProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  StreakModel? _streak;
  bool _isLoading = false;

  StreakModel? get streak => _streak;
  bool get isLoading => _isLoading;

  Future<void> loadStreakData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('user_streaks')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        _streak = StreakModel.fromJson(response);
      } else {
        // Create initial streak record if not exists
        final initial = await _supabase.from('user_streaks').insert({
          'user_id': userId,
          'current_streak': 0,
          'longest_streak': 0,
          'streak_history': [],
        }).select().single();
        _streak = StreakModel.fromJson(initial);
      }
    } catch (e) {
      debugPrint('Error loading streak data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
