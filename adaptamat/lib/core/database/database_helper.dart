// lib/core/database/database_helper.dart
// Capa de datos — Gestor de base de datos SQLite con singleton pattern

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:adaptamat/core/constants/database_constants.dart';

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
    final path = join(databasesPath, DatabaseConstants.databaseName);

    return openDatabase(
      path,
      version: 4,
      onConfigure: (db) async {
        // Mejora 1: Activar llaves foráneas para validar integridad referencial
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE ${DatabaseConstants.tableItem} ADD COLUMN ${DatabaseConstants.colItemFigura} TEXT',
      );
    }
    if (oldVersion < 3) {
      // Limpiar ítems para que se re-inserten desde JSON con valores de figura
      await db.delete(DatabaseConstants.tableItem);
    }
    if (oldVersion < 4) {
      // Recargar banco completo de 48 ítems desde JSON
      await db.delete(DatabaseConstants.tableItem);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Mejora 3: Uso de constantes para nombres de tablas y columnas

    // Tabla: estudiante
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableEstudiante} (
        ${DatabaseConstants.colEstudianteId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.colEstudianteNombre} TEXT NOT NULL,
        ${DatabaseConstants.colEstudianteGrado} TEXT NOT NULL,
        ${DatabaseConstants.colEstudianteThetaActual} REAL DEFAULT 0.0,
        ${DatabaseConstants.colEstudianteFechaRegistro} DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tabla: item
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableItem} (
        ${DatabaseConstants.colItemId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.colItemTema} TEXT NOT NULL,
        ${DatabaseConstants.colItemSubtema} TEXT NOT NULL,
        ${DatabaseConstants.colItemDificultadB} REAL NOT NULL,
        ${DatabaseConstants.colItemEnunciado} TEXT NOT NULL,
        ${DatabaseConstants.colItemOpciones} TEXT NOT NULL,
        ${DatabaseConstants.colItemRespuestaCorrecta} INTEGER NOT NULL,
        ${DatabaseConstants.colItemCodigoPatronDistractor} TEXT,
        ${DatabaseConstants.colItemFigura} TEXT
      )
    ''');

    // Tabla: sesion
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableSesion} (
        ${DatabaseConstants.colSesionId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.colSesionEstudianteId} INTEGER NOT NULL,
        ${DatabaseConstants.colSesionFechaInicio} DATETIME DEFAULT CURRENT_TIMESTAMP,
        ${DatabaseConstants.colSesionFechaFin} DATETIME,
        ${DatabaseConstants.colSesionTema} TEXT NOT NULL,
        FOREIGN KEY (${DatabaseConstants.colSesionEstudianteId}) REFERENCES ${DatabaseConstants.tableEstudiante}(${DatabaseConstants.colEstudianteId})
      )
    ''');

    // Tabla: respuesta
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableRespuesta} (
        ${DatabaseConstants.colRespuestaId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.colRespuestaSesionId} INTEGER NOT NULL,
        ${DatabaseConstants.colRespuestaItemId} INTEGER NOT NULL,
        ${DatabaseConstants.colRespuestaDada} INTEGER NOT NULL,
        ${DatabaseConstants.colRespuestaCorrecto} INTEGER NOT NULL,
        ${DatabaseConstants.colRespuestaTimestamp} DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (${DatabaseConstants.colRespuestaSesionId}) REFERENCES ${DatabaseConstants.tableSesion}(${DatabaseConstants.colSesionId}),
        FOREIGN KEY (${DatabaseConstants.colRespuestaItemId}) REFERENCES ${DatabaseConstants.tableItem}(${DatabaseConstants.colItemId})
      )
    ''');

    // Tabla: patron_error
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tablePatronError} (
        ${DatabaseConstants.colPatronId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.colPatronEstudianteId} INTEGER NOT NULL,
        ${DatabaseConstants.colPatronCodigo} TEXT NOT NULL,
        ${DatabaseConstants.colPatronFrecuencia} INTEGER DEFAULT 1,
        ${DatabaseConstants.colPatronUltimaDeteccion} DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (${DatabaseConstants.colPatronEstudianteId}) REFERENCES ${DatabaseConstants.tableEstudiante}(${DatabaseConstants.colEstudianteId})
      )
    ''');

    // Tabla: contenido_remediacion
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableContenidoRemediacion} (
        ${DatabaseConstants.colRemediacionId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.colRemediacionCodigoPatron} TEXT NOT NULL UNIQUE,
        ${DatabaseConstants.colRemediacionContenido} TEXT NOT NULL
      )
    ''');

    // Índices
    await db.execute(
      'CREATE INDEX idx_respuesta_sesion ON ${DatabaseConstants.tableRespuesta}(${DatabaseConstants.colRespuestaSesionId})',
    );
    await db.execute(
      'CREATE INDEX idx_patron_estudiante ON ${DatabaseConstants.tablePatronError}(${DatabaseConstants.colPatronEstudianteId})',
    );
    await db.execute(
      'CREATE INDEX idx_item_subtema ON ${DatabaseConstants.tableItem}(${DatabaseConstants.colItemSubtema})',
    );

    // Mejora 2: Manejo seguro de transacciones en inserciones iniciales con Batch
    final batch = db.batch();
    const remediaciones = [
      {
        DatabaseConstants.colRemediacionCodigoPatron: 'PE-01',
        DatabaseConstants.colRemediacionContenido:
            'Recuerda: Para contar, debes asignar un número a cada objeto en orden.',
      },
      {
        DatabaseConstants.colRemediacionCodigoPatron: 'PE-02',
        DatabaseConstants.colRemediacionContenido:
            'Recuerda: El valor posicional significa que la posición del dígito determina su valor.',
      },
      {
        DatabaseConstants.colRemediacionCodigoPatron: 'PE-03',
        DatabaseConstants.colRemediacionContenido:
            'Recuerda: Para sumar, agrupamos cantidades y contamos el total.',
      },
      {
        DatabaseConstants.colRemediacionCodigoPatron: 'PE-04',
        DatabaseConstants.colRemediacionContenido:
            'Recuerda: Para restar, quitamos una cantidad de la original.',
      },
      {
        DatabaseConstants.colRemediacionCodigoPatron: 'PE-05',
        DatabaseConstants.colRemediacionContenido:
            'Recuerda: Los atributos geométricos son propiedades como forma, tamaño y color.',
      },
      {
        DatabaseConstants.colRemediacionCodigoPatron: 'PE-06',
        DatabaseConstants.colRemediacionContenido:
            'Recuerda: Las figuras geométricas tienen características especiales (lados, ángulos).',
      },
    ];

    for (final r in remediaciones) {
      batch.insert(DatabaseConstants.tableContenidoRemediacion, r);
    }
    await batch.commit(noResult: true);
  }
}
