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

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.alertRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Comentarios', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        StreamBuilder<List<CommentModel>>(
          stream: context.read<CommentProvider>().watchComments(widget.incidentId),
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
                child: Text('No se pudieron cargar los comentarios.',
                    style: TextStyle(color: AppColors.gray)),
              );
            }

            final comments = snapshot.data ?? [];

            if (comments.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Sé el primero en comentar sobre este incidente.',
                    style: TextStyle(color: AppColors.gray)),
              );
            }

            return Column(
              children: comments.map((c) {
                return CommentCard(
                  comment: c,
                  authorName: c.userId == currentUserId ? 'Tú' : 'Usuario',
                  isOwnComment: c.userId == currentUserId,
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 8),
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
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ],
    );
  }
}
