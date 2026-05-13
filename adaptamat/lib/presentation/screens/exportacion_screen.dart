// lib/presentation/screens/exportacion_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _azulOscuro = Color(0xFF1F3864);

class ExportacionScreen extends StatelessWidget {
  final String textoReporte;

  const ExportacionScreen({super.key, required this.textoReporte});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: _azulOscuro,
        foregroundColor: Colors.white,
        title: const Text('Exportar reporte'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Copiar al portapapeles',
            onPressed: () => _copiar(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: _azulOscuro.withValues(alpha: 0.08),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 18, color: _azulOscuro),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Presiona copiar para llevar el reporte al portapapeles.',
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    textoReporte,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copiar reporte'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _azulOscuro,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _copiar(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copiar(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: textoReporte));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte copiado al portapapeles'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
