// lib/data/datasources/item_sesion_datasource.dart
// Capa de datos — Acceso a datos de ítems, sesiones y respuestas en SQLite

import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:adaptamat/core/constants/database_constants.dart';
import 'package:adaptamat/core/database/database_helper.dart';
import 'package:adaptamat/domain/entities/item.dart';
import 'package:adaptamat/domain/entities/sesion_respuesta_patron.dart';

class ItemDatasource {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> insertarLote(List<Item> items) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (final item in items) {
      batch.insert(DatabaseConstants.tableItem, {
        DatabaseConstants.colItemTema: item.tema,
        DatabaseConstants.colItemSubtema: item.subtema,
        DatabaseConstants.colItemDificultadB: item.dificultadB,
        DatabaseConstants.colItemEnunciado: item.enunciado,
        DatabaseConstants.colItemOpciones: jsonEncode(item.opciones),
        DatabaseConstants.colItemRespuestaCorrecta: item.respuestaCorrecta,
        DatabaseConstants.colItemCodigoPatronDistractor: item.codigoPatronDistractor,
        DatabaseConstants.colItemFigura: item.figura,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<Item>> obtenerPorSubtema(String subtema) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableItem,
      where: '${DatabaseConstants.colItemSubtema} = ?',
      whereArgs: [subtema],
    );

    return List<Item>.from(maps.map((map) {
      return Item(
        id: map[DatabaseConstants.colItemId],
        tema: map[DatabaseConstants.colItemTema],
        subtema: map[DatabaseConstants.colItemSubtema],
        dificultadB: map[DatabaseConstants.colItemDificultadB],
        enunciado: map[DatabaseConstants.colItemEnunciado],
        opciones: List<String>.from(jsonDecode(map[DatabaseConstants.colItemOpciones])),
        respuestaCorrecta: map[DatabaseConstants.colItemRespuestaCorrecta],
        codigoPatronDistractor: map[DatabaseConstants.colItemCodigoPatronDistractor],
        figura: map[DatabaseConstants.colItemFigura] as String?,
      );
    }));
  }

  Future<List<Item>> obtenerTodos() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(DatabaseConstants.tableItem);

    return List<Item>.from(maps.map((map) {
      return Item(
        id: map[DatabaseConstants.colItemId],
        tema: map[DatabaseConstants.colItemTema],
        subtema: map[DatabaseConstants.colItemSubtema],
        dificultadB: map[DatabaseConstants.colItemDificultadB],
        enunciado: map[DatabaseConstants.colItemEnunciado],
        opciones: List<String>.from(jsonDecode(map[DatabaseConstants.colItemOpciones])),
        respuestaCorrecta: map[DatabaseConstants.colItemRespuestaCorrecta],
        codigoPatronDistractor: map[DatabaseConstants.colItemCodigoPatronDistractor],
        figura: map[DatabaseConstants.colItemFigura] as String?,
      );
    }));
  }

  Future<bool> bancoVacio() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConstants.tableItem}',
    );
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count == 0;
  }
}

class SesionDatasource {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> iniciarSesion(Sesion sesion) async {
    final db = await _dbHelper.database;
    return await db.insert(DatabaseConstants.tableSesion, {
      DatabaseConstants.colSesionEstudianteId: sesion.estudianteId,
      DatabaseConstants.colSesionFechaInicio: sesion.fechaInicio.toIso8601String(),
      DatabaseConstants.colSesionTema: sesion.tema,
    });
  }

  Future<void> cerrarSesion(int sesionId) async {
    final db = await _dbHelper.database;
    await db.update(
      DatabaseConstants.tableSesion,
      {DatabaseConstants.colSesionFechaFin: DateTime.now().toIso8601String()},
      where: '${DatabaseConstants.colSesionId} = ?',
      whereArgs: [sesionId],
    );
  }

  Future<int> registrarRespuesta(Respuesta respuesta) async {
    final db = await _dbHelper.database;
    return await db.insert(DatabaseConstants.tableRespuesta, {
      DatabaseConstants.colRespuestaSesionId: respuesta.sesionId,
      DatabaseConstants.colRespuestaItemId: respuesta.itemId,
      DatabaseConstants.colRespuestaDada: respuesta.respuestaDada,
      DatabaseConstants.colRespuestaCorrecto: respuesta.correcto ? 1 : 0,
      DatabaseConstants.colRespuestaTimestamp: respuesta.timestamp.toIso8601String(),
    });
  }

  Future<List<Respuesta>> obtenerRespuestasDeSesion(int sesionId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableRespuesta,
      where: '${DatabaseConstants.colRespuestaSesionId} = ?',
      whereArgs: [sesionId],
    );

    return List<Respuesta>.from(maps.map((map) {
      return Respuesta(
        id: map[DatabaseConstants.colRespuestaId],
        sesionId: map[DatabaseConstants.colRespuestaSesionId],
        itemId: map[DatabaseConstants.colRespuestaItemId],
        respuestaDada: map[DatabaseConstants.colRespuestaDada],
        correcto: map[DatabaseConstants.colRespuestaCorrecto] == 1,
        timestamp: DateTime.parse(map[DatabaseConstants.colRespuestaTimestamp]),
      );
    }));
  }

  Future<void> registrarOActualizarPatron(
      int estudianteId, String codigoPatron) async {
    final db = await _dbHelper.database;

    final existentes = await db.query(
      DatabaseConstants.tablePatronError,
      where:
          '${DatabaseConstants.colPatronEstudianteId} = ? AND ${DatabaseConstants.colPatronCodigo} = ?',
      whereArgs: [estudianteId, codigoPatron],
    );

    if (existentes.isEmpty) {
      await db.insert(DatabaseConstants.tablePatronError, {
        DatabaseConstants.colPatronEstudianteId: estudianteId,
        DatabaseConstants.colPatronCodigo: codigoPatron,
        DatabaseConstants.colPatronFrecuencia: 1,
        DatabaseConstants.colPatronUltimaDeteccion: DateTime.now().toIso8601String(),
      });
    } else {
      final frecuenciaActual =
          existentes.first[DatabaseConstants.colPatronFrecuencia] as int;
      await db.update(
        DatabaseConstants.tablePatronError,
        {
          DatabaseConstants.colPatronFrecuencia: frecuenciaActual + 1,
          DatabaseConstants.colPatronUltimaDeteccion: DateTime.now().toIso8601String(),
        },
        where:
            '${DatabaseConstants.colPatronEstudianteId} = ? AND ${DatabaseConstants.colPatronCodigo} = ?',
        whereArgs: [estudianteId, codigoPatron],
      );
    }
  }

  Future<String?> obtenerContenidoRemediacion(String codigoPatron) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      DatabaseConstants.tableContenidoRemediacion,
      where: '${DatabaseConstants.colRemediacionCodigoPatron} = ?',
      whereArgs: [codigoPatron],
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first[DatabaseConstants.colRemediacionContenido] as String?;
  }

  Future<List<PatronError>> obtenerPatronesDeEstudiante(int estudianteId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tablePatronError,
      where: '${DatabaseConstants.colPatronEstudianteId} = ?',
      whereArgs: [estudianteId],
    );

    return List<PatronError>.from(maps.map((map) {
      return PatronError(
        id: map[DatabaseConstants.colPatronId],
        estudianteId: map[DatabaseConstants.colPatronEstudianteId],
        codigoPatron: map[DatabaseConstants.colPatronCodigo],
        frecuencia: map[DatabaseConstants.colPatronFrecuencia],
        ultimaDeteccion: DateTime.parse(map[DatabaseConstants.colPatronUltimaDeteccion]),
      );
    }));
  }
}
