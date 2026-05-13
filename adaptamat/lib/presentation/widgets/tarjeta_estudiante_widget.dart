// lib/presentation/widgets/tarjeta_estudiante_widget.dart

import 'package:flutter/material.dart';
import 'package:adaptamat/domain/usecases/resumen_grupo.dart';

const _azulOscuro = Color(0xFF1F3864);

/// Tarjeta de un estudiante en el resumen de grupo.
/// [datos] proviene de DashboardDatasource.obtenerResumenGrupo():
///   id, nombre, theta_actual, tema, total_sesiones
class TarjetaEstudianteWidget extends StatelessWidget {
  final Map<String, dynamic> datos;
  final void Function(int estudianteId) onSeleccionar;

  const TarjetaEstudianteWidget({
    super.key,
    required this.datos,
    required this.onSeleccionar,
  });

  String _temaLegible(String? tema) {
    switch (tema) {
      case 'numeros_y_operaciones':
        return 'Números y Operaciones';
      case 'geometria':
        return 'Geometría';
      default:
        return tema ?? '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = datos['id'] as int? ?? 0;
    final nombre = datos['nombre'] as String? ?? '—';
    final theta = (datos['theta_actual'] as num?)?.toDouble() ?? 0.0;
    final tema = datos['tema'] as String?;
    final sesiones = (datos['total_sesiones'] as int?) ?? 0;

    final nivel = ResumenGrupo.nivelDesdeTheta(theta);
    final colorNivel = ResumenGrupo.colorDesdeNivel(nivel);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => onSeleccionar(id),
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  backgroundColor: _azulOscuro.withValues(alpha: 0.1),
                  radius: 22,
                  child: Text(
                    nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _azulOscuro,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Datos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nombre
                      Text(
                        nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Chip de nivel + subtema
                      Row(
                        children: [
                          _NivelChip(nivel: nivel, color: colorNivel),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _temaLegible(tema),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Sesiones
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$sesiones',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _azulOscuro,
                      ),
                    ),
                    Text(
                      'sesión${sesiones != 1 ? 'es' : ''}',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded,
                    color: Colors.grey, size: 20),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1),
      ],
    );
  }
}

class _NivelChip extends StatelessWidget {
  final String nivel;
  final Color color;
  const _NivelChip({required this.nivel, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        nivel,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
