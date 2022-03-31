// ignore_for_file: prefer_const_constructors

import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jeffrey_dev/event_provider.dart';
import 'package:provider/provider.dart';

class EventPage extends StatefulWidget {
  const EventPage({Key? key}) : super(key: key);

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              TextField(decoration: InputDecoration(hintText: "Name:")),
              TimePickerDialog(initialTime: TimeOfDay.now()),
              SwitchListTile(
                title: Text('Reminder?'),
                value: true,
                onChanged: (changed) {},
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.pop(context),
          ),
        );
      },
    );
  }
}
