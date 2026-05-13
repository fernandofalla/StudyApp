// lib/presentation/screens/prueba_dashboard_screen.dart
// Pantalla TEMPORAL para verificar TarjetaEstudianteWidget y BarraPatronWidget.
// ELIMINAR antes de entrega final.

import 'package:flutter/material.dart';
import 'package:adaptamat/presentation/widgets/barra_patron_widget.dart';
import 'package:adaptamat/presentation/widgets/tarjeta_estudiante_widget.dart';

const _azulOscuro = Color(0xFF1F3864);

class PruebaDashboardScreen extends StatelessWidget {
  const PruebaDashboardScreen({super.key});

  static final _estudiantes = [
    {
      'id': 1,
      'nombre': 'Ana López',
      'theta_actual': -0.8,
      'tema': 'numeros_y_operaciones',
      'total_sesiones': 2,
    },
    {
      'id': 2,
      'nombre': 'Carlos Méndez',
      'theta_actual': 0.4,
      'tema': 'geometria',
      'total_sesiones': 5,
    },
    {
      'id': 3,
      'nombre': 'María Pérez',
      'theta_actual': 1.3,
      'tema': 'numeros_y_operaciones',
      'total_sesiones': 8,
    },
  ];

  static final _patrones = [
    {'codigo': 'PE-03', 'frecuencia': 8, 'afectados': 3},
    {'codigo': 'PE-01', 'frecuencia': 5, 'afectados': 2},
    {'codigo': 'PE-05', 'frecuencia': 2, 'afectados': 1},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: _azulOscuro,
        foregroundColor: Colors.white,
        title: const Text('Prueba widgets dashboard'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── TarjetaEstudianteWidget ─────────────────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'TarjetaEstudianteWidget',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
            Container(
              color: Colors.white,
              child: Column(
                children: _estudiantes.map((e) {
                  return TarjetaEstudianteWidget(
                    datos: e,
                    onSeleccionar: (id) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Seleccionado: ${e['nombre']} (id=$id)'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),

            // ── BarraPatronWidget ───────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'BarraPatronWidget',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: _patrones.map((p) {
                  return BarraPatronWidget(
                    codigoPatron: p['codigo'] as String,
                    frecuenciaTotal: p['frecuencia'] as int,
                    estudiantesAfectados: p['afectados'] as int,
                    maxFrecuencia: 8,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
