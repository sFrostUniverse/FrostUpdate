import 'package:flutter/material.dart';
import 'screens/update_screen.dart';

void main() {
  runApp(const FrostUpdateApp());
}

class FrostUpdateApp extends StatelessWidget {
  const FrostUpdateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FrostUpdate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const UpdateScreen(),
    );
  }
}
