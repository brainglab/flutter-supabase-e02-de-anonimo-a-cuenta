import 'package:flutter/material.dart';

import '../datos/cuenta.dart';
import '../diseno/componentes.dart';
import '../diseno/marca.dart';

enum ModoCuenta { guardar, entrar }

/// Guardar la cuenta de un invitado (correo → código →
/// contraseña) o entrar con una cuenta que ya existe.
class PantallaCuenta extends StatefulWidget {
  const PantallaCuenta({super.key, required this.modo});

  final ModoCuenta modo;

  @override
  State<PantallaCuenta> createState() => _PantallaCuentaState();
}

class _PantallaCuentaState extends State<PantallaCuenta> {
  final _cuenta = Cuenta();
  final _correo = TextEditingController();
  final _codigo = TextEditingController();
  final _clave = TextEditingController();
  var _paso = 1; // 1 correo · 2 código · 3 contraseña
  var _ocupado = false;
  String? _error;

  bool get _guardar => widget.modo == ModoCuenta.guardar;

  @override
  void dispose() {
    _correo.dispose();
    _codigo.dispose();
    _clave.dispose();
    super.dispose();
  }

  Future<void> _continuar() async {
    setState(() {
      _ocupado = true;
      _error = null;
    });
    try {
      await _siguientePaso();
    } on ErrorCuenta catch (e) {
      setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _siguientePaso() async {
    final correo = _correo.text.trim();
    if (!_guardar) {
      await _cuenta.iniciarSesion(correo, _clave.text);
      return _volver();
    }
    switch (_paso) {
      case 1:
        await _cuenta.agregarCorreo(correo);
        setState(() => _paso = 2);
      case 2:
        final codigo = _codigo.text.trim();
        await _cuenta.confirmarCodigo(correo, codigo);
        setState(() => _paso = 3);
      case 3:
        await _cuenta.crearContrasena(_clave.text);
        _volver();
    }
  }

  void _volver() {
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Marca.e5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: _volver,
                  tooltip: 'Volver',
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              const SizedBox(height: Marca.e3),
              Encabezado(
                titulo: _guardar
                    ? 'Guarda tu cuenta'
                    : 'Ya tengo cuenta',
                subtitulo: _guardar
                    ? 'Tus tareas se quedan contigo'
                    : 'Entra con tu correo y contraseña',
              ),
              const SizedBox(height: Marca.e5),
              if (_guardar) ...[
                _Pasos(actual: _paso),
                const SizedBox(height: Marca.e4),
              ],
              Tarjeta(child: _formulario()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formulario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ..._campos(),
        if (_error != null) ...[
          const SizedBox(height: Marca.e3),
          Text(
            _error!,
            style: const TextStyle(
              color: Marca.primario,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: Marca.e4),
        FilledButton.icon(
          onPressed: _ocupado ? null : _continuar,
          icon: Icon(_icono()),
          label: Text(_accion()),
        ),
      ],
    );
  }

  List<Widget> _campos() {
    final correo = TextField(
      controller: _correo,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      decoration: const InputDecoration(
        labelText: 'Correo',
        hintText: 'tu@correo.com',
      ),
    );
    if (!_guardar) {
      return [
        correo,
        const SizedBox(height: Marca.e3),
        _contrasena(),
      ];
    }
    return switch (_paso) {
      1 => [correo],
      2 => [
        TextField(
          controller: _codigo,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            labelText: 'Código',
            hintText: '6 dígitos',
            helperText: 'Lo enviamos a ${_correo.text.trim()}',
            counterText: '',
          ),
        ),
      ],
      _ => [_contrasena(ayuda: 'Correo confirmado ✓')],
    };
  }

  TextField _contrasena({String? ayuda}) => TextField(
    controller: _clave,
    obscureText: true,
    decoration: InputDecoration(
      labelText: 'Contraseña',
      hintText: 'Al menos 6 caracteres',
      helperText: ayuda,
    ),
  );

  String _accion() => !_guardar
      ? 'Entrar'
      : switch (_paso) {
          1 => 'Enviar código',
          2 => 'Confirmar',
          _ => 'Guardar cuenta',
        };

  IconData _icono() => !_guardar
      ? Icons.login_rounded
      : switch (_paso) {
          1 => Icons.mail_outline_rounded,
          2 => Icons.verified_outlined,
          _ => Icons.lock_outline_rounded,
        };
}

/// Los tres pasos, con el actual resaltado.
class _Pasos extends StatelessWidget {
  const _Pasos({required this.actual});

  final int actual;

  static const _nombres = ['Correo', 'Código', 'Contraseña'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _nombres.length; i++) ...[
          if (i > 0) const SizedBox(width: Marca.e2),
          Expanded(child: _paso(i + 1, _nombres[i])),
        ],
      ],
    );
  }

  Widget _paso(int n, String nombre) {
    final hecho = n < actual;
    final activo = n == actual;
    final color = activo || hecho
        ? Marca.primario
        : Marca.al(Marca.secundario, .5);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 4,
          decoration: BoxDecoration(
            color: activo || hecho
                ? Marca.primario
                : Marca.base300,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(height: Marca.e2),
        Text(
          hecho ? '✓ $nombre' : '$n · $nombre',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
