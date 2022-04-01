import 'package:flutter/material.dart';

class EventProvider extends ChangeNotifier {
  final List<Map> _events = [];
  List<Map> get events => _events;

  void update(Map event) {
    _events.add(event);
    notifyListeners();
  }

  List<Map> getEvents(DateTime selectedDay) {
    List<Map> list = [];
    for (var item in _events) {
      DateTime storedDate = item['date'];
      if (storedDate.year == selectedDay.year &&
          storedDate.month == selectedDay.month &&
          storedDate.day == selectedDay.day) {
        list.add(item);
      }
    }

    return list;
  }
}
