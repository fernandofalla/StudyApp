// lib/domain/entities/estudiante.dart
// Capa de dominio — Entidad Estudiante con propiedades básicas y copyWith

class Estudiante {
  final int? id;
  final String nombre;
  final String grado;
  final double thetaActual;
  final DateTime fechaRegistro;

  Estudiante({
    this.id,
    required this.nombre,
    required this.grado,
    this.thetaActual = 0.0,
    required this.fechaRegistro,
  });

  Estudiante copyWith({
    int? id,
    String? nombre,
    String? grado,
    double? thetaActual,
    DateTime? fechaRegistro,
  }) {
    return Estudiante(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      grado: grado ?? this.grado,
      thetaActual: thetaActual ?? this.thetaActual,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }
}
