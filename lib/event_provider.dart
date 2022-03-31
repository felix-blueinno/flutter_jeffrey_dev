import 'package:flutter/material.dart';

class EventProvider extends ChangeNotifier {
  final List<Map> _events = [];
  List<Map> get events => _events;

  void update(Map event) {
    _events.add(event);
    notifyListeners();
  }
}
