import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/theme.dart';
import '../models/comment_model.dart';
import '../providers/comment_provider.dart';
import 'comment_card.dart';

/// Sección de comentarios en tiempo real de un incidente. Usa
/// `StreamBuilder` porque `CommentProvider.watchComments` expone un
/// Stream respaldado por Supabase Realtime: cada vez que otro usuario
/// publica un comentario, esta lista se actualiza sola, sin necesidad
/// de recargar la pantalla.
class CommentsSection extends StatefulWidget {
  final String incidentId;

  const CommentsSection({super.key, required this.incidentId});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final _messageController = TextEditingController();
  bool _sending = false;

  late final Stream<List<CommentModel>> _commentsStream;

  @override
  void initState() {
    super.initState();
    _commentsStream =
        context.read<CommentProvider>().watchComments(widget.incidentId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // ── Enviar comentario nuevo ───────────────────────────────────────────────

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;

    setState(() => _sending = true);

    final comment = CommentModel(
      id: '',
      incidentId: widget.incidentId,
      userId: currentUser.id,
      message: text,
      createdAt: DateTime.now(),
    );

    final error = await context.read<CommentProvider>().addComment(comment);

    if (!mounted) return;
    setState(() => _sending = false);

    if (error == null) {
      _messageController.clear();
    } else {
      _showError(error);
    }
  }

  // ── Editar comentario ─────────────────────────────────────────────────────

  /// Abre un diálogo con un campo de texto pre-llenado con el mensaje
  /// actual. Guarda el cambio solo si el texto es diferente y no está vacío.
  Future<void> _showEditDialog(CommentModel comment) async {
    final newText = await showDialog<String>(
      context: context,
      builder: (ctx) => _EditCommentDialog(initialMessage: comment.message),
    );
 
    if (!mounted || newText == null) return;
    if (newText.isEmpty || newText == comment.message) return;
 
    final error = await context
        .read<CommentProvider>()
        .editComment(comment.id, newText);
 
    if (!mounted) return;
    if (error != null) _showError(error);
  }

  // ── Eliminar comentario ───────────────────────────────────────────────────

  /// Muestra un diálogo de confirmación antes de eliminar el comentario.
  Future<void> _confirmDelete(CommentModel comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar comentario'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este comentario? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.alertRed,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    final error =
        await context.read<CommentProvider>().removeComment(comment.id);

    if (!mounted) return;
    if (error != null) _showError(error);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.alertRed,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comentarios',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
 
        // Lista de comentarios en tiempo real
        StreamBuilder<List<CommentModel>>(
          stream: _commentsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
 
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No se pudieron cargar los comentarios.',
                  style: TextStyle(color: AppColors.gray),
                ),
              );
            }
 
            final comments = snapshot.data ?? [];
 
            if (comments.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Sé el primero en comentar sobre este incidente.',
                  style: TextStyle(color: AppColors.gray),
                ),
              );
            }
 
            return Column(
              children: comments.map((c) {
                final isOwn = c.userId == currentUserId;
                return CommentCard(
                  comment: c,
                  authorName: isOwn ? 'Tú' : 'Usuario',
                  isOwnComment: isOwn,
                  // Los callbacks solo se asignan cuando el comentario
                  // pertenece al usuario actual
                  onEdit: isOwn ? () => _showEditDialog(c) : null,
                  onDelete: isOwn ? () => _confirmDelete(c) : null,
                );
              }).toList(),
            );
          },
        ),
 
        const SizedBox(height: 8),
 
        // Campo de texto para escribir un nuevo comentario
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Escribe un comentario...',
                ),
                minLines: 1,
                maxLines: 3,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _sending ? null : _send,
              icon: _sending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ],
    );
  }
}

// Diálogo para editar el mensaje de un comentario existente.
class _EditCommentDialog extends StatefulWidget {
  final String initialMessage;
  const _EditCommentDialog({required this.initialMessage});
  @override
  State<_EditCommentDialog> createState() => _EditCommentDialogState();
}
class _EditCommentDialogState extends State<_EditCommentDialog> {
  late final TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialMessage);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar comentario'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 4,
        minLines: 1,
        decoration: const InputDecoration(
          hintText: 'Escribe tu comentario...',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
