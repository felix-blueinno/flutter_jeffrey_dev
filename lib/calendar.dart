import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jeffrey_dev/event.dart';
import 'package:flutter_jeffrey_dev/theme_controller.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  CalendarFormat _calendarFormat = CalendarFormat.month;

  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();

  List<Event> events = [];

  @override
  void initState() {
    DateTime now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
    _focusedDay = DateTime(now.year, now.month, now.day);

    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('events')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        events = [];
        for (var doc in snapshot.docs) {
          setState(() {
            final e = Event(
              title: doc.data()['title'] as String,
              date: DateTime.parse(doc.data()['date'] as String),
              description: doc.data()['description'] as String,
              startTime: TimeOfDay(
                hour: int.parse(doc.data()['startTime'].split(':')[0]),
                minute: int.parse(doc.data()['startTime'].split(':')[1]),
              ),
              endTime: TimeOfDay(
                hour: int.parse(doc.data()['endTime'].split(':')[0]),
                minute: int.parse(doc.data()['endTime'].split(':')[1]),
              ),
              docId: doc.id,
            );

            events.add(e);
          });
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => newEvent(context).whenComplete(() {
          _startController.clear();
          _endController.clear();
        }),
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_sharp),
            onPressed: () => setState(() => _focusedDay = DateTime.now()),
          ),
        ],
      ),
      drawer: buildDrawer(context),
      body: Column(
        children: [
          calendar(),
          const SizedBox(height: 16),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: eventList(),
          )),
        ],
      ),
    );
  }

  ListView eventList() {
    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(),
      itemCount: events.where((e) => isSameDay(e.date, _selectedDay)).length,
      itemBuilder: (context, index) {
        final selectedEvents =
            events.where((e) => isSameDay(e.date, _selectedDay)).toList();

        if (selectedEvents.isNotEmpty) {
          selectedEvents.sort((a, b) {
            /*
                return 
                      negative value if this TimeOfDay [isBefore].
                      0 if this TimeOfDay [isAtSameMomentAs], and
                      positive value otherwise (when this TimeOfDay [isAfter]).
              */
            if (a.startTime.hour < b.startTime.hour) {
              return -1;
            } else if (a.startTime.hour > b.startTime.hour) {
              return 1;
            } else {
              if (a.startTime.minute < b.startTime.minute) {
                return -1;
              } else if (a.startTime.minute > b.startTime.minute) {
                return 1;
              } else {
                return 0;
              }
            }
          });

          String title = selectedEvents[index].title;
          String description = selectedEvents[index].description.isEmpty
              ? 'No description'
              : selectedEvents[index].description;

          TimeOfDay startTime = selectedEvents[index].startTime;
          TimeOfDay endTime = selectedEvents[index].endTime;

          TextStyle contentStyle = TextStyle(
              fontSize: 16,
              color:
                  Colors.primaries[index % Colors.primaries.length].shade100);

          return Dismissible(
            key: UniqueKey(),
            onDismissed: (direction) {
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('events')
                  .doc(selectedEvents[index].docId)
                  .delete();

              setState(() => events.remove(selectedEvents[index]));
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors
                    .primaries[index % Colors.primaries.length].shade800
                    .withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors
                                  .primaries[index % Colors.primaries.length]
                                  .shade100),
                        ),
                        const SizedBox(height: 8),
                        Text(description, style: contentStyle),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.av_timer_rounded,
                                color: Colors.white54),
                            const SizedBox(width: 8),
                            Text(
                              '${startTime.format(context)} - ${endTime.format(context)}',
                              style: contentStyle,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const ListTile(
            title: Text(
          'No events on this day',
          style: TextStyle(color: Colors.white),
        ));
      },
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
                decoration: const InputDecoration(hintText: 'Title'),
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
                      decoration: const InputDecoration(
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
                      decoration: const InputDecoration(
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
                  decoration: const InputDecoration(hintText: 'Description'),
                  onChanged: (value) => description = value,
                ),
              ),

              const SizedBox(height: 16),

              /// Save button
              SizedBox(
                width: double.infinity,
                child: TextButton(
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
                        .then((value) => Navigator.of(ctx).pop())
                        .catchError((error) => print(error));
                  },
                  child: const Text('Save'),
                ),
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
          const DrawerHeader(child: Icon(Icons.account_circle, size: 48)),

          ListTile(
            title: const Text('Week'),
            leading: const Icon(Icons.calendar_view_week),
            onTap: () {
              setState(() {
                _calendarFormat = CalendarFormat.week;

                Navigator.pop(context);
              });
            },
          ),

          ListTile(
            title: const Text('Month'),
            leading: const Icon(Icons.calendar_month),
            onTap: () {
              setState(() {
                _calendarFormat = CalendarFormat.month;
                Navigator.pop(context);
              });
            },
          ),

          ListTile(
            title: const Text('Change theme'),
            leading: const Icon(Icons.color_lens),
            onTap: () => Theme.of(context).brightness == Brightness.light
                ? ThemeController.isLightTheme.add(false)
                : ThemeController.isLightTheme.add(true),
          ),

          ListTile(
            title: const Text('Settings'),
            leading: const Icon(Icons.settings),
            onTap: () {},
          ),

          ListTile(
            title: const Text('Logout'),
            leading: const Icon(Icons.exit_to_app),
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
      headerStyle: const HeaderStyle(formatButtonVisible: false),
      calendarStyle: CalendarStyle(
        markerDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
      ),
      eventLoader: (date) {
        return events.where((event) {
          return isSameDay(event.date, date);
        }).toList();
      },
    );
  }
}
