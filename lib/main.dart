// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jeffrey_dev/event_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'calendar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ChangeNotifierProvider(
    create: (context) => EventProvider(),
    child: MaterialApp(
      routes: {
        '/calendar': (context) => CalendarPage(),
      },
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: ThemeData.dark().copyWith(useMaterial3: true),
    ),
  ));
}

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
                ImagePicker _picker = ImagePicker();
                XFile? pickedImage =
                    await _picker.pickImage(source: ImageSource.gallery);

                if (pickedImage != null) {
                  if (kIsWeb) {
                    var bytes = await pickedImage.readAsBytes();
                    image = Image.memory(bytes);
                  } else {
                    var file = File(pickedImage.path);
                    image = Image.file(file);
                  }

                  setState(() {});
                }
              },
              child: image,
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/calendar'),
            child: Text('Calendar'),
          ),
        ],
      ),
    );
  }
}
