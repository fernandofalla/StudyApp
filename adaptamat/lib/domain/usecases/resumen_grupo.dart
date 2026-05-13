// lib/domain/usecases/resumen_grupo.dart

import 'package:adaptamat/data/datasources/dashboard_datasource.dart';

abstract class ResumenGrupo {
  static String nivelDesdeTheta(double theta) {
    if (theta < -1.0) return 'Inicial';
    if (theta < 0.0) return 'Básico';
    if (theta < 1.0) return 'Intermedio';
    return 'Avanzado';
  }

  static Map<String, int> distribuirPorNivel(List<ResumenEstudiante> estudiantes) {
    final dist = <String, int>{
      'Inicial': 0,
      'Básico': 0,
      'Intermedio': 0,
      'Avanzado': 0,
    };
    for (final e in estudiantes) {
      final nivel = nivelDesdeTheta(e.thetaActual);
      dist[nivel] = (dist[nivel] ?? 0) + 1;
    }
    return dist;
  }

  static double promedioTheta(List<ResumenEstudiante> estudiantes) {
    if (estudiantes.isEmpty) return 0.0;
    final suma = estudiantes.fold<double>(0, (acc, e) => acc + e.thetaActual);
    return suma / estudiantes.length;
  }

  static double promedioAcierto(List<ResumenEstudiante> estudiantes) {
    if (estudiantes.isEmpty) return 0.0;
    final suma = estudiantes.fold<double>(0, (acc, e) => acc + e.porcentajeAcierto);
    return suma / estudiantes.length;
  }
}
