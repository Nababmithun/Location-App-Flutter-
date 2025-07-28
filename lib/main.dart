import 'package:flutter/material.dart';
import 'package:flutterlocationapp/map_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Geo Location App',
      debugShowCheckedModeBanner: false,
      home: MapScreen(),
    );
  }
}