// lib/presentation/widgets/item_widget.dart

import 'package:flutter/material.dart';
import 'package:adaptamat/domain/entities/item.dart';

const _azulOscuro = Color(0xFF1F3864);

class ItemWidget extends StatefulWidget {
  final Item item;
  final void Function(int indice) onRespuesta;

  const ItemWidget({
    super.key,
    required this.item,
    required this.onRespuesta,
  });

  @override
  State<ItemWidget> createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  int? _seleccionado;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _azulOscuro, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.item.enunciado,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(widget.item.opciones.length, (i) {
              return _OpcionButton(
                texto: widget.item.opciones[i],
                seleccionado: _seleccionado == i,
                deshabilitado: _seleccionado != null,
                onTap: () {
                  setState(() => _seleccionado = i);
                  widget.onRespuesta(i);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _OpcionButton extends StatelessWidget {
  final String texto;
  final bool seleccionado;
  final bool deshabilitado;
  final VoidCallback onTap;

  const _OpcionButton({
    required this.texto,
    required this.seleccionado,
    required this.deshabilitado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bordeColor = deshabilitado && !seleccionado
        ? Colors.grey.shade300
        : _azulOscuro;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        height: 64,
        child: OutlinedButton(
          onPressed: deshabilitado ? null : onTap,
          style: OutlinedButton.styleFrom(
            backgroundColor: seleccionado ? _azulOscuro : Colors.white,
            foregroundColor: seleccionado ? Colors.white : Colors.black87,
            disabledForegroundColor:
                seleccionado ? Colors.white : Colors.grey.shade400,
            disabledBackgroundColor:
                seleccionado ? _azulOscuro : Colors.white,
            side: BorderSide(color: bordeColor, width: 1.5),
            textStyle: const TextStyle(fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(texto, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
