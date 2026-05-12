// lib/presentation/blocs/sesion_bloc.dart
// BLoC que coordina el flujo completo de una sesión adaptativa.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:adaptamat/data/datasources/item_sesion_datasource.dart';
import 'package:adaptamat/domain/entities/item.dart';
import 'package:adaptamat/domain/entities/sesion_respuesta_patron.dart';
import 'package:adaptamat/domain/usecases/motor_adaptativo.dart';
import 'package:adaptamat/domain/usecases/diagnostico_patrones.dart';
import 'package:adaptamat/domain/usecases/mapa_prerequisitos.dart';

// ─── Eventos ─────────────────────────────────────────────────────────────────

abstract class SesionEvent extends Equatable {
  const SesionEvent();
  @override
  List<Object?> get props => [];
}

class IniciarSesion extends SesionEvent {
  final int estudianteId;
  final double thetaInicial;
  final String tema;

  const IniciarSesion({
    required this.estudianteId,
    required this.thetaInicial,
    required this.tema,
  });

  @override
  List<Object?> get props => [estudianteId, thetaInicial, tema];
}

class ResponderItem extends SesionEvent {
  final int respuestaDada;

  const ResponderItem(this.respuestaDada);

  @override
  List<Object?> get props => [respuestaDada];
}

class ContinuarTrasRemediacion extends SesionEvent {
  const ContinuarTrasRemediacion();
}

class FinalizarSesion extends SesionEvent {
  const FinalizarSesion();
}

// ─── Estados ─────────────────────────────────────────────────────────────────

abstract class SesionState extends Equatable {
  const SesionState();
  @override
  List<Object?> get props => [];
}

class SesionInicial extends SesionState {
  const SesionInicial();
}

class SesionCargando extends SesionState {
  const SesionCargando();
}

class SesionConItem extends SesionState {
  final Item item;
  final double theta;
  final int itemsRespondidos;
  final String subtemaActivo;

  const SesionConItem({
    required this.item,
    required this.theta,
    required this.itemsRespondidos,
    required this.subtemaActivo,
  });

  @override
  List<Object?> get props => [item, theta, itemsRespondidos, subtemaActivo];
}

class SesionRetroalimentacion extends SesionState {
  final bool correcto;
  final int respuestaCorrecta;

  const SesionRetroalimentacion({
    required this.correcto,
    required this.respuestaCorrecta,
  });

  @override
  List<Object?> get props => [correcto, respuestaCorrecta];
}

class SesionRemediacion extends SesionState {
  final String codigoPatron;
  final String? contenido;

  const SesionRemediacion({
    required this.codigoPatron,
    this.contenido,
  });

  @override
  List<Object?> get props => [codigoPatron, contenido];
}

class SesionSubtemaDominado extends SesionState {
  final String subtema;
  final String? siguienteSubtema;

  const SesionSubtemaDominado({
    required this.subtema,
    this.siguienteSubtema,
  });

  @override
  List<Object?> get props => [subtema, siguienteSubtema];
}

class SesionFinalizada extends SesionState {
  final double thetaFinal;
  final int itemsRespondidos;

  const SesionFinalizada({
    required this.thetaFinal,
    required this.itemsRespondidos,
  });

  @override
  List<Object?> get props => [thetaFinal, itemsRespondidos];
}

class SesionError extends SesionState {
  final String mensaje;

  const SesionError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class SesionBloc extends Bloc<SesionEvent, SesionState> {
  final ItemDatasource _itemDs = ItemDatasource();
  final SesionDatasource _sesionDs = SesionDatasource();

  // Estado interno de la sesión en curso
  int? _sesionId;
  int? _estudianteId;
  double _theta = 0.0;
  String _subtema = '';
  List<Item> _banco = [];
  Item? _itemActual;
  int _itemsRespondidos = 0;
  final Set<int> _presentados = {};
  final List<Respuesta> _historial = [];

  SesionBloc() : super(const SesionInicial()) {
    on<IniciarSesion>(_onIniciarSesion);
    on<ResponderItem>(_onResponderItem);
    on<ContinuarTrasRemediacion>(_onContinuarTrasRemediacion);
    on<FinalizarSesion>(_onFinalizarSesion);
  }

  // ── IniciarSesion ──────────────────────────────────────────────────────────
  Future<void> _onIniciarSesion(
    IniciarSesion event,
    Emitter<SesionState> emit,
  ) async {
    emit(const SesionCargando());
    try {
      _estudianteId = event.estudianteId;
      _theta = event.thetaInicial;
      _subtema = MapaPrerequisitos.subtemaInicial(event.tema);
      _itemsRespondidos = 0;
      _presentados.clear();
      _historial.clear();

      _banco = await _itemDs.obtenerPorSubtema(_subtema);

      _sesionId = await _sesionDs.iniciarSesion(Sesion(
        estudianteId: event.estudianteId,
        fechaInicio: DateTime.now(),
        tema: event.tema,
      ));

      final diagnostico =
          MotorAdaptativo.seleccionarItemsDiagnostico(_subtema, _banco);
      final candidatos = diagnostico.isNotEmpty ? diagnostico : _banco;

      _itemActual = candidatos.isNotEmpty ? candidatos.first : null;
      if (_itemActual == null) {
        emit(const SesionError('No hay ítems disponibles para este subtema.'));
        return;
      }

      if (_itemActual!.id != null) _presentados.add(_itemActual!.id!);

      emit(SesionConItem(
        item: _itemActual!,
        theta: _theta,
        itemsRespondidos: _itemsRespondidos,
        subtemaActivo: _subtema,
      ));
    } catch (e) {
      emit(SesionError('Error al iniciar la sesión: $e'));
    }
  }

  // ── ResponderItem ──────────────────────────────────────────────────────────
  Future<void> _onResponderItem(
    ResponderItem event,
    Emitter<SesionState> emit,
  ) async {
    if (_sesionId == null || _itemActual == null) return;

    final correcto = event.respuestaDada == _itemActual!.respuestaCorrecta;

    final respuesta = Respuesta(
      sesionId: _sesionId!,
      itemId: _itemActual!.id ?? 0,
      respuestaDada: event.respuestaDada,
      correcto: correcto,
      timestamp: DateTime.now(),
    );

    await _sesionDs.registrarRespuesta(respuesta);
    _historial.add(respuesta);
    _theta = MotorAdaptativo.actualizarTheta(_theta, correcto);
    _itemsRespondidos++;

    emit(SesionRetroalimentacion(
      correcto: correcto,
      respuestaCorrecta: _itemActual!.respuestaCorrecta,
    ));

    final patron = DiagnosticoPatrones.evaluar(
      _historial,
      _subtema,
      event.respuestaDada,
      _itemActual!.respuestaCorrecta,
      correcto,
    );

    if (patron != null) {
      await _sesionDs.registrarOActualizarPatron(_estudianteId!, patron);
      final contenido = await _sesionDs.obtenerContenidoRemediacion(patron);
      emit(SesionRemediacion(codigoPatron: patron, contenido: contenido));
      return;
    }

    await _emitirSiguienteEstado(emit);
  }

  // ── ContinuarTrasRemediacion ───────────────────────────────────────────────
  Future<void> _onContinuarTrasRemediacion(
    ContinuarTrasRemediacion event,
    Emitter<SesionState> emit,
  ) async {
    await _emitirSiguienteEstado(emit);
  }

  // ── FinalizarSesion ────────────────────────────────────────────────────────
  Future<void> _onFinalizarSesion(
    FinalizarSesion event,
    Emitter<SesionState> emit,
  ) async {
    if (_sesionId != null) {
      await _sesionDs.cerrarSesion(_sesionId!);
    }
    emit(SesionFinalizada(
      thetaFinal: _theta,
      itemsRespondidos: _itemsRespondidos,
    ));
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<void> _emitirSiguienteEstado(Emitter<SesionState> emit) async {
    if (MotorAdaptativo.evaluarDominio(
      theta: _theta,
      itemsRespondidos: _itemsRespondidos,
    )) {
      emit(SesionSubtemaDominado(
        subtema: _subtema,
        siguienteSubtema: MapaPrerequisitos.siguienteSubtema(_subtema),
      ));
      return;
    }

    final siguiente = MotorAdaptativo.seleccionarSiguienteItem(
      _theta,
      _subtema,
      _banco,
      _presentados,
    );

    if (siguiente == null) {
      emit(SesionSubtemaDominado(
        subtema: _subtema,
        siguienteSubtema: MapaPrerequisitos.siguienteSubtema(_subtema),
      ));
      return;
    }

    _itemActual = siguiente;
    if (_itemActual!.id != null) _presentados.add(_itemActual!.id!);

    emit(SesionConItem(
      item: _itemActual!,
      theta: _theta,
      itemsRespondidos: _itemsRespondidos,
      subtemaActivo: _subtema,
    ));
  }
}
