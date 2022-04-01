// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jeffrey_dev/event_provider.dart';
import 'package:provider/provider.dart';

class EventPage extends StatefulWidget {
  final DateTime selectedDay;
  const EventPage(this.selectedDay, {Key? key}) : super(key: key);

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final TextEditingController _textEditingController = TextEditingController();

  late TimeOfDay _fromTime;
  late TimeOfDay _toTime;

  bool _remind = true;

  @override
  void initState() {
    _fromTime = TimeOfDay.now();
    _toTime = TimeOfDay.fromDateTime(DateTime.now().add(Duration(minutes: 30)));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: InkWell(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.chevron_left),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Map event = {
                      'from': _fromTime,
                      'to': _toTime,
                      'remind': _remind,
                      'name': _textEditingController.text,
                      'date': widget.selectedDay
                    };

                    eventProvider.update(event);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.tealAccent),
                  ))
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8 * 2),
              child: Column(
                children: [
                  TextField(
                    controller: _textEditingController,
                    style: TextStyle(fontSize: 24),
                    decoration: InputDecoration(
                      hintText: "Remind me...",
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 8 * 2),
                    ),
                  ),
                  SwitchListTile(
                    title: Row(
                      children: [
                        Icon(Icons.alarm),
                        SizedBox(width: 8),
                        Text('Reminder?'),
                      ],
                    ),
                    value: _remind,
                    onChanged: (changed) {
                      _remind = changed;
                      setState(() {});
                    },
                  ),
                  Wrap(
                    children: [
                      SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8 * 5),
                        child: Text(
                          'From: ',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      createInlinePicker(
                        value: _fromTime,
                        onChange: (changedTime) => _fromTime = changedTime,
                        is24HrFormat: true,
                        okText: '',
                        cancelText: '',
                        displayHeader: true,
                        isOnChangeValueMode: true,
                        elevation: 0,
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8 * 5),
                        child: Text(
                          'To: ',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      createInlinePicker(
                        value: _toTime,
                        onChange: (changedTime) => _toTime = changedTime,
                        is24HrFormat: true,
                        okText: '',
                        cancelText: '',
                        displayHeader: true,
                        isOnChangeValueMode: true,
                        elevation: 0,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
