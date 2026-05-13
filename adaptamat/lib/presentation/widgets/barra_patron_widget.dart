// lib/presentation/widgets/barra_patron_widget.dart

import 'package:flutter/material.dart';
import 'package:adaptamat/data/datasources/dashboard_datasource.dart';
import 'package:adaptamat/domain/usecases/resumen_grupo.dart';

const _azulOscuro = Color(0xFF1F3864);

class BarraPatronWidget extends StatelessWidget {
  final PatronResumen patron;
  final int maxFrecuencia;

  const BarraPatronWidget({
    super.key,
    required this.patron,
    required this.maxFrecuencia,
  });

  @override
  Widget build(BuildContext context) {
    final fraccion = maxFrecuencia > 0 ? patron.frecuencia / maxFrecuencia : 0.0;
    final descripcion = ResumenGrupo.descripcionPatron(patron.codigoPatron);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 52,
                child: Text(
                  patron.codigoPatron,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _azulOscuro,
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (_, constraints) {
                    return Stack(
                      children: [
                        Container(
                          height: 20,
                          width: constraints.maxWidth,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          height: 20,
                          width: constraints.maxWidth * fraccion,
                          decoration: BoxDecoration(
                            color: _colorPatron(patron.codigoPatron),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${patron.frecuencia}x',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Text(
              descripcion,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorPatron(String codigo) {
    switch (codigo) {
      case 'PE-01':
        return Colors.orange.shade400;
      case 'PE-02':
        return Colors.blue.shade400;
      case 'PE-03':
        return Colors.purple.shade400;
      case 'PE-04':
        return Colors.red.shade400;
      case 'PE-05':
        return Colors.teal.shade400;
      case 'PE-06':
        return Colors.green.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

}
