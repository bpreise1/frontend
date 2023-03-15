import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:frontend/models/comment.dart';

class SlidableCommentTile extends StatelessWidget {
  const SlidableCommentTile(
      {required this.comment, required this.child, this.onDelete, super.key});

  final Comment comment;
  final Future<void> Function(Comment comment)? onDelete;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: UniqueKey(),
      enabled: onDelete != null,
      endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: .4,
          dismissible: DismissiblePane(
              resizeDuration: const Duration(milliseconds: 150),
              onDismissed: () async {
                await onDelete!(comment);
              }),
          children: [
            SlidableAction(
              autoClose: false,
              backgroundColor: const Color(0xFFB00020),
              label: 'Delete',
              icon: Icons.delete,
              onPressed: ((context) async {
                final SlidableController slidableController =
                    Slidable.of(context)!;
                await slidableController.dismiss(
                  ResizeRequest(
                    const Duration(milliseconds: 150),
                    (() async {
                      await onDelete!(comment);
                    }),
                  ),
                );
              }),
            ),
          ]),
      child: child,
    );
  }
}
