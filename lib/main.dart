import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialize the firebase
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late DatabaseReference _logsRef;
  StreamSubscription? _logsSubscription;

  @override
  void initState() {
    super.initState();
    _logsRef = FirebaseDatabase.instance.reference().child('data_logs');
    // fetch the logs which are not logged i.e which have the parameter is_logged = false.
    _logsRef.orderByChild('isLogged').equalTo(false).onValue.listen((event) {
      Map<dynamic, dynamic> snapshot = event.snapshot.value ?? {};
      List<DataLog> dataLogs = [];

      List<String> notLoggedIds = [];

      for (dynamic key in snapshot.keys) {
        dynamic value = snapshot[key];
        bool isLogged = value['isLogged'];
        dataLogs.add(DataLog(id: value['id'], isLogged: isLogged));

        // add the key to list to set the isLogged to true
        notLoggedIds.add(key);
      }

      if (notLoggedIds.isNotEmpty) {
        // we have the logs which have isLogged equal to false.
        // set them to true.

        var updates = <String, dynamic>{};
        for (var id in notLoggedIds) {
          updates["$id/isLogged"] = true;
        }

        /// Issue: We are updating the data with the following updates. But the stream is not completed yet.
        /// this will again send an event to stream which throws the exception on web but not on mobile.
        ///
        /// After debugging, It seems that the dart firebase_database_web creates a synchronous stream.
        /// see <https://github.com/FirebaseExtended/flutterfire/blob/cb510af6b401e909a883dcd8c17eadecf77016e1/packages/firebase_database/firebase_database_web/lib/src/interop/database.dart#L362>
        ///
        /// If we add some delay (like 500 millis) here before updating the data then it will work fine.
        _logsRef.update(updates);
      }

      debugPrint(dataLogs.toString());
    });
  }

  @override
  void dispose() {
    _logsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text(
          'Click on the following Floating button and see the console.',
          style: TextStyle(color: Colors.black),
          textAlign: TextAlign.center,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewLog,
        child: const Icon(Icons.add),
      ),
    );
  }

  // add a new log
  void addNewLog() {
    String id = _logsRef.push().key;
    _logsRef.child(id).set(DataLog(id: id).toMap());
  }
}

class DataLog {
  final String id;
  final bool isLogged;

  DataLog({
    required this.id,
    this.isLogged = false,
  });

  @override
  String toString() {
    return "id: $id, isLogged: $isLogged";
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isLogged': isLogged,
    };
  }
}
