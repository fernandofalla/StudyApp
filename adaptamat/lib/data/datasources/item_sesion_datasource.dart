// lib/data/datasources/item_sesion_datasource.dart
// Capa de datos — Acceso a datos de ítems, sesiones y respuestas en SQLite

import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:adaptamat/core/database/database_helper.dart';
import 'package:adaptamat/domain/entities/item.dart';
import 'package:adaptamat/domain/entities/sesion_respuesta_patron.dart';

class ItemDatasource {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> insertarLote(List<Item> items) async {
    final db = await _dbHelper.database;
    for (final item in items) {
      await db.insert('item', {
        'tema': item.tema,
        'subtema': item.subtema,
        'dificultad_b': item.dificultadB,
        'enunciado': item.enunciado,
        'opciones': jsonEncode(item.opciones),
        'respuesta_correcta': item.respuestaCorrecta,
        'codigo_patron_distractor': item.codigoPatronDistractor,
        'figura': item.figura,
      });
    }
  }

  Future<List<Item>> obtenerPorSubtema(String subtema) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'item',
      where: 'subtema = ?',
      whereArgs: [subtema],
    );

    return List<Item>.from(maps.map((map) {
      return Item(
        id: map['id'],
        tema: map['tema'],
        subtema: map['subtema'],
        dificultadB: map['dificultad_b'],
        enunciado: map['enunciado'],
        opciones: List<String>.from(jsonDecode(map['opciones'])),
        respuestaCorrecta: map['respuesta_correcta'],
        codigoPatronDistractor: map['codigo_patron_distractor'],
        figura: map['figura'] as String?,
      );
    }));
  }

  Future<List<Item>> obtenerTodos() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('item');

    return List<Item>.from(maps.map((map) {
      return Item(
        id: map['id'],
        tema: map['tema'],
        subtema: map['subtema'],
        dificultadB: map['dificultad_b'],
        enunciado: map['enunciado'],
        opciones: List<String>.from(jsonDecode(map['opciones'])),
        respuestaCorrecta: map['respuesta_correcta'],
        codigoPatronDistractor: map['codigo_patron_distractor'],
        figura: map['figura'] as String?,
      );
    }));
  }

  Future<bool> bancoVacio() async {
    final db = await _dbHelper.database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM item');
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count == 0;
  }
}

class SesionDatasource {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> iniciarSesion(Sesion sesion) async {
    final db = await _dbHelper.database;
    return await db.insert('sesion', {
      'estudiante_id': sesion.estudianteId,
      'fecha_inicio': sesion.fechaInicio.toIso8601String(),
      'tema': sesion.tema,
    });
  }

  Future<void> cerrarSesion(int sesionId) async {
    final db = await _dbHelper.database;
    await db.update(
      'sesion',
      {'fecha_fin': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [sesionId],
    );
  }

  Future<int> registrarRespuesta(Respuesta respuesta) async {
    final db = await _dbHelper.database;
    return await db.insert('respuesta', {
      'sesion_id': respuesta.sesionId,
      'item_id': respuesta.itemId,
      'respuesta_dada': respuesta.respuestaDada,
      'correcto': respuesta.correcto ? 1 : 0,
      'timestamp': respuesta.timestamp.toIso8601String(),
    });
  }

  Future<List<Respuesta>> obtenerRespuestasDeSesion(int sesionId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'respuesta',
      where: 'sesion_id = ?',
      whereArgs: [sesionId],
    );

    return List<Respuesta>.from(maps.map((map) {
      return Respuesta(
        id: map['id'],
        sesionId: map['sesion_id'],
        itemId: map['item_id'],
        respuestaDada: map['respuesta_dada'],
        correcto: map['correcto'] == 1,
        timestamp: DateTime.parse(map['timestamp']),
      );
    }));
  }

  Future<void> registrarOActualizarPatron(
      int estudianteId, String codigoPatron) async {
    final db = await _dbHelper.database;

    final existentes = await db.query(
      'patron_error',
      where: 'estudiante_id = ? AND codigo_patron = ?',
      whereArgs: [estudianteId, codigoPatron],
    );

    if (existentes.isEmpty) {
      await db.insert('patron_error', {
        'estudiante_id': estudianteId,
        'codigo_patron': codigoPatron,
        'frecuencia': 1,
        'ultima_deteccion': DateTime.now().toIso8601String(),
      });
    } else {
      final frecuenciaActual = existentes.first['frecuencia'] as int;
      await db.update(
        'patron_error',
        {
          'frecuencia': frecuenciaActual + 1,
          'ultima_deteccion': DateTime.now().toIso8601String(),
        },
        where: 'estudiante_id = ? AND codigo_patron = ?',
        whereArgs: [estudianteId, codigoPatron],
      );
    }
  }

  Future<String?> obtenerContenidoRemediacion(String codigoPatron) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'contenido_remediacion',
      where: 'codigo_patron = ?',
      whereArgs: [codigoPatron],
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first['contenido'] as String?;
  }

  Future<List<PatronError>> obtenerPatronesDeEstudiante(int estudianteId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patron_error',
      where: 'estudiante_id = ?',
      whereArgs: [estudianteId],
    );

    return List<PatronError>.from(maps.map((map) {
      return PatronError(
        id: map['id'],
        estudianteId: map['estudiante_id'],
        codigoPatron: map['codigo_patron'],
        frecuencia: map['frecuencia'],
        ultimaDeteccion: DateTime.parse(map['ultima_deteccion']),
      );
    }));
  }
}
