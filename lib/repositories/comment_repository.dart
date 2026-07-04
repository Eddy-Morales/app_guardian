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
        .map((data) => data.map((e) => CommentModel.fromMap(e)).toList());
  }

  // Publicar un nuevo comentario
  Future<void> createComment(CommentModel comment) async {
    try {
      await _supabase.from('comments').insert(comment.toMap());
    } catch (e) {
      throw Exception('Error al publicar comentario: $e');
    }
  }
}