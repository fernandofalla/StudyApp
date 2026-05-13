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
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    const sep = '─────────────────────────────────────';

    final buf = StringBuffer();
    buf.writeln(sep);
    buf.writeln('REPORTE DE AVANCE — AdaptaMat');
    buf.writeln('Fecha: $fecha');
    buf.writeln(sep);
    buf.writeln();

    // ── Resumen del grupo (tabla) ──────────────────────────────────────────
    buf.writeln('RESUMEN DEL GRUPO');
    buf.writeln();
    buf.writeln('${'Estudiante'.padRight(20)}${'Nivel'.padRight(13)}Sesiones');
    buf.writeln('─' * 40);
    for (final r in _resumenGrupo) {
      final nombre = (r['nombre'] as String? ?? '—');
      final theta = (r['theta_actual'] as num?)?.toDouble() ?? 0.0;
      final nivel = ResumenGrupo.nivelDesdeTheta(theta);
      final sesiones = (r['total_sesiones'] as int?) ?? 0;
      buf.writeln(
          '${nombre.padRight(20)}${nivel.padRight(13)}$sesiones');
    }
    if (_resumenGrupo.isEmpty) {
      buf.writeln('Sin datos de sesiones aún.');
    }
    buf.writeln();

    // ── Patrones de error más frecuentes (lista numerada) ─────────────────
    buf.writeln(sep);
    buf.writeln('PATRONES DE ERROR MÁS FRECUENTES');
    buf.writeln();
    if (_patronesGrupo.isEmpty) {
      buf.writeln('Sin patrones detectados aún.');
    } else {
      for (var i = 0; i < _patronesGrupo.length; i++) {
        final p = _patronesGrupo[i];
        final codigo = p['codigo_patron'] as String? ?? '—';
        final frecTotal = (p['frecuencia_total'] as int?) ?? 0;
        final desc = ResumenGrupo.descripcionPatron(codigo);
        final label = frecTotal == 1 ? 'vez' : 'veces';
        buf.writeln('${i + 1}. $desc — $frecTotal $label');
      }
    }
    buf.writeln(sep);

    return buf.toString();
  }
}
