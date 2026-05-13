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

class CargarDashboard extends DashboardEvent {
  const CargarDashboard();
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
  final List<ResumenEstudiante> estudiantes;
  final Map<String, int> distribucionNiveles;
  final double promedioTheta;
  final double promedioAcierto;

  const DashboardCargado({
    required this.estudiantes,
    required this.distribucionNiveles,
    required this.promedioTheta,
    required this.promedioAcierto,
  });

  @override
  List<Object?> get props => [estudiantes, distribucionNiveles, promedioTheta, promedioAcierto];
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

  DashboardBloc() : super(const DashboardInicial()) {
    on<CargarDashboard>(_onCargarDashboard);
  }

  Future<void> _onCargarDashboard(
    CargarDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardCargando());
    try {
      final estudiantes = await _ds.obtenerResumenEstudiantes();
      emit(DashboardCargado(
        estudiantes: estudiantes,
        distribucionNiveles: ResumenGrupo.distribuirPorNivel(estudiantes),
        promedioTheta: ResumenGrupo.promedioTheta(estudiantes),
        promedioAcierto: ResumenGrupo.promedioAcierto(estudiantes),
      ));
    } catch (e) {
      emit(DashboardError('Error al cargar el dashboard: $e'));
    }
  }
}
