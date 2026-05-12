// lib/presentation/screens/sesion_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:adaptamat/domain/entities/estudiante.dart';
import 'package:adaptamat/presentation/blocs/sesion_bloc.dart';
import 'package:adaptamat/presentation/widgets/item_widget.dart';
import 'package:adaptamat/presentation/widgets/retroalimentacion_widget.dart';
import 'package:adaptamat/presentation/widgets/remediacion_widget.dart';

const _azulOscuro = Color(0xFF1F3864);

class SesionScreen extends StatelessWidget {
  final Estudiante estudiante;
  final String tema;

  const SesionScreen({
    super.key,
    required this.estudiante,
    required this.tema,
  });

  String get _tituloTema {
    switch (tema) {
      case 'numeros_y_operaciones':
        return 'Números y Operaciones';
      case 'geometria':
        return 'Geometría';
      default:
        return tema;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SesionBloc()
        ..add(IniciarSesion(
          estudianteId: estudiante.id!,
          thetaInicial: estudiante.thetaActual,
          tema: tema,
        )),
      child: _SesionView(tituloTema: _tituloTema),
    );
  }
}

class _SesionView extends StatelessWidget {
  final String tituloTema;

  const _SesionView({required this.tituloTema});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SesionBloc, SesionState>(
      // Escucha SesionSubtemaDominado para mostrar el AlertDialog de logro
      listenWhen: (_, current) => current is SesionSubtemaDominado,
      listener: (context, state) {
        if (state is SesionSubtemaDominado) {
          _mostrarDialogoLogro(context, state);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            backgroundColor: _azulOscuro,
            foregroundColor: Colors.white,
            title: Text(tituloTema),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                context.read<SesionBloc>().add(const FinalizarSesion());
                Navigator.pop(context);
              },
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _buildCuerpo(context, state),
          ),
        );
      },
    );
  }

  Widget _buildCuerpo(BuildContext context, SesionState state) {
    if (state is SesionCargando || state is SesionInicial) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator(color: _azulOscuro)),
      );
    }

    if (state is SesionConItem) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InfoTheta(theta: state.theta, itemsRespondidos: state.itemsRespondidos),
          const SizedBox(height: 16),
          ItemWidget(
            item: state.item,
            onRespuesta: (indice) =>
                context.read<SesionBloc>().add(ResponderItem(indice)),
          ),
        ],
      );
    }

    if (state is SesionRetroalimentacion) {
      return RetroalimentacionWidget(
        correcto: state.correcto,
        respuestaCorrecta: state.correcto ? '' : 'opción ${state.respuestaCorrecta + 1}',
        onContinuar: () {},
      );
    }

    if (state is SesionRemediacion) {
      return RemediacionWidget(
        contenido: state.contenido ?? 'Repasa el concepto antes de continuar.',
        onContinuar: () =>
            context.read<SesionBloc>().add(const ContinuarTrasRemediacion()),
      );
    }

    if (state is SesionFinalizada) {
      return _PantallaFinalizada(
        thetaFinal: state.thetaFinal,
        itemsRespondidos: state.itemsRespondidos,
        onSalir: () => Navigator.pop(context),
      );
    }

    if (state is SesionError) {
      return _PantallaError(
        mensaje: state.mensaje,
        onReintentar: () => Navigator.pop(context),
      );
    }

    // SesionSubtemaDominado lo maneja el listener (AlertDialog)
    return const SizedBox.shrink();
  }

  void _mostrarDialogoLogro(BuildContext context, SesionSubtemaDominado state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 32),
            SizedBox(width: 8),
            Text('¡Subtema dominado!'),
          ],
        ),
        content: Text(
          state.siguienteSubtema != null
              ? 'Completaste "${state.subtema}".\nAhora practicarás "${state.siguienteSubtema}".'
              : '¡Completaste todos los subtemas de este tema!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // cierra el dialog
              if (state.siguienteSubtema == null) {
                context.read<SesionBloc>().add(const FinalizarSesion());
              }
            },
            child: Text(
              state.siguienteSubtema != null ? 'Continuar' : 'Finalizar',
              style: const TextStyle(color: _azulOscuro),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _InfoTheta extends StatelessWidget {
  final double theta;
  final int itemsRespondidos;

  const _InfoTheta({required this.theta, required this.itemsRespondidos});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Chip(label: 'Nivel: ${theta.toStringAsFixed(1)}'),
        const SizedBox(width: 8),
        _Chip(label: 'Respondidos: $itemsRespondidos'),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _azulOscuro.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _azulOscuro.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, color: _azulOscuro),
      ),
    );
  }
}

class _PantallaFinalizada extends StatelessWidget {
  final double thetaFinal;
  final int itemsRespondidos;
  final VoidCallback onSalir;

  const _PantallaFinalizada({
    required this.thetaFinal,
    required this.itemsRespondidos,
    required this.onSalir,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const Icon(Icons.school_rounded, color: _azulOscuro, size: 80),
            const SizedBox(height: 16),
            const Text(
              '¡Sesión completada!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            _FilaResumen(etiqueta: 'Nivel final (θ)', valor: thetaFinal.toStringAsFixed(2)),
            _FilaResumen(etiqueta: 'Ítems respondidos', valor: '$itemsRespondidos'),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onSalir,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _azulOscuro,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Volver al inicio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaResumen extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _FilaResumen({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta, style: const TextStyle(fontSize: 16, color: Colors.black54)),
          Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _PantallaError extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;

  const _PantallaError({required this.mensaje, required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(mensaje, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onReintentar,
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }
}
