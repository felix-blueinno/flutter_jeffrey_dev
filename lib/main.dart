// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jeffrey_dev/calendar.dart';
import 'package:flutter_jeffrey_dev/event.dart';
import 'package:flutter_jeffrey_dev/event_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:provider/provider.dart';

main() => runApp(ChangeNotifierProvider(
      create: (context) => EventProvider(),
      child: MaterialApp(
        routes: {
          '/calendar': (context) => CalendarPage(),
          '/event': (context) => EventPage(),
        },
        home: HomePage(),
      ),
    ));

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Image image = Image.network(
    'https://picsum.photos/id/0/5616/3744',
    fit: BoxFit.fill,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 20,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Time: ',
                    style: TextStyle(fontSize: 48),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(DateTime.now().toString()),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 60,
            child: GestureDetector(
              onTap: () async {
                if (kIsWeb) {
                  // Web:
                  Image? pickedImage = await ImagePickerWeb.getImageAsWidget();
                  if (pickedImage != null) {
                    image = pickedImage;
                    setState(() {});
                  }
                } else {
                  // Mobile:
                  ImagePicker _picker = ImagePicker();
                  XFile? pickedImage =
                      await _picker.pickImage(source: ImageSource.gallery);

                  if (pickedImage != null) {
                    var file = File(pickedImage.path);
                    image = Image.file(file);
                    setState(() {});
                  }
                }
              },
              child: image,
            ),
          ),
          Expanded(
            flex: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Schedule'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    //     shape: CircleBorder(),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/calendar'),
                  child: Text('Calendar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
