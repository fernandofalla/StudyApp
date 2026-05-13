// lib/presentation/screens/perfil_estudiante_screen.dart

import 'package:flutter/material.dart';
import 'package:adaptamat/data/datasources/dashboard_datasource.dart';
import 'package:adaptamat/domain/usecases/resumen_grupo.dart';
import 'package:adaptamat/presentation/widgets/barra_patron_widget.dart';

const _azulOscuro = Color(0xFF1F3864);

class PerfilEstudianteScreen extends StatefulWidget {
  final ResumenEstudiante estudiante;

  const PerfilEstudianteScreen({super.key, required this.estudiante});

  @override
  State<PerfilEstudianteScreen> createState() => _PerfilEstudianteScreenState();
}

class _PerfilEstudianteScreenState extends State<PerfilEstudianteScreen> {
  final _ds = DashboardDatasource();
  List<PatronResumen> _patrones = [];
  List<SesionResumen> _sesiones = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final patrones = await _ds.obtenerPatronesPorEstudiante(widget.estudiante.id);
      final sesiones = await _ds.obtenerSesionesPorEstudiante(widget.estudiante.id);
      if (mounted) {
        setState(() {
          _patrones = patrones;
          _sesiones = sesiones;
          _cargando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: _azulOscuro,
        foregroundColor: Colors.white,
        title: Text(widget.estudiante.nombre),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: _azulOscuro))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TarjetaResumen(estudiante: widget.estudiante),
                  const SizedBox(height: 16),
                  if (_patrones.isNotEmpty) ...[
                    _SeccionPatrones(patrones: _patrones),
                    const SizedBox(height: 16),
                  ],
                  _SeccionSesiones(sesiones: _sesiones),
                ],
              ),
            ),
    );
  }
}

// ─── Tarjeta resumen ──────────────────────────────────────────────────────────

class _TarjetaResumen extends StatelessWidget {
  final ResumenEstudiante estudiante;
  const _TarjetaResumen({required this.estudiante});

  @override
  Widget build(BuildContext context) {
    final nivel = ResumenGrupo.nivelDesdeTheta(estudiante.thetaActual);
    return Card(
      color: _azulOscuro,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              estudiante.grado,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              estudiante.nombre,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatBox(label: 'Nivel', valor: nivel),
                const SizedBox(width: 12),
                _StatBox(
                  label: 'θ actual',
                  valor: estudiante.thetaActual.toStringAsFixed(2),
                ),
                const SizedBox(width: 12),
                _StatBox(
                  label: 'Acierto',
                  valor:
                      '${(estudiante.porcentajeAcierto * 100).toStringAsFixed(0)}%',
                ),
                const SizedBox(width: 12),
                _StatBox(
                  label: 'Sesiones',
                  valor: '${estudiante.totalSesiones}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String valor;
  const _StatBox({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              valor,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sección de patrones ──────────────────────────────────────────────────────

class _SeccionPatrones extends StatelessWidget {
  final List<PatronResumen> patrones;
  const _SeccionPatrones({required this.patrones});

  @override
  Widget build(BuildContext context) {
    final maxFrecuencia = patrones.fold<int>(0, (m, p) => p.frecuencia > m ? p.frecuencia : m);
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            ...patrones.map((p) => BarraPatronWidget(
                  patron: p,
                  maxFrecuencia: maxFrecuencia,
                )),
          ],
        ),
      ),
    );
  }
}

// ─── Sección de sesiones ──────────────────────────────────────────────────────

class _SeccionSesiones extends StatelessWidget {
  final List<SesionResumen> sesiones;
  const _SeccionSesiones({required this.sesiones});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                child: Text(
                  'Sin sesiones registradas.',
                  style: TextStyle(color: Colors.black54),
                ),
              )
            else
              ...sesiones.map((s) => _FilaSesion(sesion: s)),
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
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
