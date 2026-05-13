// lib/presentation/widgets/figura_widget.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';

const _azulOscuro = Color(0xFF1F3864);

class FiguraWidget extends StatelessWidget {
  final String codigo;

  const FiguraWidget({super.key, required this.codigo});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _azulOscuro.withValues(alpha: 0.2)),
      ),
      child: CustomPaint(
        painter: _painterFor(codigo),
      ),
    );
  }

  CustomPainter _painterFor(String codigo) {
    switch (codigo) {
      case 'palitos_3':
        return _PalitosPainter(cantidad: 3);
      case 'circulos_azules_6':
        return _CirculosPainter(cantidad: 6);
      case 'manzanas_8':
        return _ManzanasPainter(cantidad: 8);
      case 'cuadrado':
        return _CuadradoPainter();
      case 'triangulo':
        return _TrianguloPainter();
      case 'comparar_formas':
        return _CompararFormasPainter();
      case 'cubo':
        return _CuboPainter();
      case 'grupos_figuras':
        return _GruposFigurasPainter();
      default:
        return _VacioPainter();
    }
  }
}

// ─── Palitos ────────────────────────────────────────────────────────────────

class _PalitosPainter extends CustomPainter {
  final int cantidad;
  _PalitosPainter({required this.cantidad});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.shade600
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final gap = size.width / (cantidad + 1);
    final top = size.height * 0.2;
    final bottom = size.height * 0.8;

    for (int i = 0; i < cantidad; i++) {
      final x = gap * (i + 1);
      canvas.drawLine(Offset(x, top), Offset(x, bottom), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── Círculos azules ────────────────────────────────────────────────────────

class _CirculosPainter extends CustomPainter {
  final int cantidad;
  _CirculosPainter({required this.cantidad});

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = Colors.blue.shade400;
    final stroke = Paint()
      ..color = Colors.blue.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const cols = 3;
    final rows = (cantidad / cols).ceil();
    final r = math.min(size.width / (cols * 2 + 1), size.height / (rows * 2 + 1)) * 0.8;
    final startX = (size.width - (cols * 2 - 1) * r) / 2 + r;
    final startY = (size.height - (rows * 2 - 1) * r) / 2 + r;

    for (int i = 0; i < cantidad; i++) {
      final col = i % cols;
      final row = i ~/ cols;
      final center = Offset(startX + col * 2 * r, startY + row * 2 * r);
      canvas.drawCircle(center, r, fill);
      canvas.drawCircle(center, r, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── Manzanas ───────────────────────────────────────────────────────────────

class _ManzanasPainter extends CustomPainter {
  final int cantidad;
  _ManzanasPainter({required this.cantidad});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.red.shade400;
    final stemPaint = Paint()
      ..color = Colors.brown.shade500
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const cols = 4;
    final rows = (cantidad / cols).ceil();
    final cellW = size.width / cols;
    final cellH = size.height / rows;
    final r = math.min(cellW, cellH) * 0.35;

    for (int i = 0; i < cantidad; i++) {
      final col = i % cols;
      final row = i ~/ cols;
      final cx = cellW * col + cellW / 2;
      final cy = cellH * row + cellH / 2 + r * 0.3;

      // body
      canvas.drawCircle(Offset(cx, cy), r, bodyPaint);
      // stem
      canvas.drawLine(
        Offset(cx, cy - r),
        Offset(cx + r * 0.3, cy - r - r * 0.4),
        stemPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── Cuadrado ───────────────────────────────────────────────────────────────

class _CuadradoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height) * 0.6;
    final left = (size.width - side) / 2;
    final top = (size.height - side) / 2;
    final rect = Rect.fromLTWH(left, top, side, side);

    canvas.drawRect(rect, Paint()..color = Colors.blue.shade200);
    canvas.drawRect(
      rect,
      Paint()
        ..color = _azulOscuro
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // vertex dots
    final dotPaint = Paint()..color = _azulOscuro;
    for (final corner in [
      Offset(left, top),
      Offset(left + side, top),
      Offset(left, top + side),
      Offset(left + side, top + side),
    ]) {
      canvas.drawCircle(corner, 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── Triángulo ──────────────────────────────────────────────────────────────

class _TrianguloPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final h = size.height * 0.7;
    final top = (size.height - h) / 2;
    final base = size.width * 0.6;

    final path = Path()
      ..moveTo(cx, top)
      ..lineTo(cx + base / 2, top + h)
      ..lineTo(cx - base / 2, top + h)
      ..close();

    canvas.drawPath(path, Paint()..color = Colors.green.shade200);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.green.shade800
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // vertex dots
    final dotPaint = Paint()..color = Colors.green.shade800;
    for (final pt in [
      Offset(cx, top),
      Offset(cx + base / 2, top + h),
      Offset(cx - base / 2, top + h),
    ]) {
      canvas.drawCircle(pt, 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── Comparar formas (triángulo, cuadrado, pentágono) ──────────────────────

class _CompararFormasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / 3;
    final cy = size.height / 2;
    final r = math.min(cellW, size.height) * 0.35;

    final fills = [Colors.green.shade200, Colors.blue.shade200, Colors.orange.shade200];
    final strokes = [Colors.green.shade800, Colors.blue.shade800, Colors.orange.shade800];
    final sides = [3, 4, 5];

    for (int i = 0; i < 3; i++) {
      final cx = cellW * i + cellW / 2;
      _drawPolygon(canvas, Offset(cx, cy), r, sides[i], fills[i], strokes[i]);

      // label
      final tp = TextPainter(
        text: TextSpan(
          text: '${sides[i]} lados',
          style: TextStyle(fontSize: 10, color: strokes[i], fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, cy + r + 4));
    }
  }

  void _drawPolygon(Canvas canvas, Offset center, double r, int n,
      Color fill, Color stroke) {
    final path = Path();
    for (int i = 0; i < n; i++) {
      final angle = (2 * math.pi * i / n) - math.pi / 2;
      final pt = Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(path, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = 2.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── Cubo (isométrico simplificado) ─────────────────────────────────────────

class _CuboPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height) * 0.45;
    final cx = size.width / 2;
    final cy = size.height / 2;

    // top face
    final top = Path()
      ..moveTo(cx, cy - s * 0.6)
      ..lineTo(cx + s * 0.8, cy - s * 0.2)
      ..lineTo(cx, cy + s * 0.2)
      ..lineTo(cx - s * 0.8, cy - s * 0.2)
      ..close();

    // right face
    final right = Path()
      ..moveTo(cx + s * 0.8, cy - s * 0.2)
      ..lineTo(cx + s * 0.8, cy + s * 0.6)
      ..lineTo(cx, cy + s)
      ..lineTo(cx, cy + s * 0.2)
      ..close();

    // left face
    final left = Path()
      ..moveTo(cx - s * 0.8, cy - s * 0.2)
      ..lineTo(cx, cy + s * 0.2)
      ..lineTo(cx, cy + s)
      ..lineTo(cx - s * 0.8, cy + s * 0.6)
      ..close();

    canvas.drawPath(top, Paint()..color = Colors.blue.shade300);
    canvas.drawPath(right, Paint()..color = Colors.blue.shade500);
    canvas.drawPath(left, Paint()..color = Colors.blue.shade200);

    final edge = Paint()
      ..color = _azulOscuro
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(top, edge);
    canvas.drawPath(right, edge);
    canvas.drawPath(left, edge);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── Grupos de figuras (con vs sin ángulos) ──────────────────────────────────

class _GruposFigurasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final halfW = size.width / 2;
    final cy = size.height / 2;

    // Group A — sin ángulos: círculo + elipse (label "A")
    _drawCircle(canvas, Offset(halfW * 0.35, cy - 20), 22, Colors.red.shade200, Colors.red.shade700);
    _drawCircle(canvas, Offset(halfW * 0.65, cy + 10), 18, Colors.red.shade200, Colors.red.shade700);
    _drawGroupLabel(canvas, Offset(halfW * 0.5, size.height * 0.85), 'sin ángulos', Colors.red.shade700);

    // divider
    final divPaint = Paint()..color = Colors.grey.shade400..strokeWidth = 1.5;
    canvas.drawLine(Offset(halfW, size.height * 0.1), Offset(halfW, size.height * 0.75), divPaint);

    // Group B — con ángulos: triángulo + cuadrado
    _drawTriangle(canvas, Offset(halfW + halfW * 0.3, cy - 20), 24, Colors.blue.shade200, Colors.blue.shade800);
    _drawSquare(canvas, Offset(halfW + halfW * 0.65, cy + 10), 22, Colors.blue.shade200, Colors.blue.shade800);
    _drawGroupLabel(canvas, Offset(halfW + halfW * 0.5, size.height * 0.85), 'con ángulos', Colors.blue.shade800);
  }

  void _drawCircle(Canvas canvas, Offset c, double r, Color fill, Color stroke) {
    canvas.drawCircle(c, r, Paint()..color = fill);
    canvas.drawCircle(c, r, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  void _drawTriangle(Canvas canvas, Offset c, double r, Color fill, Color stroke) {
    final path = Path();
    for (int i = 0; i < 3; i++) {
      final a = (2 * math.pi * i / 3) - math.pi / 2;
      final pt = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(path, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  void _drawSquare(Canvas canvas, Offset c, double half, Color fill, Color stroke) {
    final rect = Rect.fromCenter(center: c, width: half * 2, height: half * 2);
    canvas.drawRect(rect, Paint()..color = fill);
    canvas.drawRect(rect, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  void _drawGroupLabel(Canvas canvas, Offset pos, String text, Color color) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── Vacío (fallback) ────────────────────────────────────────────────────────

class _VacioPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {}
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
