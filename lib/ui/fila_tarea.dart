import 'package:flutter/material.dart';

import '../datos/tarea.dart';
import '../diseno/marca.dart';

/// Una tarea: tarjeta con casilla (card + checkbox).
class FilaTarea extends StatelessWidget {
  const FilaTarea({
    super.key,
    required this.tarea,
    required this.onChanged,
  });

  final Tarea tarea;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final hecha = tarea.completada;
    return Padding(
      padding: const EdgeInsets.only(bottom: Marca.e3),
      child: CheckboxListTile(
        value: hecha,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
        tileColor: Marca.base200,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(Marca.radioCaja),
          ),
          side: const BorderSide(color: Marca.base300),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Marca.e3,
          vertical: Marca.e1,
        ),
        title: Text(
          tarea.titulo,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: hecha
                ? Marca.al(Marca.secundario, .5)
                : Marca.texto,
            decoration: hecha
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            decorationColor: Marca.primario,
          ),
        ),
      ),
    );
  }
}
