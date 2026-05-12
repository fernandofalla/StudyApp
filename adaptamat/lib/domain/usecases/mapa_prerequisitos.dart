// lib/domain/usecases/mapa_prerequisitos.dart
// Grafo de prerrequisitos entre subtemas para los temas de primer grado.

class MapaPrerequisitos {
  // Subtemas ordenados de menor a mayor dificultad por tema.
  static const Map<String, List<String>> _subtemasPorTema = {
    'numeros_y_operaciones': [
      'conteo',
      'valor_posicional',
      'adicion',
      'sustraccion',
    ],
    'geometria': [
      'atributos_geometricos',
      'figuras_geometricas',
      'clasificacion_geometrica',
    ],
  };

  // Mapa de prerrequisitos: subtema → subtemas que deben estar dominados antes.
  static const Map<String, List<String>> _prerequisitos = {
    'conteo': [],
    'valor_posicional': ['conteo'],
    'adicion': ['conteo'],
    'sustraccion': ['adicion'],
    'atributos_geometricos': [],
    'figuras_geometricas': ['atributos_geometricos'],
    'clasificacion_geometrica': ['figuras_geometricas'],
  };

  /// Primer subtema a trabajar para un tema (punto de entrada de la secuencia).
  static String subtemaInicial(String tema) {
    return _subtemasPorTema[tema]!.first;
  }

  /// Siguiente subtema dentro de la secuencia lineal del mismo tema,
  /// o null si [subtemaActual] es el último.
  static String? siguienteSubtema(String subtemaActual) {
    for (final subtemas in _subtemasPorTema.values) {
      final idx = subtemas.indexOf(subtemaActual);
      if (idx != -1 && idx + 1 < subtemas.length) {
        return subtemas[idx + 1];
      }
    }
    return null;
  }

  /// True cuando todos los prerrequisitos de [subtema] están en [subtemasDominados].
  static bool estaDisponible(String subtema, List<String> subtemasDominados) {
    final requisitos = _prerequisitos[subtema] ?? const [];
    return requisitos.every(subtemasDominados.contains);
  }

  /// Lista ordenada de subtemas que pertenecen a [tema].
  static List<String> subtemasDeTema(String tema) {
    return List.unmodifiable(_subtemasPorTema[tema] ?? const []);
  }
}
