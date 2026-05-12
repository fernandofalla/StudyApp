import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adaptamat/core/database/database_helper.dart';
import 'package:adaptamat/data/datasources/item_sesion_datasource.dart';
import 'package:adaptamat/domain/entities/item.dart';

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

  // Cargar banco de ítems si está vacío
  try {
    final itemDatasource = ItemDatasource();
    final bancoVacio = await itemDatasource.bancoVacio();
    
    if (bancoVacio) {
      // Cargar JSON desde assets
      final jsonString = await rootBundle.loadString('assets/items/banco_items.json');
      final List<dynamic> jsonData = jsonDecode(jsonString);
      
      // Convertir a objetos Item
      final items = jsonData.map((item) {
        return Item(
          tema: item['tema'] as String,
          subtema: item['subtema'] as String,
          dificultadB: (item['dificultad_b'] as num).toDouble(),
          enunciado: item['enunciado'] as String,
          opciones: List<String>.from(item['opciones'] as List),
          respuestaCorrecta: item['respuesta_correcta'] as int,
          codigoPatronDistractor: item['codigo_patron_distractor'] as String,
        );
      }).toList();
      
      // Insertar lote de ítems
      await itemDatasource.insertarLote(items);
      // ignore: avoid_print
      print('✓ Banco de ítems cargado: ${items.length} ítems insertados');
    } else {
      // ignore: avoid_print
      print('✓ Banco de ítems ya existe en base de datos');
    }
  } catch (e) {
    // ignore: avoid_print
    print('✗ Error al cargar banco de ítems: $e');
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
