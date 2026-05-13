// lib/presentation/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:adaptamat/domain/usecases/resumen_grupo.dart';
import 'package:adaptamat/presentation/blocs/dashboard_bloc.dart';
import 'package:adaptamat/presentation/screens/exportacion_screen.dart';
import 'package:adaptamat/presentation/screens/perfil_estudiante_screen.dart';

const _azulOscuro = Color(0xFF1F3864);

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc()..add(const CargarDashboard()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardBloc, DashboardState>(
      listenWhen: (_, current) =>
          current is PerfilEstudianteCargado || current is ReporteGenerado,
      listener: (context, state) {
        if (state is PerfilEstudianteCargado) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PerfilEstudianteScreen(
                perfil: state.perfil,
                historialTheta: state.historialTheta,
              ),
            ),
          ).then((_) {
            if (context.mounted) {
              context.read<DashboardBloc>().add(const CargarDashboard());
            }
          });
        }
        if (state is ReporteGenerado) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ExportacionScreen(textoReporte: state.textoReporte),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            backgroundColor: _azulOscuro,
            foregroundColor: Colors.white,
            title: const Text('Dashboard Docente'),
            actions: [
              if (state is DashboardCargado)
                IconButton(
                  icon: const Icon(Icons.file_download_outlined),
                  tooltip: 'Exportar reporte',
                  onPressed: () =>
                      context.read<DashboardBloc>().add(const GenerarReporte()),
                ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Actualizar',
                onPressed: () =>
                    context.read<DashboardBloc>().add(const CargarDashboard()),
              ),
            ],
          ),
          body: _buildCuerpo(context, state),
        );
      },
    );
  }

  Widget _buildCuerpo(BuildContext context, DashboardState state) {
    if (state is DashboardCargando || state is DashboardInicial) {
      return const Center(
        child: CircularProgressIndicator(color: _azulOscuro),
      );
    }

    if (state is DashboardError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(state.mensaje, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    context.read<DashboardBloc>().add(const CargarDashboard()),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is DashboardCargado) {
      if (state.resumenGrupo.isEmpty) {
        return const Center(
          child: Text(
            'No hay estudiantes registrados.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PanelGrupo(resumenGrupo: state.resumenGrupo),
          if (state.patronesGrupo.isNotEmpty)
            _PanelPatrones(patronesGrupo: state.patronesGrupo),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: state.resumenGrupo.length,
              itemBuilder: (_, i) {
                final est = state.resumenGrupo[i];
                return _TarjetaEstudiante(
                  datos: est,
                  onTap: () {
                    final id = est['id'] as int?;
                    if (id != null) {
                      context
                          .read<DashboardBloc>()
                          .add(SeleccionarEstudiante(id));
                    }
                  },
                );
              },
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

// ─── Panel de resumen del grupo ───────────────────────────────────────────────

class _PanelGrupo extends StatelessWidget {
  final List<Map<String, dynamic>> resumenGrupo;
  const _PanelGrupo({required this.resumenGrupo});

  @override
  Widget build(BuildContext context) {
    final dist = <String, int>{
      'Inicio': 0,
      'En proceso': 0,
      'Logrado': 0,
    };
    double sumaTheta = 0;
    for (final r in resumenGrupo) {
      final theta = (r['theta_actual'] as num).toDouble();
      sumaTheta += theta;
      final nivel = ResumenGrupo.nivelDesdeTheta(theta);
      dist[nivel] = (dist[nivel] ?? 0) + 1;
    }
    final promTheta = resumenGrupo.isNotEmpty
        ? sumaTheta / resumenGrupo.length
        : 0.0;

    return Container(
      color: _azulOscuro,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${resumenGrupo.length} estudiante${resumenGrupo.length != 1 ? 's' : ''}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatCard(
                label: 'θ promedio',
                valor: promTheta.toStringAsFixed(2),
              ),
              const SizedBox(width: 10),
              _StatCard(
                label: 'Nivel grupo',
                valor: ResumenGrupo.nivelDesdeTheta(promTheta),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _BarraDistribucion(distribucion: dist, total: resumenGrupo.length),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String valor;
  const _StatCard({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarraDistribucion extends StatelessWidget {
  final Map<String, int> distribucion;
  final int total;
  const _BarraDistribucion(
      {required this.distribucion, required this.total});

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();

    final niveles = [
      ('Inicio', const Color(0xFFC62828)),
      ('En proceso', const Color(0xFFF9A825)),
      ('Logrado', const Color(0xFF2E7D32)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distribución de niveles',
          style: TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: niveles.map((entry) {
              final count = distribucion[entry.$1] ?? 0;
              if (count == 0) return const SizedBox.shrink();
              return Expanded(
                flex: count,
                child: Container(
                  height: 18,
                  color: entry.$2,
                  alignment: Alignment.center,
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: niveles.map((entry) {
            final count = distribucion[entry.$1] ?? 0;
            if (count == 0) return const SizedBox.shrink();
            return Expanded(
              flex: count,
              child: Text(
                entry.$1,
                style: const TextStyle(color: Colors.white60, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Panel de patrones del grupo ─────────────────────────────────────────────

class _PanelPatrones extends StatelessWidget {
  final List<Map<String, dynamic>> patronesGrupo;
  const _PanelPatrones({required this.patronesGrupo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _azulOscuro.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Patrones frecuentes del grupo',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ...patronesGrupo.take(3).map((p) {
            final codigo = p['codigo_patron'] as String;
            final frecTotal = p['frecuencia_total'] ?? 0;
            final afectados = p['estudiantes_afectados'] ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _azulOscuro.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      codigo,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _azulOscuro,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ResumenGrupo.descripcionPatron(codigo),
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black87),
                    ),
                  ),
                  Text(
                    '$frecTotal×  $afectados est.',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Tarjeta de estudiante (inline, basada en Map) ────────────────────────────

class _TarjetaEstudiante extends StatelessWidget {
  final Map<String, dynamic> datos;
  final VoidCallback onTap;

  const _TarjetaEstudiante({required this.datos, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final nombre = datos['nombre'] as String? ?? '—';
    final theta = (datos['theta_actual'] as num?)?.toDouble() ?? 0.0;
    final sesiones = datos['total_sesiones'] ?? 0;
    final nivel = ResumenGrupo.nivelDesdeTheta(theta);
    final colorNivel = ResumenGrupo.colorDesdeNivel(nivel);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _NivelChip(nivel: nivel, color: colorNivel),
                        const SizedBox(width: 6),
                        Text(
                          'θ ${theta.toStringAsFixed(2)}  ·  $sesiones sesión${sesiones != 1 ? 'es' : ''}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
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
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        nivel,
        style: TextStyle(
            fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
