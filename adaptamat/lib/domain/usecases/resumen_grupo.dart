// lib/domain/usecases/resumen_grupo.dart

import 'package:flutter/material.dart';
import 'package:adaptamat/data/datasources/dashboard_datasource.dart';

abstract class ResumenGrupo {
  /// Convierte theta a un nivel comprensible para el docente.
  static String nivelDesdeTheta(double theta) {
    if (theta < 0.0) return 'Inicio';
    if (theta < 1.0) return 'En proceso';
    return 'Logrado';
  }

  /// Color semafórico asociado al nivel.
  static Color colorDesdeNivel(String nivel) {
    switch (nivel) {
      case 'Inicio':
        return const Color(0xFFC62828);
      case 'En proceso':
        return const Color(0xFFF9A825);
      case 'Logrado':
        return const Color(0xFF2E7D32);
      default:
        return Colors.grey;
    }
  }

  /// Nombre legible del patrón de error.
  static String descripcionPatron(String codigoPatron) {
    switch (codigoPatron) {
      case 'PE-01':
        return 'Conteo no correspondiente';
      case 'PE-02':
        return 'Inversión de dígitos';
      case 'PE-03':
        return 'Error de reagrupación en adición';
      case 'PE-04':
        return 'Sustracción inversa';
      case 'PE-05':
        return 'Confusión de figura y cuerpo';
      case 'PE-06':
        return 'Clasificación por atributo no geométrico';
      default:
        return 'Patrón desconocido';
    }
  }

  /// Porcentaje de logro; retorna 0 si total es 0.
  static double porcentajeLogro(int correctas, int total) {
    if (total == 0) return 0;
    return correctas / total * 100;
  }

  // ── Helpers para el dashboard ──────────────────────────────────────────────

  static Map<String, int> distribuirPorNivel(
      List<ResumenEstudiante> estudiantes) {
    final dist = <String, int>{
      'Inicio': 0,
      'En proceso': 0,
      'Logrado': 0,
    };
    for (final e in estudiantes) {
      final nivel = nivelDesdeTheta(e.thetaActual);
      dist[nivel] = (dist[nivel] ?? 0) + 1;
    }
    return dist;
  }

  static double promedioTheta(List<ResumenEstudiante> estudiantes) {
    if (estudiantes.isEmpty) return 0.0;
    return estudiantes.fold<double>(0, (acc, e) => acc + e.thetaActual) /
        estudiantes.length;
  }

  static double promedioAcierto(List<ResumenEstudiante> estudiantes) {
    if (estudiantes.isEmpty) return 0.0;
    return estudiantes.fold<double>(0, (acc, e) => acc + e.porcentajeAcierto) /
        estudiantes.length;
  }
}
