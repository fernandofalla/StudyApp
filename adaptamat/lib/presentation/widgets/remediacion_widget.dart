// lib/presentation/widgets/remediacion_widget.dart

import 'package:flutter/material.dart';

const _azulOscuro = Color(0xFF1F3864);

class RemediacionWidget extends StatelessWidget {
  final String contenido;
  final VoidCallback onContinuar;

  const RemediacionWidget({
    super.key,
    required this.contenido,
    required this.onContinuar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 72),
        const SizedBox(height: 8),
        const Text(
          'Recuerda:',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.amber.shade50,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.amber.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              contenido,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
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
            child: const Text('Entendido, continuar'),
          ),
        ),
      ],
    );
  }
}
