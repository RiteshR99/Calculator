import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const calculator());}

class calculator extends StatelessWidget {
  const calculator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
