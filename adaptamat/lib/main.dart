import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:adaptamat/core/database/database_helper.dart';
import 'package:adaptamat/data/datasources/dashboard_datasource.dart';
import 'package:adaptamat/domain/usecases/resumen_grupo.dart';
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
  } catch (_) {}

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
          codigoPatronDistractor: e['codigo_patron_distractor'] as String?,
          figura: e['figura'] as String?,
        );
      }).toList();
      await itemDs.insertarLote(items);
    }
  } catch (_) {}

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
    }
  } catch (_) {}

  // VERIFICACIÓN TEMPORAL — eliminar antes de entrega
  // ignore: avoid_print
  print(ResumenGrupo.nivelDesdeTheta(-0.5)); // Inicio
  // ignore: avoid_print
  print(ResumenGrupo.nivelDesdeTheta(0.5));  // En proceso
  // ignore: avoid_print
  print(ResumenGrupo.nivelDesdeTheta(1.2));  // Logrado
  try {
    final dashDs = DashboardDatasource();
    final resumen = await dashDs.obtenerResumenGrupo();
    // ignore: avoid_print
    print('[DashboardDatasource] obtenerResumenGrupo → ${resumen.length} filas: $resumen');
  } catch (e) {
    // ignore: avoid_print
    print('[DashboardDatasource] error en verificación: $e');
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
