// lib/core/database/database_helper.dart
// Capa de datos — Gestor de base de datos SQLite con singleton pattern

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'adaptamat.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla: estudiante
    await db.execute('''
      CREATE TABLE estudiante (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        grado TEXT NOT NULL,
        theta_actual REAL DEFAULT 0.0,
        fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tabla: item
    await db.execute('''
      CREATE TABLE item (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tema TEXT NOT NULL,
        subtema TEXT NOT NULL,
        dificultad_b REAL NOT NULL,
        enunciado TEXT NOT NULL,
        opciones TEXT NOT NULL,
        respuesta_correcta INTEGER NOT NULL,
        codigo_patron_distractor TEXT
      )
    ''');

    // Tabla: sesion
    await db.execute('''
      CREATE TABLE sesion (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        estudiante_id INTEGER NOT NULL,
        fecha_inicio DATETIME DEFAULT CURRENT_TIMESTAMP,
        fecha_fin DATETIME,
        tema TEXT NOT NULL,
        FOREIGN KEY (estudiante_id) REFERENCES estudiante(id)
      )
    ''');

    // Tabla: respuesta
    await db.execute('''
      CREATE TABLE respuesta (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sesion_id INTEGER NOT NULL,
        item_id INTEGER NOT NULL,
        respuesta_dada INTEGER NOT NULL,
        correcto INTEGER NOT NULL,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (sesion_id) REFERENCES sesion(id),
        FOREIGN KEY (item_id) REFERENCES item(id)
      )
    ''');

    // Tabla: patron_error
    await db.execute('''
      CREATE TABLE patron_error (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        estudiante_id INTEGER NOT NULL,
        codigo_patron TEXT NOT NULL,
        frecuencia INTEGER DEFAULT 1,
        ultima_deteccion DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (estudiante_id) REFERENCES estudiante(id)
      )
    ''');

    // Tabla: contenido_remediacion
    await db.execute('''
      CREATE TABLE contenido_remediacion (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo_patron TEXT NOT NULL UNIQUE,
        contenido TEXT NOT NULL
      )
    ''');

    // Índices
    await db.execute(
      'CREATE INDEX idx_respuesta_sesion ON respuesta(sesion_id)'
    );
    await db.execute(
      'CREATE INDEX idx_patron_estudiante ON patron_error(estudiante_id)'
    );
    await db.execute(
      'CREATE INDEX idx_item_subtema ON item(subtema)'
    );

    // Inserción inicial de contenido de remediación (PE-01 al PE-06)
    await db.insert('contenido_remediacion', {
      'codigo_patron': 'PE-01',
      'contenido':
          'Recuerda: Para contar, debes asignar un número a cada objeto en orden.',
    });
    await db.insert('contenido_remediacion', {
      'codigo_patron': 'PE-02',
      'contenido':
          'Recuerda: El valor posicional significa que la posición del dígito determina su valor.',
    });
    await db.insert('contenido_remediacion', {
      'codigo_patron': 'PE-03',
      'contenido':
          'Recuerda: Para sumar, agrupamos cantidades y contamos el total.',
    });
    await db.insert('contenido_remediacion', {
      'codigo_patron': 'PE-04',
      'contenido':
          'Recuerda: Para restar, quitamos una cantidad de la original.',
    });
    await db.insert('contenido_remediacion', {
      'codigo_patron': 'PE-05',
      'contenido':
          'Recuerda: Los atributos geométricos son propiedades como forma, tamaño y color.',
    });
    await db.insert('contenido_remediacion', {
      'codigo_patron': 'PE-06',
      'contenido':
          'Recuerda: Las figuras geométricas tienen características especiales (lados, ángulos).',
    });
  }
}
