// lib/presentation/screens/prueba_widgets_screen.dart
// Pantalla temporal para verificar visualmente los widgets con flujo real.
// ELIMINAR antes de la entrega final.

import 'package:flutter/material.dart';
import 'package:adaptamat/domain/entities/item.dart';
import 'package:adaptamat/presentation/widgets/item_widget.dart';
import 'package:adaptamat/presentation/widgets/retroalimentacion_widget.dart';
import 'package:adaptamat/presentation/widgets/remediacion_widget.dart';

// Fases del flujo de prueba
enum _Fase { pregunta, retroalimentacion, remediacion, reinicio }

class PruebaWidgetsScreen extends StatefulWidget {
  const PruebaWidgetsScreen({super.key});

  @override
  State<PruebaWidgetsScreen> createState() => _PruebaWidgetsScreenState();
}

class _PruebaWidgetsScreenState extends State<PruebaWidgetsScreen> {
  _Fase _fase = _Fase.pregunta;
  bool _correcto = false;
  int _intentos = 0;

  static final _item = Item(
    id: 1,
    tema: 'numeros_y_operaciones',
    subtema: 'adicion',
    dificultadB: 0.0,
    enunciado: '¿Cuánto es 3 + 4?',
    opciones: ['5', '6', '7', '8'],
    respuestaCorrecta: 2, // '7' es la correcta
  );

  static const _remediacion =
      'Para sumar, empieza desde el número más grande (4) '
      'y cuenta 3 más: 5, 6, 7. ¡El resultado es 7!';

  String get _tituloAppBar {
    switch (_fase) {
      case _Fase.pregunta:
        return 'Pregunta (intento ${_intentos + 1})';
      case _Fase.retroalimentacion:
        return _correcto ? 'Retroalimentación — Correcto' : 'Retroalimentación — Incorrecto';
      case _Fase.remediacion:
        return 'Remediación';
      case _Fase.reinicio:
        return 'Sesión completada';
    }
  }

  void _responder(int indice) {
    setState(() {
      _correcto = indice == _item.respuestaCorrecta;
      _intentos++;
      _fase = _Fase.retroalimentacion;
    });
  }

  void _continuar() {
    setState(() {
      // Si fue incorrecto y es el primer intento → mostrar remediación
      if (!_correcto && _intentos == 1) {
        _fase = _Fase.remediacion;
      } else {
        _fase = _Fase.reinicio;
      }
    });
  }

  void _reiniciar() {
    setState(() {
      _fase = _Fase.pregunta;
      _intentos = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F3864),
        foregroundColor: Colors.white,
        title: Text(_tituloAppBar),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _buildContenido(),
      ),
    );
  }

  Widget _buildContenido() {
    switch (_fase) {
      case _Fase.pregunta:
        return ItemWidget(item: _item, onRespuesta: _responder);

      case _Fase.retroalimentacion:
        return RetroalimentacionWidget(
          correcto: _correcto,
          respuestaCorrecta: _item.opciones[_item.respuestaCorrecta],
          onContinuar: _continuar,
        );

      case _Fase.remediacion:
        return RemediacionWidget(
          contenido: _remediacion,
          onContinuar: _reiniciar,
        );

      case _Fase.reinicio:
        return _ResumenFinal(
          correcto: _correcto,
          intentos: _intentos,
          onReiniciar: _reiniciar,
        );
    }
  }
}

class _ResumenFinal extends StatelessWidget {
  final bool correcto;
  final int intentos;
  final VoidCallback onReiniciar;

  const _ResumenFinal({
    required this.correcto,
    required this.intentos,
    required this.onReiniciar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const Icon(Icons.stars_rounded, color: Colors.amber, size: 72),
            const SizedBox(height: 16),
            Text(
              correcto ? '¡Excelente trabajo!' : 'Sigue practicando',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Respondiste en $intentos intento${intentos > 1 ? 's' : ''}.',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onReiniciar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F3864),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Volver a intentar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
