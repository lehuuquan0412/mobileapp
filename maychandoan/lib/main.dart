import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyA-nygNJcschiZzbiGZqh2XRkndSFyeuzU",
          appId: "484558138052:android:60f057c4217b1b28f27791",
          messagingSenderId: "484558138052",
          projectId: "test-b0897"));
  FirebaseDatabase.instance.databaseURL =
      'https://test-b0897-default-rtdb.asia-southeast1.firebasedatabase.app';
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: LoginPage(),
    );
  }
}
