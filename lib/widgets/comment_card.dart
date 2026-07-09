import 'package:flutter/material.dart';
import '../models/comment_model.dart';

/// Tarjeta que representa un comentario dentro del detalle de un
/// incidente. Widget puramente de presentación (no accede a
/// repositorios ni providers: recibe todo por parámetro).
///
/// Si [isOwnComment] es `true`, muestra un menú con las opciones
/// "Editar" y "Eliminar" que disparan los callbacks [onEdit] y [onDelete].
class CommentCard extends StatelessWidget {
  final CommentModel comment;
  final String authorName;
  final bool isOwnComment;

  /// Llamado cuando el usuario elige "Editar" en el menú contextual.
  final VoidCallback? onEdit;

  /// Llamado cuando el usuario elige "Eliminar" en el menú contextual.
  final VoidCallback? onDelete;

  const CommentCard({
    super.key,
    required this.comment,
    this.authorName = 'Usuario',
    this.isOwnComment = false,
    this.onEdit,
    this.onDelete,
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
                // Avatar con inicial del nombre
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

                // Menú de opciones: solo visible para el dueño del comentario
                if (isOwnComment)
                  Builder(
                    builder: (btnCtx) => IconButton(
                      icon: const Icon(Icons.more_vert, size: 18),
                      tooltip: 'Opciones del comentario',
                      onPressed: () async {
                        // Calcular posición exacta del botón en pantalla
                        // para que el menú aparezca justo a su lado.
                        final box =
                            btnCtx.findRenderObject() as RenderBox?;
                        final overlay = Overlay.of(btnCtx)
                            .context
                            .findRenderObject() as RenderBox?;

                        if (box == null || overlay == null) return;

                        final rect = RelativeRect.fromRect(
                          box.localToGlobal(Offset.zero, ancestor: overlay) &
                              box.size,
                          Offset.zero & overlay.size,
                        );

                        final selected =
                            await showMenu<_CommentAction>(
                          context: btnCtx,
                          position: rect,
                          items: const [
                            PopupMenuItem(
                              value: _CommentAction.edit,
                              child: Row(children: [
                                Icon(Icons.edit_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ]),
                            ),
                            PopupMenuItem(
                              value: _CommentAction.delete,
                              child: Row(children: [
                                Icon(Icons.delete_outline,
                                    size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Eliminar',
                                    style:
                                        TextStyle(color: Colors.red)),
                              ]),
                            ),
                          ],
                        );

                        if (selected == _CommentAction.edit) {
                          onEdit?.call();
                        } else if (selected == _CommentAction.delete) {
                          onDelete?.call();
                        }
                      },
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

/// Acciones disponibles en el menú contextual del comentario.
enum _CommentAction { edit, delete }
