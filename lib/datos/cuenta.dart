import 'package:supabase_flutter/supabase_flutter.dart';

/// Único punto de la app que habla con Supabase Auth.
///
/// Guardar la cuenta de un invitado no crea otro usuario:
/// le agrega correo y contraseña al mismo. Su id no cambia,
/// así que las políticas de RLS le siguen dando sus tareas.
class Cuenta {
  final GoTrueClient _auth = Supabase.instance.client.auth;

  /// El usuario actual, cada vez que cambia.
  Stream<User?> observar() => _auth.onAuthStateChange.map(
    (estado) => estado.session?.user,
  );

  /// Paso 1: Supabase envía un código a ese correo.
  Future<void> agregarCorreo(String correo) => _intentar(
    () => _auth.updateUser(UserAttributes(email: correo)),
  );

  /// Paso 2: el código confirma el correo.
  /// Desde aquí, el usuario ya no es anónimo.
  Future<void> confirmarCodigo(String correo, String codigo) =>
      _intentar(
        () => _auth.verifyOTP(
          type: OtpType.emailChange,
          email: correo,
          token: codigo,
        ),
      );

  /// Paso 3: con el correo confirmado, la contraseña.
  Future<void> crearContrasena(String contrasena) => _intentar(
    () =>
        _auth.updateUser(UserAttributes(password: contrasena)),
  );

  /// En otro dispositivo: entra con su cuenta.
  Future<void> iniciarSesion(
    String correo,
    String contrasena,
  ) => _intentar(
    () => _auth.signInWithPassword(
      email: correo,
      password: contrasena,
    ),
  );

  /// Al salir, la app sigue con un invitado nuevo.
  Future<void> cerrarSesion() => _intentar(() async {
    await _auth.signOut();
    await _auth.signInAnonymously();
  });

  Future<void> _intentar(Future<void> Function() accion) async {
    try {
      await accion();
    } on AuthException catch (e) {
      throw ErrorCuenta.desde(e);
    }
  }
}

/// Error de Auth con un mensaje listo para la pantalla.
class ErrorCuenta implements Exception {
  const ErrorCuenta(this.mensaje);

  /// Códigos de error de Auth (docs de Supabase:
  /// guides/auth/debugging/error-codes).
  factory ErrorCuenta.desde(AuthException e) =>
      ErrorCuenta(switch (e.code) {
        'email_exists' => 'Ese correo ya tiene una cuenta.',
        'validation_failed' => 'Revisa el correo.',
        'otp_expired' => 'El código no es válido o venció.',
        'weak_password' => 'Usa al menos 6 caracteres.',
        'invalid_credentials' =>
          'Correo o contraseña incorrectos.',
        'over_email_send_rate_limit' =>
          'Espera unos segundos antes de pedir otro código.',
        _ => 'No se pudo completar. Inténtalo de nuevo.',
      });

  final String mensaje;

  @override
  String toString() => mensaje;
}
