// lib/data/datasources/estudiante_datasource.dart
// Capa de datos — Acceso a datos de estudiantes en SQLite

import 'package:adaptamat/core/database/database_helper.dart';
import 'package:adaptamat/domain/entities/estudiante.dart';

class EstudianteDatasource {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertar(Estudiante estudiante) async {
    final db = await _dbHelper.database;
    return await db.insert('estudiante', {
      'nombre': estudiante.nombre,
      'grado': estudiante.grado,
      'theta_actual': estudiante.thetaActual,
      'fecha_registro': estudiante.fechaRegistro.toIso8601String(),
    });
  }

  Future<List<Estudiante>> obtenerTodos() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('estudiante');

    return List<Estudiante>.from(maps.map((map) {
      return Estudiante(
        id: map['id'],
        nombre: map['nombre'],
        grado: map['grado'],
        thetaActual: map['theta_actual'],
        fechaRegistro: DateTime.parse(map['fecha_registro']),
      );
    }));
  }

  Future<Estudiante?> obtenerPorId(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'estudiante',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    final map = maps.first;
    return Estudiante(
      id: map['id'],
      nombre: map['nombre'],
      grado: map['grado'],
      thetaActual: map['theta_actual'],
      fechaRegistro: DateTime.parse(map['fecha_registro']),
    );
  }

  Future<void> actualizarTheta(int id, double nuevoTheta) async {
    final db = await _dbHelper.database;
    await db.update(
      'estudiante',
      {'theta_actual': nuevoTheta},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
