// lib/presentation/widgets/retroalimentacion_widget.dart

import 'package:flutter/material.dart';

const _azulOscuro = Color(0xFF1F3864);

class RetroalimentacionWidget extends StatelessWidget {
  final bool correcto;
  final String respuestaCorrecta;
  final VoidCallback onContinuar;

  const RetroalimentacionWidget({
    super.key,
    required this.correcto,
    required this.respuestaCorrecta,
    required this.onContinuar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              correcto ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: correcto ? Colors.green : Colors.red,
              size: 88,
            ),
            const SizedBox(height: 16),
            Text(
              correcto ? '¡Correcto!' : 'Incorrecto',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: correcto ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
            if (!correcto) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  'La respuesta correcta es: $respuestaCorrecta',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onContinuar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _azulOscuro,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Continuar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
