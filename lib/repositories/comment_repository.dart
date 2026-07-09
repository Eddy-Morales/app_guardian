import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment_model.dart';

class CommentRepository {
  final SupabaseClient _supabase;

  CommentRepository(this._supabase);

  // Escuchar comentarios en tiempo real para un incidente específico
  Stream<List<CommentModel>> getCommentsStream(String incidentId) {
    return _supabase
        .from('comments')
        .stream(primaryKey: ['id'])
        .eq('incident_id', incidentId)
        .order('created_at', ascending: true) // Los más antiguos arriba
        .map((data) {
          // Supabase puede emitir el mismo registro dos veces (consulta HTTP
          // inicial + evento Realtime). Deduplicamos por 'id' para evitar
          // que los comentarios aparezcan duplicados en la UI.
          final seen = <String>{};
          return data
              .map((e) => CommentModel.fromMap(e))
              .where((c) => seen.add(c.id))
              .toList();
        });
  }

  // Publicar un nuevo comentario
  Future<void> createComment(CommentModel comment) async {
    try {
      await _supabase.from('comments').insert(comment.toMap());
    } catch (e) {
      throw Exception('Error al publicar comentario: $e');
    }
  }

  // Editar el mensaje de un comentario existente
  Future<void> updateComment(String commentId, String newMessage) async {
    try {
      await _supabase
          .from('comments')
          .update({'message': newMessage})
          .eq('id', commentId);
    } catch (e) {
      throw Exception('Error al editar comentario: $e');
    }
  }

  // Eliminar un comentario por su ID
  Future<void> deleteComment(String commentId) async {
    try {
      await _supabase.from('comments').delete().eq('id', commentId);
    } catch (e) {
      throw Exception('Error al eliminar comentario: $e');
    }
  }
}