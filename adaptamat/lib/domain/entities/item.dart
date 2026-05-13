// lib/domain/entities/item.dart
// Capa de dominio — Entidad Item con datos de ítem, opciones y distractores

class Item {
  final int? id;
  final String tema;
  final String subtema;
  final double dificultadB;
  final String enunciado;
  final List<String> opciones;
  final int respuestaCorrecta;
  final String? codigoPatronDistractor;
  final String? figura;

  Item({
    this.id,
    required this.tema,
    required this.subtema,
    required this.dificultadB,
    required this.enunciado,
    required this.opciones,
    required this.respuestaCorrecta,
    this.codigoPatronDistractor,
    this.figura,
  });

  Item copyWith({
    int? id,
    String? tema,
    String? subtema,
    double? dificultadB,
    String? enunciado,
    List<String>? opciones,
    int? respuestaCorrecta,
    String? codigoPatronDistractor,
    String? figura,
  }) {
    return Item(
      id: id ?? this.id,
      tema: tema ?? this.tema,
      subtema: subtema ?? this.subtema,
      dificultadB: dificultadB ?? this.dificultadB,
      enunciado: enunciado ?? this.enunciado,
      opciones: opciones ?? this.opciones,
      respuestaCorrecta: respuestaCorrecta ?? this.respuestaCorrecta,
      codigoPatronDistractor: codigoPatronDistractor ?? this.codigoPatronDistractor,
      figura: figura ?? this.figura,
    );
  }
}
