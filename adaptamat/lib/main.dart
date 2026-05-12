import 'package:flutter/material.dart';

void main() {
  runApp(const AdaptaMatApp());
}

class AdaptaMatApp extends StatelessWidget {
  const AdaptaMatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AdaptaMat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'AdaptaMat',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
