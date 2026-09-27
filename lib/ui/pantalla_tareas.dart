import 'package:flutter/material.dart';

import '../datos/cuenta.dart';
import '../datos/repositorio_tareas.dart';
import '../datos/tarea.dart';
import '../diseno/componentes.dart';
import '../diseno/marca.dart';
import 'fila_tarea.dart';
import 'pantalla_cuenta.dart';

class PantallaTareas extends StatefulWidget {
  const PantallaTareas({
    super.key,
    required this.invitado,
    this.correo,
  });

  /// Usuario anónimo: todavía sin correo ni contraseña.
  final bool invitado;
  final String? correo;

  @override
  State<PantallaTareas> createState() => _PantallaTareasState();
}

class _PantallaTareasState extends State<PantallaTareas> {
  final _repositorio = RepositorioTareas();
  final _cuenta = Cuenta();
  final _campo = TextEditingController();
  final _foco = FocusNode();

  // Una sola vez: si lo creas en build(),
  // cada redibujado abre una suscripción nueva.
  late final Stream<List<Tarea>> _tareas = _repositorio
      .observar();

  @override
  void dispose() {
    _campo.dispose();
    _foco.dispose();
    super.dispose();
  }

  Future<void> _crear() async {
    final titulo = _campo.text.trim();
    if (titulo.isEmpty) return;
    _campo.clear();
    _foco.requestFocus(); // listo para la siguiente
    await _repositorio.crear(titulo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Marca.e5),
          child: Column(
            children: [
              const Encabezado(
                titulo: 'Mis tareas',
                subtitulo: 'Flutter + Supabase · Brainglab',
              ),
              const SizedBox(height: Marca.e4),
              widget.invitado
                  ? _GuardarCuenta(abrir: _abrirCuenta)
                  : _MiCuenta(
                      correo: widget.correo ?? '',
                      salir: _cuenta.cerrarSesion,
                    ),
              const SizedBox(height: Marca.e4),
              _nuevaTarea(),
              const SizedBox(height: Marca.e5),
              Expanded(child: _lista()),
            ],
          ),
        ),
      ),
    );
  }

  void _abrirCuenta(ModoCuenta modo) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PantallaCuenta(modo: modo),
      ),
    );
  }

  Widget _nuevaTarea() {
    return Tarjeta(
      padding: const EdgeInsets.all(Marca.e3),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _campo,
              focusNode: _foco,
              decoration: const InputDecoration(
                hintText: 'Nueva tarea',
              ),
              onSubmitted: (_) => _crear(),
            ),
          ),
          const SizedBox(width: Marca.e3),
          FilledButton.icon(
            onPressed: _crear,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  Widget _lista() {
    return StreamBuilder<List<Tarea>>(
      stream: _tareas,
      builder: (context, snapshot) {
        if (snapshot.hasError) return _Error(snapshot.error);
        if (!snapshot.hasData) return const _Cargando();
        if (snapshot.data!.isEmpty) return const _SinTareas();
        return ListView(
          children: [
            _Resumen(tareas: snapshot.data!),
            for (final tarea in snapshot.data!)
              FilaTarea(
                tarea: tarea,
                onChanged: (_) => _repositorio.alternar(tarea),
              ),
          ],
        );
      },
    );
  }
}

/// Aviso para el invitado: guardar su cuenta o entrar.
class _GuardarCuenta extends StatelessWidget {
  const _GuardarCuenta({required this.abrir});

  final void Function(ModoCuenta modo) abrir;

  @override
  Widget build(BuildContext context) {
    return Tarjeta(
      resaltada: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconoCaja(Icons.person_outline_rounded),
              const SizedBox(width: Marca.e3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estás como invitado',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Guárdala para no perder tus tareas.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Marca.al(Marca.secundario, .7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Marca.e3),
          Row(
            children: [
              FilledButton(
                onPressed: () => abrir(ModoCuenta.guardar),
                child: const Text('Guardar mi cuenta'),
              ),
              const SizedBox(width: Marca.e2),
              TextButton(
                onPressed: () => abrir(ModoCuenta.entrar),
                child: const Text('Ya tengo cuenta'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Cuenta guardada: su correo y la opción de salir.
class _MiCuenta extends StatelessWidget {
  const _MiCuenta({required this.correo, required this.salir});

  final String correo;
  final Future<void> Function() salir;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Insignia(
              correo,
              icono: Icons.verified_user_rounded,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: salir,
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: const Text('Salir'),
        ),
      ],
    );
  }
}

/// Cabecera de la lista: cuántas tareas quedan pendientes.
class _Resumen extends StatelessWidget {
  const _Resumen({required this.tareas});

  final List<Tarea> tareas;

  @override
  Widget build(BuildContext context) {
    final pendientes = tareas
        .where((t) => !t.completada)
        .length;
    return Padding(
      padding: const EdgeInsets.only(bottom: Marca.e3),
      child: Row(
        children: [
          Text(
            'TAREAS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Marca.al(Marca.secundario, .6),
            ),
          ),
          const Spacer(),
          Insignia(
            pendientes == 1
                ? '1 pendiente'
                : '$pendientes pendientes',
            icono: Icons.bolt_rounded,
          ),
        ],
      ),
    );
  }
}

class _SinTareas extends StatelessWidget {
  const _SinTareas();

  @override
  Widget build(BuildContext context) {
    return const EstadoVacio(
      icono: Icons.task_alt_rounded,
      titulo: 'Sin tareas todavía',
      texto: 'Escribe la primera y pulsa Agregar.',
    );
  }
}

/// Mientras llega la primera lista.
class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// Si el stream informa un error.
class _Error extends StatelessWidget {
  const _Error(this.error);

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return EstadoVacio(
      icono: Icons.cloud_off_rounded,
      titulo: 'No se pudieron cargar las tareas',
      texto: '$error',
    );
  }
}
