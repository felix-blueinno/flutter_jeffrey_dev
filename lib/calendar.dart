// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_jeffrey_dev/event_page.dart';
import 'package:flutter_jeffrey_dev/event_provider.dart';
import 'package:provider/provider.dart';
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
        onPressed: () => showDialog(
          context: context,
          builder: (context) => EventPage(_selectedDay),
        ),
        child: Icon(Icons.add),
      ),
      appBar: AppBar(title: Text('Calendar')),
      body: Column(
        children: [
          calendar(),
          events(),
        ],
      ),
    );
  }

  Widget events() {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) => Expanded(
        child: ListView.builder(
          itemCount: eventProvider.getEvents(_selectedDay).length,
          itemBuilder: (context, index) {
            Map event = eventProvider.getEvents(_selectedDay)[index];

            String eventName = event['name'];
            TimeOfDay fromTime = event['from'];
            TimeOfDay toTime = event['to'];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Event: '),
                  Text(eventName),
                  Text('From: '),
                  Text(fromTime.format(context)),
                  Text('To: '),
                  Text(toTime.format(context)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget calendar() {
    return TableCalendar(
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
      calendarStyle: CalendarStyle(
        selectedDecoration:
            BoxDecoration(color: Colors.teal[500], shape: BoxShape.circle),
        todayDecoration:
            BoxDecoration(color: Colors.teal[300], shape: BoxShape.circle),
      ),
      headerStyle: HeaderStyle(
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.teal),
        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.teal),
        formatButtonVisible: false,
      ),
    );
  }
}
