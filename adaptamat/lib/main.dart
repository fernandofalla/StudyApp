import 'package:flutter/material.dart';
import 'package:adaptamat/core/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Verificar inicialización de base de datos
  try {
    // ignore: unused_local_variable
    final db = await DatabaseHelper().database;
    // ignore: avoid_print
    print('✓ Base de datos inicializada correctamente');
  } catch (e) {
    // ignore: avoid_print
    print('✗ Error al inicializar base de datos: $e');
  }
  
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
