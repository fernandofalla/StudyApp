// lib/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:adaptamat/data/datasources/estudiante_datasource.dart';
import 'package:adaptamat/domain/entities/estudiante.dart';
import 'package:adaptamat/presentation/screens/sesion_screen.dart';

// Estudiante de prueba usado cuando la BD no está disponible (ej: web).
final _estudianteFallback = Estudiante(
  id: 1,
  nombre: 'Estudiante Demo',
  grado: '1ro Primaria',
  thetaActual: 0.0,
  fechaRegistro: DateTime(2025),
);

const _azulOscuro = Color(0xFF1F3864);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Estudiante? _estudiante;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarEstudiante();
  }

  Future<void> _cargarEstudiante() async {
    try {
      final todos = await EstudianteDatasource().obtenerTodos();
      setState(() {
        _estudiante = todos.isNotEmpty ? todos.first : _estudianteFallback;
        _cargando = false;
      });
    } catch (_) {
      // BD no disponible (ej: web) — usar estudiante de prueba en memoria.
      setState(() {
        _estudiante = _estudianteFallback;
        _cargando = false;
      });
    }
  }

  void _navegarASesion(String tema) {
    if (_estudiante == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SesionScreen(
          estudiante: _estudiante!,
          tema: tema,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: _azulOscuro,
        foregroundColor: Colors.white,
        title: const Text('AdaptaMat'),
        elevation: 0,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _estudiante == null
              ? const Center(child: Text('No se encontró un estudiante registrado.'))
              : _buildContenido(),
    );
  }

  Widget _buildContenido() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          // Saludo
          Card(
            color: _azulOscuro,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¡Hola!',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _estudiante!.nombre,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 36),
          const Text(
            '¿Qué quieres practicar hoy?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          // Botón Números y Operaciones
          _TemaButton(
            icono: Icons.calculate_rounded,
            titulo: 'Números y Operaciones',
            subtitulo: 'Conteo, suma, resta y más',
            onTap: () => _navegarASesion('numeros_y_operaciones'),
          ),
          const SizedBox(height: 16),
          // Botón Geometría
          _TemaButton(
            icono: Icons.category_rounded,
            titulo: 'Geometría',
            subtitulo: 'Figuras y atributos geométricos',
            onTap: () => _navegarASesion('geometria'),
          ),
        ],
      ),
    );
  }
}

class _TemaButton extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _TemaButton({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _azulOscuro,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: _azulOscuro, width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Row(
          children: [
            Icon(icono, size: 36, color: _azulOscuro),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _azulOscuro,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}
