// lib/presentation/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:adaptamat/presentation/blocs/dashboard_bloc.dart';
import 'package:adaptamat/presentation/screens/exportacion_screen.dart';
import 'package:adaptamat/presentation/screens/perfil_estudiante_screen.dart';
import 'package:adaptamat/presentation/widgets/barra_patron_widget.dart';
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
        if (state is DashboardCargando ||
            state is DashboardInicial ||
            state is PerfilEstudianteCargado ||
            state is ReporteGenerado) {
          return Scaffold(
            backgroundColor: Colors.grey.shade100,
            appBar: _appBarSimple(context),
            body: const Center(
              child: CircularProgressIndicator(color: _azulOscuro),
            ),
          );
        }

        if (state is DashboardError) {
          return Scaffold(
            backgroundColor: Colors.grey.shade100,
            appBar: _appBarSimple(context),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
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
            ),
          );
        }

        if (state is DashboardCargado) {
          // DefaultTabController DEBE envolver el Scaffold para que
          // el TabBar en el AppBar encuentre su controller ancestro.
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: Colors.grey.shade100,
              appBar: AppBar(
                backgroundColor: _azulOscuro,
                foregroundColor: Colors.white,
                title: const Text('Panel docente'),
                bottom: const TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(text: 'Grupo'),
                    Tab(text: 'Patrones de error'),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.download),
                    tooltip: 'Exportar reporte',
                    onPressed: () => context
                        .read<DashboardBloc>()
                        .add(const GenerarReporte()),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Actualizar',
                    onPressed: () => context
                        .read<DashboardBloc>()
                        .add(const CargarDashboard()),
                  ),
                ],
              ),
              body: TabBarView(
                children: [
                  _TabGrupo(
                    resumenGrupo: state.resumenGrupo,
                    onSeleccionar: (id) => context
                        .read<DashboardBloc>()
                        .add(SeleccionarEstudiante(id)),
                  ),
                  _TabPatrones(patronesGrupo: state.patronesGrupo),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  AppBar _appBarSimple(BuildContext context) {
    return AppBar(
      backgroundColor: _azulOscuro,
      foregroundColor: Colors.white,
      title: const Text('Panel docente'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Actualizar',
          onPressed: () =>
              context.read<DashboardBloc>().add(const CargarDashboard()),
        ),
      ],
    );
  }
}

// ─── Pestaña Grupo ────────────────────────────────────────────────────────────

class _TabGrupo extends StatelessWidget {
  final List<Map<String, dynamic>> resumenGrupo;
  final void Function(int estudianteId) onSeleccionar;

  const _TabGrupo({
    required this.resumenGrupo,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    if (resumenGrupo.isEmpty) {
      return const Center(
        child: Text(
          'Sin datos de sesiones aún',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: resumenGrupo.length,
      itemBuilder: (_, i) {
        return TarjetaEstudianteWidget(
          datos: resumenGrupo[i],
          onSeleccionar: onSeleccionar,
        );
      },
    );
  }
}

// ─── Pestaña Patrones de error ────────────────────────────────────────────────

class _TabPatrones extends StatelessWidget {
  final List<Map<String, dynamic>> patronesGrupo;

  const _TabPatrones({required this.patronesGrupo});

  @override
  Widget build(BuildContext context) {
    if (patronesGrupo.isEmpty) {
      return const Center(
        child: Text(
          'Sin patrones detectados aún',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    final maxFrecuencia = patronesGrupo.fold<int>(
      0,
      (m, p) {
        final f = (p['frecuencia_total'] as int?) ?? 0;
        return f > m ? f : m;
      },
    );

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: patronesGrupo.length,
      separatorBuilder: (context2, i2) => const SizedBox(height: 4),
      itemBuilder: (_, i) {
        final p = patronesGrupo[i];
        return BarraPatronWidget(
          codigoPatron: p['codigo_patron'] as String,
          frecuenciaTotal: (p['frecuencia_total'] as int?) ?? 0,
          estudiantesAfectados: (p['estudiantes_afectados'] as int?) ?? 0,
          maxFrecuencia: maxFrecuencia,
        );
      },
    );
  }
}
