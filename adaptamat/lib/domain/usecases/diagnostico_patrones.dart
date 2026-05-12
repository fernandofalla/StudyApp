// lib/domain/usecases/diagnostico_patrones.dart
// 6 reglas heurísticas para detectar patrones de error en respuestas de primer grado.
// Tabla 2.6: cada regla devuelve el código PE-0x del patrón detectado o null.

import '../entities/sesion_respuesta_patron.dart';

class DiagnosticoPatrones {
  /// Analiza la respuesta actual junto con el historial de [Respuesta] del
  /// estudiante y devuelve el código del patrón detectado, o null si no hay
  /// patrón identificable.
  static String? evaluar(
    List<Respuesta> historial,
    String subtema,
    int respuestaDada,
    int respuestaCorrecta,
    bool correcto,
  ) {
    if (correcto) return null;

    final incorrectas = historial.where((r) => !r.correcto).toList();

    // Regla 6 (PE-06): Bloqueo sostenido — ≥3 errores consecutivos al final.
    if (_rachaConsecutivaFinal(historial) >= 3) return 'PE-06';

    // Regla 5 (PE-05): Sesgo hacia la primera opción — eligió índice 0
    // incorrectamente en ≥2 respuestas anteriores.
    if (respuestaDada == 0 &&
        incorrectas.where((r) => r.respuestaDada == 0).length >= 2) {
      return 'PE-05';
    }

    // Regla 3 (PE-03): Perseveración de distractor — repite el mismo índice
    // incorrecto ≥2 veces en el historial.
    if (incorrectas
            .where((r) => r.respuestaDada == respuestaDada)
            .length >= 2) {
      return 'PE-03';
    }

    // Regla 2 (PE-02): Sobreestimación por adyacencia — elige el índice
    // inmediatamente superior al correcto.
    if (respuestaDada == respuestaCorrecta + 1 && incorrectas.isNotEmpty) {
      return 'PE-02';
    }

    // Regla 1 (PE-01): Subestimación por adyacencia — elige el índice
    // inmediatamente inferior al correcto.
    if (respuestaDada == respuestaCorrecta - 1 && incorrectas.isNotEmpty) {
      return 'PE-01';
    }

    // Regla 4 (PE-04): Sobreestimación amplia — elige un índice >1 por
    // encima del correcto con al menos 2 errores previos.
    if (respuestaDada > respuestaCorrecta + 1 && incorrectas.length >= 2) {
      return 'PE-04';
    }

    return null;
  }

  static int _rachaConsecutivaFinal(List<Respuesta> historial) {
    int racha = 0;
    for (final r in historial.reversed) {
      if (!r.correcto) {
        racha++;
      } else {
        break;
      }
    }
    return racha;
  }
}
