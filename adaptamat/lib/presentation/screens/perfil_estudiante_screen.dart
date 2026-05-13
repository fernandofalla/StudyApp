// lib/presentation/screens/perfil_estudiante_screen.dart

import 'package:flutter/material.dart';
import 'package:adaptamat/domain/usecases/resumen_grupo.dart';

const _azulOscuro = Color(0xFF1F3864);

class PerfilEstudianteScreen extends StatelessWidget {
  final Map<String, dynamic> perfil;
  final List<Map<String, dynamic>> historialTheta;

  const PerfilEstudianteScreen({
    super.key,
    required this.perfil,
    required this.historialTheta,
  });

  String _fmtFecha(String isoStr) {
    final d = DateTime.tryParse(isoStr);
    if (d == null) return isoStr;
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final nombre = perfil['nombre'] as String? ?? '—';
    final theta = (perfil['theta_actual'] as num?)?.toDouble() ?? 0.0;
    final nivel = ResumenGrupo.nivelDesdeTheta(theta);
    final colorNivel = ResumenGrupo.colorDesdeNivel(nivel);
    final sesionesRaw =
        (perfil['sesiones'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final patronesRaw =
        (perfil['patrones'] as List?)?.cast<Map<String, dynamic>>() ?? [];

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
            // ── Sección 1: Datos generales ──────────────────────────────────
            _Seccion(
              titulo: 'Datos generales',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _NivelChip(nivel: nivel, color: colorNivel),
                      const SizedBox(width: 12),
                      Text(
                        'θ = ${theta.toStringAsFixed(2)} logits',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.event_note_rounded,
                          size: 18, color: _azulOscuro),
                      const SizedBox(width: 6),
                      Text(
                        '${sesionesRaw.length} sesión${sesionesRaw.length != 1 ? 'es' : ''} completada${sesionesRaw.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Sección 2: Evolución de habilidad ───────────────────────────
            _Seccion(
              titulo: 'Evolución de habilidad',
              child: historialTheta.isEmpty
                  ? const _MensajeVacio('Sin sesiones registradas')
                  : _TablaHistorial(
                      historial: historialTheta,
                      fmtFecha: _fmtFecha,
                    ),
            ),

            const SizedBox(height: 14),

            // ── Sección 3: Patrones de error activos ─────────────────────────
            _Seccion(
              titulo: 'Patrones de error activos',
              child: patronesRaw.isEmpty
                  ? const _MensajeVacio('Sin patrones detectados')
                  : Column(
                      children: patronesRaw.map((p) {
                        final codigo = p['codigo_patron'] as String? ?? '—';
                        final frecuencia = (p['frecuencia'] as int?) ?? 0;
                        final ultimaStr = p['ultima_deteccion'] as String? ?? '';
                        return _FilaPatron(
                          codigo: codigo,
                          nombre: ResumenGrupo.descripcionPatron(codigo),
                          frecuencia: frecuencia,
                          ultimaFecha: _fmtFecha(ultimaStr),
                        );
                      }).toList(),
                    ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Sección contenedora ──────────────────────────────────────────────────────

class _Seccion extends StatelessWidget {
  final String titulo;
  final Widget child;

  const _Seccion({required this.titulo, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: _azulOscuro,
                letterSpacing: 0.5,
              ),
            ),
            const Divider(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

// ─── Tabla de historial ───────────────────────────────────────────────────────

class _TablaHistorial extends StatelessWidget {
  final List<Map<String, dynamic>> historial;
  final String Function(String) fmtFecha;

  const _TablaHistorial({
    required this.historial,
    required this.fmtFecha,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.4),
        1: FlexColumnWidth(1),
      },
      children: [
        // Encabezado
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: const [
            _CeldaTh('Fecha de sesión'),
            _CeldaTh('Nivel'),
          ],
        ),
        // Filas
        ...historial.map((h) {
          final fechaStr = h['fecha_inicio'] as String? ?? '';
          final theta = (h['theta_actual'] as num?)?.toDouble() ?? 0.0;
          final nivel = ResumenGrupo.nivelDesdeTheta(theta);
          final color = ResumenGrupo.colorDesdeNivel(nivel);
          return TableRow(
            children: [
              _CeldaTd(fmtFecha(fechaStr)),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 6, horizontal: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    nivel,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _CeldaTh extends StatelessWidget {
  final String texto;
  const _CeldaTh(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}

class _CeldaTd extends StatelessWidget {
  final String texto;
  const _CeldaTd(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Text(texto,
          style: const TextStyle(fontSize: 13, color: Colors.black87)),
    );
  }
}

// ─── Fila de patrón ───────────────────────────────────────────────────────────

class _FilaPatron extends StatelessWidget {
  final String codigo;
  final String nombre;
  final int frecuencia;
  final String ultimaFecha;

  const _FilaPatron({
    required this.codigo,
    required this.nombre,
    required this.frecuencia,
    required this.ultimaFecha,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFC62828).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              codigo,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC62828),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 2),
                Text(
                  '$frecuencia ${frecuencia == 1 ? 'vez' : 'veces'}  ·  última: $ultimaFecha',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mensaje vacío ────────────────────────────────────────────────────────────

class _MensajeVacio extends StatelessWidget {
  final String texto;
  const _MensajeVacio(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        texto,
        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
      ),
    );
  }
}

// ─── Chip de nivel ────────────────────────────────────────────────────────────

class _NivelChip extends StatelessWidget {
  final String nivel;
  final Color color;
  const _NivelChip({required this.nivel, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        nivel,
        style: TextStyle(
          fontSize: 13,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
