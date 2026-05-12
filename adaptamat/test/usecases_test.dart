import 'package:flutter_test/flutter_test.dart';
import 'package:adaptamat/domain/entities/item.dart';
import 'package:adaptamat/domain/entities/sesion_respuesta_patron.dart';
import 'package:adaptamat/domain/usecases/motor_adaptativo.dart';
import 'package:adaptamat/domain/usecases/diagnostico_patrones.dart';
import 'package:adaptamat/domain/usecases/mapa_prerequisitos.dart';

void main() {
  // ─── MotorAdaptativo ────────────────────────────────────────────────────────

  group('MotorAdaptativo', () {
    test('probabilidadCorrecta: θ=b → 0.5', () {
      expect(MotorAdaptativo.probabilidadCorrecta(1.0, 1.0), closeTo(0.5, 0.0001));
    });

    test('probabilidadCorrecta: θ >> b → cercano a 1', () {
      expect(MotorAdaptativo.probabilidadCorrecta(5.0, 0.0), greaterThan(0.99));
    });

    test('actualizarTheta: correcto suma 0.3', () {
      expect(MotorAdaptativo.actualizarTheta(0.0, true), closeTo(0.3, 0.0001));
    });

    test('actualizarTheta: incorrecto resta 0.3', () {
      expect(MotorAdaptativo.actualizarTheta(0.0, false), closeTo(-0.3, 0.0001));
    });

    test('actualizarTheta: clamp superior en 3.0', () {
      expect(MotorAdaptativo.actualizarTheta(3.0, true), equals(3.0));
    });

    test('actualizarTheta: clamp inferior en -3.0', () {
      expect(MotorAdaptativo.actualizarTheta(-3.0, false), equals(-3.0));
    });

    test('evaluarDominio: θ=1.1 y 5 ítems → true', () {
      expect(
        MotorAdaptativo.evaluarDominio(theta: 1.1, itemsRespondidos: 5),
        isTrue,
      );
    });

    test('evaluarDominio: θ=0.9 → false aunque ítems suficientes', () {
      expect(
        MotorAdaptativo.evaluarDominio(theta: 0.9, itemsRespondidos: 5),
        isFalse,
      );
    });

    test('evaluarDominio: θ=1.5 pero solo 4 ítems → false', () {
      expect(
        MotorAdaptativo.evaluarDominio(theta: 1.5, itemsRespondidos: 4),
        isFalse,
      );
    });

    test('seleccionarSiguienteItem: elige el más cercano a theta', () {
      final banco = [
        _item(1, 'adicion', -1.0),
        _item(2, 'adicion', 0.1),
        _item(3, 'adicion', 2.0),
      ];
      final item = MotorAdaptativo.seleccionarSiguienteItem(
          0.0, 'adicion', banco, {});
      expect(item?.id, equals(2));
    });

    test('seleccionarSiguienteItem: omite ítems ya presentados', () {
      final banco = [
        _item(1, 'adicion', 0.1),
        _item(2, 'adicion', 0.2),
      ];
      final item = MotorAdaptativo.seleccionarSiguienteItem(
          0.0, 'adicion', banco, {1});
      expect(item?.id, equals(2));
    });

    test('seleccionarSiguienteItem: null si banco vacío para ese subtema', () {
      final banco = [_item(1, 'sustraccion', 0.0)];
      final item = MotorAdaptativo.seleccionarSiguienteItem(
          0.0, 'adicion', banco, {});
      expect(item, isNull);
    });

    test('seleccionarItemsDiagnostico: solo |b| ≤ 0.5, máx 3', () {
      final banco = [
        _item(1, 'conteo', -0.5),
        _item(2, 'conteo', 0.0),
        _item(3, 'conteo', 0.5),
        _item(4, 'conteo', 0.6),
        _item(5, 'conteo', -2.0),
      ];
      final resultado =
          MotorAdaptativo.seleccionarItemsDiagnostico('conteo', banco);
      expect(resultado.length, equals(3));
      expect(resultado.every((i) => i.dificultadB.abs() <= 0.5), isTrue);
    });
  });

  // ─── DiagnosticoPatrones ────────────────────────────────────────────────────

  group('DiagnosticoPatrones', () {
    test('respuesta correcta → null', () {
      expect(
        DiagnosticoPatrones.evaluar([], 'conteo', 2, 2, true),
        isNull,
      );
    });

    test('PE-06: ≥3 incorrectas consecutivas al final', () {
      final h = [
        _respuesta(false),
        _respuesta(false),
        _respuesta(false),
      ];
      expect(DiagnosticoPatrones.evaluar(h, 'conteo', 1, 2, false),
          equals('PE-06'));
    });

    test('PE-05: índice 0 elegido ≥2 veces en historial incorrecto', () {
      final h = [_respuesta(false, idx: 0), _respuesta(false, idx: 0)];
      expect(DiagnosticoPatrones.evaluar(h, 'conteo', 0, 2, false),
          equals('PE-05'));
    });

    test('PE-03: misma opción incorrecta ≥2 veces en historial', () {
      final h = [_respuesta(false, idx: 3), _respuesta(false, idx: 3)];
      expect(DiagnosticoPatrones.evaluar(h, 'adicion', 3, 1, false),
          equals('PE-03'));
    });

    test('PE-02: sobreestimación adyacente (índice correcto + 1)', () {
      final h = [_respuesta(false, idx: 2)];
      expect(DiagnosticoPatrones.evaluar(h, 'adicion', 3, 2, false),
          equals('PE-02'));
    });

    test('PE-01: subestimación adyacente (índice correcto - 1)', () {
      final h = [_respuesta(false, idx: 1)];
      expect(DiagnosticoPatrones.evaluar(h, 'adicion', 1, 2, false),
          equals('PE-01'));
    });

    test('PE-04: sobreestimación amplia con ≥2 errores previos', () {
      final h = [_respuesta(false, idx: 1), _respuesta(false, idx: 2)];
      expect(DiagnosticoPatrones.evaluar(h, 'sustraccion', 3, 0, false),
          equals('PE-04'));
    });

    test('sin patrón claro → null', () {
      expect(DiagnosticoPatrones.evaluar([], 'conteo', 1, 2, false), isNull);
    });
  });

  // ─── MapaPrerequisitos ──────────────────────────────────────────────────────

  group('MapaPrerequisitos', () {
    test('subtemaInicial numeros_y_operaciones → conteo', () {
      expect(MapaPrerequisitos.subtemaInicial('numeros_y_operaciones'),
          equals('conteo'));
    });

    test('subtemaInicial geometria → atributos_geometricos', () {
      expect(MapaPrerequisitos.subtemaInicial('geometria'),
          equals('atributos_geometricos'));
    });

    test('siguienteSubtema conteo → valor_posicional', () {
      expect(MapaPrerequisitos.siguienteSubtema('conteo'),
          equals('valor_posicional'));
    });

    test('siguienteSubtema sustraccion → null (es el último)', () {
      expect(MapaPrerequisitos.siguienteSubtema('sustraccion'), isNull);
    });

    test('siguienteSubtema clasificacion_geometrica → null', () {
      expect(
          MapaPrerequisitos.siguienteSubtema('clasificacion_geometrica'), isNull);
    });

    test('estaDisponible conteo sin prerrequisitos → true', () {
      expect(MapaPrerequisitos.estaDisponible('conteo', []), isTrue);
    });

    test('estaDisponible adicion sin dominar conteo → false', () {
      expect(MapaPrerequisitos.estaDisponible('adicion', []), isFalse);
    });

    test('estaDisponible adicion con conteo dominado → true', () {
      expect(MapaPrerequisitos.estaDisponible('adicion', ['conteo']), isTrue);
    });

    test('subtemasDeTema geometria devuelve los 3 subtemas', () {
      expect(MapaPrerequisitos.subtemasDeTema('geometria'), [
        'atributos_geometricos',
        'figuras_geometricas',
        'clasificacion_geometrica',
      ]);
    });
  });
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Item _item(int id, String subtema, double b) => Item(
      id: id,
      tema: 'test',
      subtema: subtema,
      dificultadB: b,
      enunciado: '',
      opciones: ['a', 'b', 'c', 'd'],
      respuestaCorrecta: 0,
    );

Respuesta _respuesta(bool correcto, {int idx = 1}) => Respuesta(
      sesionId: 1,
      itemId: 1,
      respuestaDada: idx,
      correcto: correcto,
      timestamp: DateTime.now(),
    );
