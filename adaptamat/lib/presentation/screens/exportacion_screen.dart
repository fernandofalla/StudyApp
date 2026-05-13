// lib/presentation/screens/exportacion_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adaptamat/data/datasources/dashboard_datasource.dart';
import 'package:adaptamat/domain/usecases/resumen_grupo.dart';

const _azulOscuro = Color(0xFF1F3864);

class ExportacionScreen extends StatelessWidget {
  final List<ResumenEstudiante> estudiantes;

  const ExportacionScreen({super.key, required this.estudiantes});

  String _fmtFecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _fmtFechaHora(DateTime d) =>
      '${_fmtFecha(d)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String _generarReporte() {
    final ahora = _fmtFechaHora(DateTime.now());
    final buf = StringBuffer();

    buf.writeln('══════════════════════════════════════');
    buf.writeln('  REPORTE DE PROGRESO — AdaptaMat');
    buf.writeln('  Generado: $ahora');
    buf.writeln('══════════════════════════════════════');
    buf.writeln();

    // Resumen de grupo
    final promTheta = ResumenGrupo.promedioTheta(estudiantes);
    final promAcierto = ResumenGrupo.promedioAcierto(estudiantes);
    final dist = ResumenGrupo.distribuirPorNivel(estudiantes);

    buf.writeln('RESUMEN DEL GRUPO');
    buf.writeln('─────────────────');
    buf.writeln('Total estudiantes : ${estudiantes.length}');
    buf.writeln('θ promedio        : ${promTheta.toStringAsFixed(2)}');
    buf.writeln('Acierto promedio  : ${(promAcierto * 100).toStringAsFixed(1)}%');
    buf.writeln();
    buf.writeln('Distribución por nivel:');
    for (final entry in dist.entries) {
      buf.writeln('  ${entry.key.padRight(12)}: ${entry.value} estudiante(s)');
    }
    buf.writeln();

    // Detalle por estudiante
    buf.writeln('DETALLE POR ESTUDIANTE');
    buf.writeln('──────────────────────');
    for (final e in estudiantes) {
      final nivel = ResumenGrupo.nivelDesdeTheta(e.thetaActual);
      buf.writeln('${e.nombre} (${e.grado})');
      buf.writeln('  Nivel    : $nivel  (θ = ${e.thetaActual.toStringAsFixed(2)})');
      buf.writeln('  Acierto  : ${(e.porcentajeAcierto * 100).toStringAsFixed(1)}%  '
          '(${e.totalCorrectas}/${e.totalRespuestas} respuestas)');
      buf.writeln('  Sesiones : ${e.totalSesiones}');
      if (e.ultimaSesion != null) {
        buf.writeln('  Última   : ${_fmtFecha(e.ultimaSesion!)}');
      }
      buf.writeln();
    }

    buf.writeln('══════════════════════════════════════');
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final reporte = _generarReporte();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: _azulOscuro,
        foregroundColor: Colors.white,
        title: const Text('Exportar reporte'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Copiar al portapapeles',
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: reporte));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reporte copiado al portapapeles'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: _azulOscuro.withValues(alpha: 0.08),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 18, color: _azulOscuro),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Presiona el ícono de copiar para llevar el reporte al portapapeles.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    reporte,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copiar reporte'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _azulOscuro,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: reporte));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reporte copiado al portapapeles'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
