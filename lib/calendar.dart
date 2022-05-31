// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jeffrey_dev/event.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  CalendarFormat _calendarFormat = CalendarFormat.month;

  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print(_selectedDay.toString());
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => newEvent(context).whenComplete(() {
          _startController.clear();
          _endController.clear();
        }),
        child: Icon(Icons.add),
      ),
      appBar: AppBar(title: Text('Calendar')),
      drawer: buildDrawer(context),
      body: Column(
        children: [
          calendar(),
          Expanded(child: ListView()),
        ],
      ),
    );
  }

  Future<void> newEvent(BuildContext context) {
    String title = '';
    String description = '';
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    return showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// Modal Sheet title
              Text(
                'Add new event',
                style: Theme.of(ctx).textTheme.headline5,
              ),

              const SizedBox(height: 16),

              /// Title field
              TextField(
                decoration: InputDecoration(hintText: 'Title'),
                onChanged: (value) => title = value,
              ),

              const SizedBox(height: 16),

              /// Time-range row:
              Row(
                children: [
                  /// start time picker:
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      controller: _startController,
                      decoration: InputDecoration(
                          hintText: 'Starts',
                          prefixIcon: Icon(Icons.access_time)),
                      onTap: () {
                        Navigator.of(ctx)
                            .push(showPicker(
                                value: TimeOfDay.now(), onChange: (_) {}))
                            .then((value) {
                          if (value != null) {
                            startTime = value;
                            _startController.text = startTime!.format(ctx);
                          }
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 16),

                  /// end time picker:
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      controller: _endController,
                      decoration: InputDecoration(
                          hintText: 'End', prefixIcon: Icon(Icons.access_time)),
                      onTap: () {
                        Navigator.of(ctx)
                            .push(showPicker(
                                value: TimeOfDay.now(), onChange: (_) {}))
                            .then((value) {
                          if (value != null) {
                            endTime = value;
                            _endController.text = endTime!.format(ctx);
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: TextField(
                  expands: true,
                  minLines: null,
                  maxLines: null,
                  decoration: InputDecoration(hintText: 'Description'),
                ),
              ),

              const SizedBox(height: 16),

              /// Save button
              TextButton(
                onPressed: () {
                  if (title.isEmpty || startTime == null || endTime == null) {
                    return;
                  }

                  final event = Event(
                    title: title,
                    date: _selectedDay,
                    description: description,
                    startTime: startTime!,
                    endTime: endTime!,
                  );

                  CollectionReference users =
                      FirebaseFirestore.instance.collection('users');

                  users
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('events')
                      .add(event.toJson())
                      .then((value) => print(value))
                      .catchError((error) => print(error));
                },
                child: Text('Save'),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // drawer header
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.account_circle, size: 48),
                // Text(FirebaseAuth.instance.currentUser!.email.toString()),
                Text(FirebaseAuth.instance.currentUser!.uid),
              ],
            ),
          ),

          ListTile(
            title: Text('Week'),
            leading: Icon(Icons.calendar_view_week),
            onTap: () {
              setState(() {
                _calendarFormat = CalendarFormat.week;

                Navigator.pop(context);
              });
            },
          ),

          ListTile(
            title: Text('Month'),
            leading: Icon(Icons.calendar_month),
            onTap: () {
              setState(() {
                _calendarFormat = CalendarFormat.month;
                Navigator.pop(context);
              });
            },
          ),

          ListTile(
            title: Text('Settings'),
            leading: Icon(Icons.settings),
            onTap: () {},
          ),

          ListTile(
            title: Text('Logout'),
            leading: Icon(Icons.exit_to_app),
            onTap: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
    );
  }

  Widget calendar() {
    return TableCalendar(
      currentDay: DateTime.now(),
      focusedDay: _focusedDay,
      firstDay: DateTime(2000),
      lastDay: DateTime(2040),
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      headerStyle: HeaderStyle(formatButtonVisible: false),
    );
  }
}
