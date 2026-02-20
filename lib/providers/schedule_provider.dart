import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/schedule_model.dart';

/// Manages schedule state
class ScheduleProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<ScheduleModel> _events = [];
  DateTime _selectedDay = DateTime.now();
  bool _isLoading = false;

  List<ScheduleModel> get events => _events;
  DateTime get selectedDay => _selectedDay;
  bool get isLoading => _isLoading;

  /// Events for the selected day
  List<ScheduleModel> get selectedDayEvents {
    return _events.where((e) {
      return e.dateTime.year == _selectedDay.year &&
          e.dateTime.month == _selectedDay.month &&
          e.dateTime.day == _selectedDay.day;
    }).toList();
  }

  Future<void> loadSchedule() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('schedules')
          .select('*, course:courses(title)');
      
      _events = (response as List)
          .map((json) => ScheduleModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading schedule: $e');
      if (_events.isEmpty) {
        _events = ScheduleModel.demoSchedule;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectDay(DateTime day) {
    _selectedDay = day;
    notifyListeners();
  }
}
