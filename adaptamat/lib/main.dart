import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:adaptamat/core/database/database_helper.dart';
import 'package:adaptamat/data/datasources/estudiante_datasource.dart';
import 'package:adaptamat/data/datasources/item_sesion_datasource.dart';
import 'package:adaptamat/domain/entities/estudiante.dart';
import 'package:adaptamat/domain/entities/item.dart';
import 'package:adaptamat/presentation/blocs/sesion_bloc.dart';
import 'package:adaptamat/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar base de datos
  try {
    await DatabaseHelper().database;
    // ignore: avoid_print
    print('✓ Base de datos inicializada');
  } catch (e) {
    // ignore: avoid_print
    print('✗ Error BD: $e');
  }

  // Cargar banco de ítems si está vacío
  try {
    final itemDs = ItemDatasource();
    if (await itemDs.bancoVacio()) {
      final jsonString =
          await rootBundle.loadString('assets/items/banco_items.json');
      final items = (jsonDecode(jsonString) as List).map((e) {
        return Item(
          tema: e['tema'] as String,
          subtema: e['subtema'] as String,
          dificultadB: (e['dificultad_b'] as num).toDouble(),
          enunciado: e['enunciado'] as String,
          opciones: List<String>.from(e['opciones'] as List),
          respuestaCorrecta: e['respuesta_correcta'] as int,
          codigoPatronDistractor: e['codigo_patron_distractor'] as String,
        );
      }).toList();
      await itemDs.insertarLote(items);
      // ignore: avoid_print
      print('✓ Banco de ítems cargado: ${items.length} ítems');
    }
  } catch (e) {
    // ignore: avoid_print
    print('✗ Error banco: $e');
  }

  // Crear estudiante de prueba si no existe ninguno
  try {
    final estudianteDs = EstudianteDatasource();
    final todos = await estudianteDs.obtenerTodos();
    if (todos.isEmpty) {
      await estudianteDs.insertar(Estudiante(
        nombre: 'Estudiante Demo',
        grado: '1ro Primaria',
        thetaActual: 0.0,
        fechaRegistro: DateTime.now(),
      ));
      // ignore: avoid_print
      print('✓ Estudiante de prueba creado');
    }
  } catch (e) {
    // ignore: avoid_print
    print('✗ Error estudiante: $e');
  }

  runApp(const AdaptaMatApp());
}

class AdaptaMatApp extends StatelessWidget {
  const AdaptaMatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SesionBloc(),
      child: MaterialApp(
        title: 'AdaptaMat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F3864)),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
