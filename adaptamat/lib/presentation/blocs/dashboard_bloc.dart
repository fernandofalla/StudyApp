// lib/presentation/blocs/dashboard_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:adaptamat/data/datasources/dashboard_datasource.dart';
import 'package:adaptamat/domain/usecases/resumen_grupo.dart';

// ─── Eventos ─────────────────────────────────────────────────────────────────

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

/// Carga el resumen del grupo y los patrones al abrir el dashboard.
class CargarDashboard extends DashboardEvent {
  const CargarDashboard();
}

/// Carga el perfil individual del estudiante seleccionado.
class SeleccionarEstudiante extends DashboardEvent {
  final int estudianteId;
  const SeleccionarEstudiante(this.estudianteId);
  @override
  List<Object?> get props => [estudianteId];
}

/// Prepara el texto del reporte para exportación.
class GenerarReporte extends DashboardEvent {
  const GenerarReporte();
}

// ─── Estados ─────────────────────────────────────────────────────────────────

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInicial extends DashboardState {
  const DashboardInicial();
}

class DashboardCargando extends DashboardState {
  const DashboardCargando();
}

class DashboardCargado extends DashboardState {
  final List<Map<String, dynamic>> resumenGrupo;
  final List<Map<String, dynamic>> patronesGrupo;

  const DashboardCargado({
    required this.resumenGrupo,
    required this.patronesGrupo,
  });

  @override
  List<Object?> get props => [resumenGrupo, patronesGrupo];
}

class PerfilEstudianteCargado extends DashboardState {
  final Map<String, dynamic> perfil;
  final List<Map<String, dynamic>> historialTheta;

  const PerfilEstudianteCargado({
    required this.perfil,
    required this.historialTheta,
  });

  @override
  List<Object?> get props => [perfil, historialTheta];
}

class ReporteGenerado extends DashboardState {
  final String textoReporte;

  const ReporteGenerado({required this.textoReporte});

  @override
  List<Object?> get props => [textoReporte];
}

class DashboardError extends DashboardState {
  final String mensaje;

  const DashboardError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardDatasource _ds = DashboardDatasource();

  // Estado interno para GenerarReporte
  List<Map<String, dynamic>> _resumenGrupo = [];
  List<Map<String, dynamic>> _patronesGrupo = [];

  DashboardBloc() : super(const DashboardInicial()) {
    on<CargarDashboard>(_onCargarDashboard);
    on<SeleccionarEstudiante>(_onSeleccionarEstudiante);
    on<GenerarReporte>(_onGenerarReporte);
  }

  // ── CargarDashboard ────────────────────────────────────────────────────────

  Future<void> _onCargarDashboard(
    CargarDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardCargando());
    try {
      _resumenGrupo = await _ds.obtenerResumenGrupo();
      _patronesGrupo = await _ds.obtenerPatronesDelGrupo();
      emit(DashboardCargado(
        resumenGrupo: _resumenGrupo,
        patronesGrupo: _patronesGrupo,
      ));
    } catch (e) {
      emit(DashboardError('Error al cargar el dashboard: $e'));
    }
  }

  // ── SeleccionarEstudiante ──────────────────────────────────────────────────

  Future<void> _onSeleccionarEstudiante(
    SeleccionarEstudiante event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardCargando());
    try {
      final perfil = await _ds.obtenerPerfilEstudiante(event.estudianteId);
      final historial = await _ds.obtenerHistorialTheta(event.estudianteId);
      emit(PerfilEstudianteCargado(
        perfil: perfil,
        historialTheta: historial,
      ));
    } catch (e) {
      emit(DashboardError('Error al cargar el perfil: $e'));
    }
  }

  // ── GenerarReporte ─────────────────────────────────────────────────────────

  Future<void> _onGenerarReporte(
    GenerarReporte event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final texto = _construirTextoReporte();
      emit(ReporteGenerado(textoReporte: texto));
    } catch (e) {
      emit(DashboardError('Error al generar el reporte: $e'));
    }
  }

  String _construirTextoReporte() {
    final now = DateTime.now();
    final fecha =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final buf = StringBuffer();
    buf.writeln('══════════════════════════════════════');
    buf.writeln('  REPORTE DE PROGRESO — AdaptaMat');
    buf.writeln('  Generado: $fecha');
    buf.writeln('══════════════════════════════════════');
    buf.writeln();

    // Resumen del grupo
    buf.writeln('RESUMEN DEL GRUPO');
    buf.writeln('─────────────────');
    buf.writeln('Total estudiantes : ${_resumenGrupo.length}');

    if (_resumenGrupo.isNotEmpty) {
      final thetaPromedio = _resumenGrupo.fold<double>(
            0,
            (acc, r) => acc + (r['theta_actual'] as num).toDouble(),
          ) /
          _resumenGrupo.length;
      buf.writeln('θ promedio        : ${thetaPromedio.toStringAsFixed(2)}');

      final dist = <String, int>{
        'Inicio': 0,
        'En proceso': 0,
        'Logrado': 0,
      };
      for (final r in _resumenGrupo) {
        final nivel =
            ResumenGrupo.nivelDesdeTheta((r['theta_actual'] as num).toDouble());
        dist[nivel] = (dist[nivel] ?? 0) + 1;
      }
      buf.writeln();
      buf.writeln('Distribución por nivel:');
      dist.forEach((nivel, cantidad) {
        buf.writeln('  ${nivel.padRight(12)}: $cantidad estudiante(s)');
      });
    }

    // Patrones del grupo
    if (_patronesGrupo.isNotEmpty) {
      buf.writeln();
      buf.writeln('PATRONES DE ERROR DEL GRUPO');
      buf.writeln('───────────────────────────');
      for (final p in _patronesGrupo) {
        final codigo = p['codigo_patron'] as String;
        final frecTotal = p['frecuencia_total'];
        final afectados = p['estudiantes_afectados'];
        buf.writeln(
            '  $codigo — ${ResumenGrupo.descripcionPatron(codigo)}');
        buf.writeln(
            '    Frecuencia total: $frecTotal  |  Estudiantes afectados: $afectados');
      }
    }

    // Detalle por estudiante
    buf.writeln();
    buf.writeln('DETALLE POR ESTUDIANTE');
    buf.writeln('──────────────────────');
    for (final r in _resumenGrupo) {
      final theta = (r['theta_actual'] as num).toDouble();
      final nivel = ResumenGrupo.nivelDesdeTheta(theta);
      buf.writeln('${r['nombre']}');
      buf.writeln('  Nivel   : $nivel  (θ = ${theta.toStringAsFixed(2)})');
      buf.writeln('  Sesiones: ${r['total_sesiones'] ?? 0}');
      buf.writeln();
    }

    buf.writeln('══════════════════════════════════════');
    return buf.toString();
  }
}
