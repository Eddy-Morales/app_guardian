import 'package:flutter/material.dart';
import '../models/comment_model.dart';
import '../repositories/comment_repository.dart';

class CommentProvider extends ChangeNotifier {
  final CommentRepository _commentRepository;

  CommentProvider(this._commentRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Expone el Stream para que la vista (UI) lo escuche con un StreamBuilder
  Stream<List<CommentModel>> watchComments(String incidentId) {
    return _commentRepository.getCommentsStream(incidentId);
  }

  // Enviar un nuevo comentario
  Future<String?> addComment(CommentModel comment) async {
    _setLoading(true);
    try {
      await _commentRepository.createComment(comment);
      // No necesitamos recargar listas porque el Stream de arriba se actualiza automáticamente
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}