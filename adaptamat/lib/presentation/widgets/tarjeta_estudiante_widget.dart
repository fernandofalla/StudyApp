// lib/presentation/widgets/tarjeta_estudiante_widget.dart

import 'package:flutter/material.dart';
import 'package:adaptamat/data/datasources/dashboard_datasource.dart';
import 'package:adaptamat/domain/usecases/resumen_grupo.dart';

const _azulOscuro = Color(0xFF1F3864);

class TarjetaEstudianteWidget extends StatelessWidget {
  final ResumenEstudiante estudiante;
  final VoidCallback onTap;

  const TarjetaEstudianteWidget({
    super.key,
    required this.estudiante,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nivel = ResumenGrupo.nivelDesdeTheta(estudiante.thetaActual);
    final colorNivel = ResumenGrupo.colorDesdeNivel(nivel);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Avatar con inicial
              CircleAvatar(
                backgroundColor: _azulOscuro.withValues(alpha: 0.1),
                radius: 24,
                child: Text(
                  estudiante.nombre.isNotEmpty
                      ? estudiante.nombre[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _azulOscuro,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Nombre y grado
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      estudiante.nombre,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      estudiante.grado,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _Chip(label: nivel, color: colorNivel),
                        const SizedBox(width: 6),
                        _Chip(
                          label:
                              '${(estudiante.porcentajeAcierto * 100).toStringAsFixed(0)}% acierto',
                          color: Colors.teal,
                        ),
                        const SizedBox(width: 6),
                        _Chip(
                          label: '${estudiante.totalSesiones} sesión${estudiante.totalSesiones != 1 ? 'es' : ''}',
                          color: Colors.blueGrey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
