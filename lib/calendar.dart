import 'package:flutter/material.dart';
import 'package:flutter_jeffrey_dev/event.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  var _selectedDay = DateTime.now();
  var _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            showDialog(context: context, builder: (context) => EventPage()),
        child: Icon(Icons.add),
      ),
      body: TableCalendar(
        currentDay: DateTime.now(),
        focusedDay: _focusedDay,
        firstDay: DateTime(2000),
        lastDay: DateTime(2040),
        calendarFormat: CalendarFormat.month,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          setState(() {});
        },
      ),
    );
  }
}
