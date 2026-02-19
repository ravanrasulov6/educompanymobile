import 'package:flutter/material.dart';
import '../models/schedule_model.dart';

/// Manages schedule state
class ScheduleProvider extends ChangeNotifier {
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

    await Future.delayed(const Duration(milliseconds: 400));

    _events = ScheduleModel.demoSchedule;
    _isLoading = false;
    notifyListeners();
  }

  void selectDay(DateTime day) {
    _selectedDay = day;
    notifyListeners();
  }
}
