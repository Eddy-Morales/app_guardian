import 'package:flutter/material.dart';
import '../models/comment_model.dart';

/// Tarjeta que representa un comentario dentro del detalle de un
/// incidente. Widget puramente de presentación (no accede a
/// repositorios ni providers: recibe todo por parámetro).
class CommentCard extends StatelessWidget {
  final CommentModel comment;
  final String authorName;
  final bool isOwnComment;

  const CommentCard({
    super.key,
    required this.comment,
    this.authorName = 'Usuario',
    this.isOwnComment = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      isOwnComment ? theme.colorScheme.primary : Colors.grey,
                  child: Text(
                    authorName.isNotEmpty ? authorName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    authorName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment.message, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
