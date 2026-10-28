// lib/data/datasources/estudiante_datasource.dart
// Capa de datos — Acceso a datos de estudiantes en SQLite

import 'package:adaptamat/core/constants/database_constants.dart';
import 'package:adaptamat/core/database/database_helper.dart';
import 'package:adaptamat/domain/entities/estudiante.dart';

class EstudianteDatasource {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertar(Estudiante estudiante) async {
    final db = await _dbHelper.database;
    return await db.insert(DatabaseConstants.tableEstudiante, {
      DatabaseConstants.colEstudianteNombre: estudiante.nombre,
      DatabaseConstants.colEstudianteGrado: estudiante.grado,
      DatabaseConstants.colEstudianteThetaActual: estudiante.thetaActual,
      DatabaseConstants.colEstudianteFechaRegistro: estudiante.fechaRegistro.toIso8601String(),
    });
  }

  Future<List<Estudiante>> obtenerTodos() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(DatabaseConstants.tableEstudiante);

    return List<Estudiante>.from(maps.map((map) {
      return Estudiante(
        id: map[DatabaseConstants.colEstudianteId],
        nombre: map[DatabaseConstants.colEstudianteNombre],
        grado: map[DatabaseConstants.colEstudianteGrado],
        thetaActual: map[DatabaseConstants.colEstudianteThetaActual],
        fechaRegistro: DateTime.parse(map[DatabaseConstants.colEstudianteFechaRegistro]),
      );
    }));
  }

  Future<Estudiante?> obtenerPorId(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableEstudiante,
      where: '${DatabaseConstants.colEstudianteId} = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    final map = maps.first;
    return Estudiante(
      id: map[DatabaseConstants.colEstudianteId],
      nombre: map[DatabaseConstants.colEstudianteNombre],
      grado: map[DatabaseConstants.colEstudianteGrado],
      thetaActual: map[DatabaseConstants.colEstudianteThetaActual],
      fechaRegistro: DateTime.parse(map[DatabaseConstants.colEstudianteFechaRegistro]),
    );
  }

  Future<void> actualizarTheta(int id, double nuevoTheta) async {
    final db = await _dbHelper.database;
    await db.update(
      DatabaseConstants.tableEstudiante,
      {DatabaseConstants.colEstudianteThetaActual: nuevoTheta},
      where: '${DatabaseConstants.colEstudianteId} = ?',
      whereArgs: [id],
    );
  }
}
