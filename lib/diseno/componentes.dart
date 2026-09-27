import 'package:flutter/material.dart';

import 'marca.dart';

/// Componentes reutilizables de Brainglab UI. Cada uno replica
/// un componente de DaisyUI con el tema brainglab-dark.

/// card: superficie con borde y esquinas de 16.
class Tarjeta extends StatelessWidget {
  const Tarjeta({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Marca.e4),
    this.resaltada = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Borde y brillo del color primario (elemento activo).
  final bool resaltada;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: padding,
      decoration: BoxDecoration(
        color: Marca.base200,
        borderRadius: BorderRadius.circular(Marca.radioCaja),
        border: Border.all(
          color: resaltada
              ? Marca.al(Marca.primario, .6)
              : Marca.base300,
        ),
        boxShadow: resaltada
            ? [
                BoxShadow(
                  color: Marca.al(Marca.primario, .25),
                  blurRadius: 24,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

/// badge badge-primary badge-soft: etiqueta pequeña.
class Insignia extends StatelessWidget {
  const Insignia(this.texto, {super.key, this.icono});

  final String texto;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Marca.e3,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Marca.al(Marca.primario, .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icono != null) ...[
            Icon(icono, size: 14, color: Marca.primario),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              texto,
              overflow:
                  TextOverflow.ellipsis, // un correo largo
              style: const TextStyle(
                color: Marca.primario,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: .4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Caja de icono con fondo primario/10 (como en las
/// tarjetas de servicios de brainglab.com).
class IconoCaja extends StatelessWidget {
  const IconoCaja(this.icono, {super.key, this.tam = 44});

  final IconData icono;
  final double tam;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tam,
      height: tam,
      decoration: BoxDecoration(
        color: Marca.al(Marca.primario, .12),
        borderRadius: BorderRadius.circular(
          Marca.radioSelector,
        ),
      ),
      child: Icon(icono, color: Marca.primario, size: tam * .5),
    );
  }
}

/// Encabezado de pantalla: isotipo, título y subtítulo.
class Encabezado extends StatelessWidget {
  const Encabezado({
    super.key,
    required this.titulo,
    required this.subtitulo,
  });

  final String titulo;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset('assets/marca/isotipo.png', width: 40),
        const SizedBox(width: Marca.e3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.6,
                ),
              ),
              Text(
                subtitulo,
                style: TextStyle(
                  fontSize: 13,
                  color: Marca.al(Marca.secundario, .7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Estado vacío: icono, título y texto de ayuda.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.icono,
    required this.titulo,
    required this.texto,
  });

  final IconData icono;
  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconoCaja(icono, tam: 64),
          const SizedBox(height: Marca.e4),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: Marca.e1),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Marca.al(Marca.secundario, .7),
            ),
          ),
        ],
      ),
    );
  }
}
