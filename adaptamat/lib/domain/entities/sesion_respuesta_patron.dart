// lib/domain/entities/sesion_respuesta_patron.dart
// Capa de dominio — Entidades de sesión, respuesta y patrón de error

class Sesion {
  final int? id;
  final int estudianteId;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final String tema;

  Sesion({
    this.id,
    required this.estudianteId,
    required this.fechaInicio,
    this.fechaFin,
    required this.tema,
  });

  Sesion copyWith({
    int? id,
    int? estudianteId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? tema,
  }) {
    return Sesion(
      id: id ?? this.id,
      estudianteId: estudianteId ?? this.estudianteId,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      tema: tema ?? this.tema,
    );
  }
}

class Respuesta {
  final int? id;
  final int sesionId;
  final int itemId;
  final int respuestaDada;
  final bool correcto;
  final DateTime timestamp;

  Respuesta({
    this.id,
    required this.sesionId,
    required this.itemId,
    required this.respuestaDada,
    required this.correcto,
    required this.timestamp,
  });

  Respuesta copyWith({
    int? id,
    int? sesionId,
    int? itemId,
    int? respuestaDada,
    bool? correcto,
    DateTime? timestamp,
  }) {
    return Respuesta(
      id: id ?? this.id,
      sesionId: sesionId ?? this.sesionId,
      itemId: itemId ?? this.itemId,
      respuestaDada: respuestaDada ?? this.respuestaDada,
      correcto: correcto ?? this.correcto,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class PatronError {
  final int? id;
  final int estudianteId;
  final String codigoPatron;
  final int frecuencia;
  final DateTime ultimaDeteccion;

  PatronError({
    this.id,
    required this.estudianteId,
    required this.codigoPatron,
    required this.frecuencia,
    required this.ultimaDeteccion,
  });

  PatronError copyWith({
    int? id,
    int? estudianteId,
    String? codigoPatron,
    int? frecuencia,
    DateTime? ultimaDeteccion,
  }) {
    return PatronError(
      id: id ?? this.id,
      estudianteId: estudianteId ?? this.estudianteId,
      codigoPatron: codigoPatron ?? this.codigoPatron,
      frecuencia: frecuencia ?? this.frecuencia,
      ultimaDeteccion: ultimaDeteccion ?? this.ultimaDeteccion,
    );
  }
}
