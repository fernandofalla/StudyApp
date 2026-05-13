// lib/presentation/screens/perfil_estudiante_screen.dart

import 'package:flutter/material.dart';
import 'package:adaptamat/domain/usecases/resumen_grupo.dart';
import 'package:adaptamat/presentation/widgets/barra_patron_widget.dart';
import 'package:adaptamat/data/datasources/dashboard_datasource.dart';

const _azulOscuro = Color(0xFF1F3864);

class PerfilEstudianteScreen extends StatelessWidget {
  final Map<String, dynamic> perfil;
  final List<Map<String, dynamic>> historialTheta;

  const PerfilEstudianteScreen({
    super.key,
    required this.perfil,
    required this.historialTheta,
  });

  @override
  Widget build(BuildContext context) {
    final nombre = perfil['nombre'] as String? ?? '—';
    final grado = perfil['grado'] as String? ?? '—';
    final theta = (perfil['theta_actual'] as num?)?.toDouble() ?? 0.0;
    final correctas = (perfil['total_correctas'] as int?) ?? 0;
    final incorrectas = (perfil['total_incorrectas'] as int?) ?? 0;
    final total = correctas + incorrectas;

    final sesionesRaw =
        (perfil['sesiones'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final patronesRaw =
        (perfil['patrones'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    final sesiones = sesionesRaw.map((m) {
      final finStr = m['fecha_fin'] as String?;
      return SesionResumen(
        id: m['id'] as int,
        tema: m['tema'] as String,
        fechaInicio: DateTime.parse(m['fecha_inicio'] as String),
        fechaFin: finStr != null ? DateTime.tryParse(finStr) : null,
        totalRespuestas: (m['total_respuestas'] as int?) ?? 0,
        correctas: (m['correctas'] as int?) ?? 0,
      );
    }).toList();

    final patrones = patronesRaw.map((m) {
      return PatronResumen(
        codigoPatron: m['codigo_patron'] as String,
        frecuencia: m['frecuencia'] as int,
        ultimaDeteccion:
            DateTime.parse(m['ultima_deteccion'] as String),
      );
    }).toList();

    final nivel = ResumenGrupo.nivelDesdeTheta(theta);
    final porcentaje = ResumenGrupo.porcentajeLogro(correctas, total);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: _azulOscuro,
        foregroundColor: Colors.white,
        title: Text(nombre),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarjeta resumen
            Card(
              color: _azulOscuro,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(grado,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _StatBox(label: 'Nivel', valor: nivel),
                        const SizedBox(width: 10),
                        _StatBox(
                            label: 'θ actual',
                            valor: theta.toStringAsFixed(2)),
                        const SizedBox(width: 10),
                        _StatBox(
                            label: 'Logro',
                            valor:
                                '${porcentaje.toStringAsFixed(0)}%'),
                        const SizedBox(width: 10),
                        _StatBox(
                            label: 'Sesiones',
                            valor: '${sesiones.length}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Patrones de error
            if (patrones.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Patrones de error detectados',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...patrones.map((p) {
                        final maxFrecuencia = patrones.fold<int>(
                            0,
                            (m, x) =>
                                x.frecuencia > m ? x.frecuencia : m);
                        return BarraPatronWidget(
                          patron: p,
                          maxFrecuencia: maxFrecuencia,
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
            // Historial de sesiones
            const SizedBox(height: 16),
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Historial de sesiones',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (sesiones.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Sin sesiones registradas.',
                            style: TextStyle(color: Colors.black54)),
                      )
                    else
                      ...sesiones.map((s) => _FilaSesion(sesion: s)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String label;
  final String valor;
  const _StatBox({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(valor,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _FilaSesion extends StatelessWidget {
  final SesionResumen sesion;
  const _FilaSesion({required this.sesion});

  String _fmtFecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.history_rounded, size: 20, color: _azulOscuro),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sesion.temaLegible,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  _fmtFecha(sesion.fechaInicio),
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${sesion.correctas}/${sesion.totalRespuestas}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _azulOscuro,
                ),
              ),
              Text(
                '${(sesion.porcentajeAcierto * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                    fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
