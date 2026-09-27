import 'package:supabase_flutter/supabase_flutter.dart';

import 'tarea.dart';

/// Único punto de la app que habla con Supabase.
class RepositorioTareas {
  final SupabaseClient _db = Supabase.instance.client;

  /// Lista viva: se actualiza sola con cada cambio.
  Stream<List<Tarea>> observar() => _db
      .from('tareas')
      .stream(primaryKey: ['id'])
      .order('created_at') // descendente por defecto
      .map((filas) => filas.map(Tarea.desdeFila).toList());

  Future<void> crear(String titulo) async {
    // user_id no se envía: Postgres pone auth.uid().
    await _db.from('tareas').insert({'titulo': titulo});
  }

  Future<void> alternar(Tarea tarea) async {
    await _db
        .from('tareas')
        .update({'completada': !tarea.completada})
        .eq('id', tarea.id);
  }
}
