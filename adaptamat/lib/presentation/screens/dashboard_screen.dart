// lib/presentation/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:adaptamat/presentation/blocs/dashboard_bloc.dart';
import 'package:adaptamat/presentation/screens/exportacion_screen.dart';
import 'package:adaptamat/presentation/screens/perfil_estudiante_screen.dart';
import 'package:adaptamat/presentation/widgets/tarjeta_estudiante_widget.dart';

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
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            backgroundColor: _azulOscuro,
            foregroundColor: Colors.white,
            title: const Text('Dashboard Docente'),
            actions: [
              if (state is DashboardCargado && state.estudiantes.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.file_download_outlined),
                  tooltip: 'Exportar reporte',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExportacionScreen(
                        estudiantes: state.estudiantes,
                      ),
                    ),
                  ),
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
                onPressed: () => context
                    .read<DashboardBloc>()
                    .add(const CargarDashboard()),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is DashboardCargado) {
      if (state.estudiantes.isEmpty) {
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
          _PanelGrupo(state: state),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: state.estudiantes.length,
              itemBuilder: (_, i) {
                final est = state.estudiantes[i];
                return TarjetaEstudianteWidget(
                  estudiante: est,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PerfilEstudianteScreen(estudiante: est),
                    ),
                  ),
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
  final DashboardCargado state;
  const _PanelGrupo({required this.state});

  @override
  Widget build(BuildContext context) {
    final dist = state.distribucionNiveles;

    return Container(
      color: _azulOscuro,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${state.estudiantes.length} estudiante${state.estudiantes.length != 1 ? 's' : ''}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatCard(
                label: 'θ promedio',
                valor: state.promedioTheta.toStringAsFixed(2),
              ),
              const SizedBox(width: 10),
              _StatCard(
                label: 'Acierto prom.',
                valor:
                    '${(state.promedioAcierto * 100).toStringAsFixed(1)}%',
              ),
            ],
          ),
          const SizedBox(height: 10),
          _BarraDistribucion(distribucion: dist, total: state.estudiantes.length),
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
                fontSize: 20,
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
  const _BarraDistribucion({required this.distribucion, required this.total});

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();

    final niveles = [
      ('Inicial', Colors.red.shade300),
      ('Básico', Colors.orange.shade300),
      ('Intermedio', Colors.blue.shade300),
      ('Avanzado', Colors.green.shade300),
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
              final flex = count > 0 ? count : 0;
              if (flex == 0) return const SizedBox.shrink();
              return Expanded(
                flex: flex,
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
