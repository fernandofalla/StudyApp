// lib/data/datasources/dashboard_datasource.dart

import 'package:adaptamat/core/database/database_helper.dart';

// ─── DTOs usados por la capa de presentación ─────────────────────────────────

class ResumenEstudiante {
  final int id;
  final String nombre;
  final String grado;
  final double thetaActual;
  final int totalSesiones;
  final int totalRespuestas;
  final int totalCorrectas;
  final DateTime? ultimaSesion;

  const ResumenEstudiante({
    required this.id,
    required this.nombre,
    required this.grado,
    required this.thetaActual,
    required this.totalSesiones,
    required this.totalRespuestas,
    required this.totalCorrectas,
    this.ultimaSesion,
  });

  double get porcentajeAcierto =>
      totalRespuestas > 0 ? totalCorrectas / totalRespuestas : 0.0;
}

class PatronResumen {
  final String codigoPatron;
  final int frecuencia;
  final DateTime ultimaDeteccion;

  const PatronResumen({
    required this.codigoPatron,
    required this.frecuencia,
    required this.ultimaDeteccion,
  });
}

class SesionResumen {
  final int id;
  final String tema;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final int totalRespuestas;
  final int correctas;

  const SesionResumen({
    required this.id,
    required this.tema,
    required this.fechaInicio,
    this.fechaFin,
    required this.totalRespuestas,
    required this.correctas,
  });

  double get porcentajeAcierto =>
      totalRespuestas > 0 ? correctas / totalRespuestas : 0.0;

  String get temaLegible {
    switch (tema) {
      case 'numeros_y_operaciones':
        return 'Números y Operaciones';
      case 'geometria':
        return 'Geometría';
      default:
        return tema;
    }
  }
}

// ─── Datasource ───────────────────────────────────────────────────────────────

class DashboardDatasource {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Retorna un resumen por cada estudiante: id, nombre, theta_actual,
  /// tema de la última sesión y total de sesiones completadas.
  Future<List<Map<String, dynamic>>> obtenerResumenGrupo() async {
    final db = await _dbHelper.database;
    return db.rawQuery('''
      SELECT e.id, e.nombre, e.theta_actual,
             s.tema, COUNT(s.id) AS total_sesiones
      FROM estudiante e
      LEFT JOIN sesion s ON s.estudiante_id = e.id
      GROUP BY e.id
    ''');
  }

  /// Retorna los patrones de error del grupo ordenados por frecuencia
  /// total acumulada, con el número de estudiantes afectados.
  Future<List<Map<String, dynamic>>> obtenerPatronesDelGrupo() async {
    final db = await _dbHelper.database;
    return db.rawQuery('''
      SELECT codigo_patron,
             SUM(frecuencia)            AS frecuencia_total,
             COUNT(DISTINCT estudiante_id) AS estudiantes_afectados
      FROM patron_error
      GROUP BY codigo_patron
      ORDER BY frecuencia_total DESC
    ''');
  }

  /// Retorna el perfil completo de un estudiante: datos básicos,
  /// sesiones con fecha y tema, patrones activos y conteos de acierto.
  Future<Map<String, dynamic>> obtenerPerfilEstudiante(
      int estudianteId) async {
    final db = await _dbHelper.database;

    // Datos básicos
    final estRows = await db.query(
      'estudiante',
      where: 'id = ?',
      whereArgs: [estudianteId],
      limit: 1,
    );
    if (estRows.isEmpty) return {};

    final est = estRows.first;

    // Sesiones con aciertos
    final sesRows = await db.rawQuery('''
      SELECT s.id, s.tema, s.fecha_inicio, s.fecha_fin,
             COUNT(r.id)     AS total_respuestas,
             SUM(r.correcto) AS correctas
      FROM sesion s
      LEFT JOIN respuesta r ON r.sesion_id = s.id
      WHERE s.estudiante_id = ?
      GROUP BY s.id, s.tema, s.fecha_inicio, s.fecha_fin
      ORDER BY s.fecha_inicio DESC
    ''', [estudianteId]);

    // Patrones activos
    final patronRows = await db.query(
      'patron_error',
      where: 'estudiante_id = ?',
      whereArgs: [estudianteId],
      orderBy: 'frecuencia DESC',
    );

    // Totales de respuestas
    final totalesRows = await db.rawQuery('''
      SELECT COUNT(r.id)     AS total,
             SUM(r.correcto) AS correctas
      FROM respuesta r
      JOIN sesion s ON s.id = r.sesion_id
      WHERE s.estudiante_id = ?
    ''', [estudianteId]);

    final total = (totalesRows.first['total'] as int?) ?? 0;
    final correctas = (totalesRows.first['correctas'] as int?) ?? 0;

    return {
      'nombre': est['nombre'],
      'grado': est['grado'],
      'theta_actual': est['theta_actual'],
      'sesiones': sesRows,
      'patrones': patronRows,
      'total_correctas': correctas,
      'total_incorrectas': total - correctas,
    };
  }

  /// Retorna la evolución de theta del estudiante, una entrada por sesión.
  Future<List<Map<String, dynamic>>> obtenerHistorialTheta(
      int estudianteId) async {
    final db = await _dbHelper.database;
    return db.rawQuery('''
      SELECT s.fecha_inicio, e.theta_actual
      FROM sesion s
      JOIN estudiante e ON e.id = s.estudiante_id
      WHERE s.estudiante_id = ?
      ORDER BY s.fecha_inicio ASC
    ''', [estudianteId]);
  }

  // ── Métodos auxiliares para la capa de presentación ──────────────────────

  /// Versión tipada de [obtenerResumenGrupo] con datos extendidos para la UI.
  Future<List<ResumenEstudiante>> obtenerResumenEstudiantes() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT
        e.id, e.nombre, e.grado, e.theta_actual,
        COUNT(DISTINCT s.id)  AS total_sesiones,
        COUNT(r.id)           AS total_respuestas,
        SUM(r.correcto)       AS total_correctas,
        MAX(s.fecha_inicio)   AS ultima_sesion
      FROM estudiante e
      LEFT JOIN sesion   s ON s.estudiante_id = e.id
      LEFT JOIN respuesta r ON r.sesion_id    = s.id
      GROUP BY e.id, e.nombre, e.grado, e.theta_actual
      ORDER BY e.nombre ASC
    ''');

    return rows.map((r) {
      final ultimaStr = r['ultima_sesion'] as String?;
      return ResumenEstudiante(
        id: r['id'] as int,
        nombre: r['nombre'] as String,
        grado: r['grado'] as String,
        thetaActual: (r['theta_actual'] as num).toDouble(),
        totalSesiones: (r['total_sesiones'] as int?) ?? 0,
        totalRespuestas: (r['total_respuestas'] as int?) ?? 0,
        totalCorrectas: (r['total_correctas'] as int?) ?? 0,
        ultimaSesion: ultimaStr != null ? DateTime.tryParse(ultimaStr) : null,
      );
    }).toList();
  }

  /// Versión tipada de los patrones de un estudiante para la UI.
  Future<List<PatronResumen>> obtenerPatronesPorEstudiante(
      int estudianteId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'patron_error',
      where: 'estudiante_id = ?',
      whereArgs: [estudianteId],
      orderBy: 'frecuencia DESC',
    );
    return rows.map((r) {
      return PatronResumen(
        codigoPatron: r['codigo_patron'] as String,
        frecuencia: r['frecuencia'] as int,
        ultimaDeteccion: DateTime.parse(r['ultima_deteccion'] as String),
      );
    }).toList();
  }

  /// Versión tipada de las sesiones de un estudiante para la UI.
  Future<List<SesionResumen>> obtenerSesionesPorEstudiante(
      int estudianteId) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT s.id, s.tema, s.fecha_inicio, s.fecha_fin,
             COUNT(r.id)     AS total_respuestas,
             SUM(r.correcto) AS correctas
      FROM sesion s
      LEFT JOIN respuesta r ON r.sesion_id = s.id
      WHERE s.estudiante_id = ?
      GROUP BY s.id, s.tema, s.fecha_inicio, s.fecha_fin
      ORDER BY s.fecha_inicio DESC
    ''', [estudianteId]);

    return rows.map((r) {
      final finStr = r['fecha_fin'] as String?;
      return SesionResumen(
        id: r['id'] as int,
        tema: r['tema'] as String,
        fechaInicio: DateTime.parse(r['fecha_inicio'] as String),
        fechaFin: finStr != null ? DateTime.tryParse(finStr) : null,
        totalRespuestas: (r['total_respuestas'] as int?) ?? 0,
        correctas: (r['correctas'] as int?) ?? 0,
      );
    }).toList();
  }
}
