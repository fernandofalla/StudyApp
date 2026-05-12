// lib/domain/usecases/motor_adaptativo.dart
// Lógica IRT de un parámetro: estimación de theta y selección adaptativa de ítems.

import 'dart:math';
import '../entities/item.dart';

class MotorAdaptativo {
  /// P(correcto | θ, b) = 1 / (1 + e^(-(θ − b)))
  static double probabilidadCorrecta(double theta, double b) {
    return 1.0 / (1.0 + exp(-(theta - b)));
  }

  /// Actualiza θ con paso fijo ±0.3, acotado en [-3, 3].
  static double actualizarTheta(double thetaActual, bool correcto) {
    final delta = correcto ? 0.3 : -0.3;
    return (thetaActual + delta).clamp(-3.0, 3.0);
  }

  /// Devuelve el ítem del banco con dificultad más cercana a theta,
  /// del subtema indicado y que no haya sido presentado aún.
  static Item? seleccionarSiguienteItem(
    double theta,
    String subtema,
    List<Item> banco,
    Set<int> presentados,
  ) {
    final candidatos = banco
        .where((item) =>
            item.subtema == subtema &&
            (item.id == null || !presentados.contains(item.id)))
        .toList();

    if (candidatos.isEmpty) return null;

    candidatos.sort((a, b) =>
        (a.dificultadB - theta).abs().compareTo((b.dificultadB - theta).abs()));

    return candidatos.first;
  }

  /// El estudiante domina el subtema cuando θ ≥ 1.0 y respondió ≥ 5 ítems.
  static bool evaluarDominio({
    required double theta,
    required int itemsRespondidos,
  }) {
    return theta >= 1.0 && itemsRespondidos >= 5;
  }

  /// Ítems de diagnóstico: dificultad cercana a cero (|b| ≤ 0.5), máximo 3.
  static List<Item> seleccionarItemsDiagnostico(
    String subtema,
    List<Item> banco,
  ) {
    return banco
        .where((item) =>
            item.subtema == subtema && item.dificultadB.abs() <= 0.5)
        .take(3)
        .toList();
  }
}
