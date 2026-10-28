// lib/core/constants/database_constants.dart
// Constantes de nombres de tablas y columnas para la base de datos SQLite (AdaptaMat)

class DatabaseConstants {
  DatabaseConstants._();

  static const String databaseName = 'adaptamat.db';
  static const int databaseVersion = 3;

  // ─── Nombres de Tablas ──────────────────────────────────────────────────────
  static const String tableEstudiante = 'estudiante';
  static const String tableItem = 'item';
  static const String tableSesion = 'sesion';
  static const String tableRespuesta = 'respuesta';
  static const String tablePatronError = 'patron_error';
  static const String tableContenidoRemediacion = 'contenido_remediacion';

  // ─── Columnas: estudiante ───────────────────────────────────────────────────
  static const String colEstudianteId = 'id';
  static const String colEstudianteNombre = 'nombre';
  static const String colEstudianteGrado = 'grado';
  static const String colEstudianteThetaActual = 'theta_actual';
  static const String colEstudianteFechaRegistro = 'fecha_registro';

  // ─── Columnas: item ─────────────────────────────────────────────────────────
  static const String colItemId = 'id';
  static const String colItemTema = 'tema';
  static const String colItemSubtema = 'subtema';
  static const String colItemDificultadB = 'dificultad_b';
  static const String colItemEnunciado = 'enunciado';
  static const String colItemOpciones = 'opciones';
  static const String colItemRespuestaCorrecta = 'respuesta_correcta';
  static const String colItemCodigoPatronDistractor = 'codigo_patron_distractor';
  static const String colItemFigura = 'figura';

  // ─── Columnas: sesion ───────────────────────────────────────────────────────
  static const String colSesionId = 'id';
  static const String colSesionEstudianteId = 'estudiante_id';
  static const String colSesionFechaInicio = 'fecha_inicio';
  static const String colSesionFechaFin = 'fecha_fin';
  static const String colSesionTema = 'tema';

  // ─── Columnas: respuesta ────────────────────────────────────────────────────
  static const String colRespuestaId = 'id';
  static const String colRespuestaSesionId = 'sesion_id';
  static const String colRespuestaItemId = 'item_id';
  static const String colRespuestaDada = 'respuesta_dada';
  static const String colRespuestaCorrecto = 'correcto';
  static const String colRespuestaTimestamp = 'timestamp';

  // ─── Columnas: patron_error ─────────────────────────────────────────────────
  static const String colPatronId = 'id';
  static const String colPatronEstudianteId = 'estudiante_id';
  static const String colPatronCodigo = 'codigo_patron';
  static const String colPatronFrecuencia = 'frecuencia';
  static const String colPatronUltimaDeteccion = 'ultima_deteccion';

  // ─── Columnas: contenido_remediacion ────────────────────────────────────────
  static const String colRemediacionId = 'id';
  static const String colRemediacionCodigoPatron = 'codigo_patron';
  static const String colRemediacionContenido = 'contenido';
}
