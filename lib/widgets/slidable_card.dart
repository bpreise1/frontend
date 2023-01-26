import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SlidableCard extends ConsumerWidget {
  const SlidableCard({required this.child, required this.onDismiss, super.key});

  final Widget child;
  final void Function() onDismiss;

  final _resizeDuration = const Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: Slidable(
        key: UniqueKey(),
        endActionPane: ActionPane(
          extentRatio: .4,
          dismissible: DismissiblePane(
              resizeDuration: _resizeDuration,
              onDismissed: () {
                onDismiss();
              }),
          motion: const StretchMotion(),
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
                    _resizeDuration,
                    (() {
                      onDismiss();
                    }),
                  ),
                );
              }),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
