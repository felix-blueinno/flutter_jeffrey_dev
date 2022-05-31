import 'package:flutter/material.dart';

class Event {
  final String title;
  final DateTime date;
  final String description;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  String docId;

  Event({
    required this.title,
    required this.date,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.docId = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date.toString(),
      'description': description,
      'startTime':
          startTime.hour.toString() + ':' + startTime.minute.toString(),
      'endTime': endTime.hour.toString() + ':' + endTime.minute.toString(),
    };
  }
}
