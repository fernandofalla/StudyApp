// lib/presentation/widgets/barra_patron_widget.dart

import 'package:flutter/material.dart';
import 'package:adaptamat/domain/usecases/resumen_grupo.dart';

const _colorBarra = Color(0xFFC62828);

/// Barra de frecuencia de un patrón de error del grupo.
///
/// Ejemplo visual:
///   Error de reagrupación en adición
///   ████████████████░░░░  8 veces · 3 estudiantes
class BarraPatronWidget extends StatelessWidget {
  final String codigoPatron;
  final int frecuenciaTotal;
  final int estudiantesAfectados;
  final int maxFrecuencia;

  const BarraPatronWidget({
    super.key,
    required this.codigoPatron,
    required this.frecuenciaTotal,
    required this.estudiantesAfectados,
    required this.maxFrecuencia,
  });

  @override
  Widget build(BuildContext context) {
    final nombre = ResumenGrupo.descripcionPatron(codigoPatron);
    final fraccion =
        maxFrecuencia > 0 ? frecuenciaTotal / maxFrecuencia : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre del patrón
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _colorBarra.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  codigoPatron,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _colorBarra,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Barra + etiqueta
          Row(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (_, constraints) {
                    final totalWidth = constraints.maxWidth;
                    final filledWidth = totalWidth * fraccion;
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: [
                          // Fondo vacío
                          Container(
                            height: 18,
                            width: totalWidth,
                            color: Colors.grey.shade200,
                          ),
                          // Relleno proporcional
                          Container(
                            height: 18,
                            width: filledWidth,
                            color: _colorBarra,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$frecuenciaTotal ${frecuenciaTotal == 1 ? 'vez' : 'veces'} · '
                '$estudiantesAfectados est.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
