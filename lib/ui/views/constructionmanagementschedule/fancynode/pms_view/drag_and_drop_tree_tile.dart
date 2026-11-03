import 'package:flutter/material.dart';
import '../../fancynode/pms_view/nodee.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import '../src/drag_and_drop.dart';
import '../src/tree_controller.dart';

extension on TreeDragAndDropDetails<Node> {
  T mapDropPosition<T>({
    required T Function() whenAbove,
    required T Function() whenInside,
    required T Function() whenBelow,
  }) {
    final double oneThirdOfTotalHeight = targetBounds.height * 0.3;
    final double pointerVerticalOffset = dropPosition.dy;

    if (pointerVerticalOffset < oneThirdOfTotalHeight) {
      return whenAbove();
    } else if (pointerVerticalOffset < oneThirdOfTotalHeight * 2) {
      return whenInside();
    } else {
      return whenBelow();
    }
  }
}

class DragAndDropTreeTile extends StatefulWidget {
  const DragAndDropTreeTile({
    super.key,
    this.scroll,
    required this.entry,
    required this.onNodeAccepted,
    this.borderSide = BorderSide.none,
    this.onFolderPressed,
    this.onFilePressed,
    this.controller,
    // required this.fetchRecords,
    required this.projectId,
    required this.towarId,
  });
  final String projectId;
  final String towarId;
  final ScrollPhysics? scroll;
  final TreeEntry<Node> entry;
  final TreeDragTargetNodeAccepted<Node> onNodeAccepted;
  final BorderSide borderSide;
  final VoidCallback? onFolderPressed;
  final VoidCallback? onFilePressed;

  final ScrollController? controller;
  // final VoidCallback fetchRecords;

  @override
  State<DragAndDropTreeTile> createState() => _DragAndDropTreeTileState();
}

class _DragAndDropTreeTileState extends State<DragAndDropTreeTile> {
  @override
  Widget build(BuildContext context) {
    return TreeDragTarget<Node>(
      node: widget.entry.node,
      onNodeAccepted: widget.onNodeAccepted,
      builder: (BuildContext context, TreeDragAndDropDetails<Node>? details) {
        Decoration? decoration;

        if (details != null) {
          decoration = BoxDecoration(
            border: details.mapDropPosition(
              whenAbove: () => Border(top: widget.borderSide),
              whenInside: () => Border.fromBorderSide(widget.borderSide),
              whenBelow: () => Border(bottom: widget.borderSide),
            ),
          );
        }

        return TreeDraggable<Node>(
          node: widget.entry.node,
          childWhenDragging: Opacity(
            opacity: .5,
            child: IgnorePointer(
              child: TreeTile(
                entry: widget.entry,
                // fetchRecords: widget.fetchRecords,
                projectId: widget.projectId,
                towarId: widget.towarId,
              ),
            ),
          ),
          feedback: IntrinsicWidth(
            child: Material(
              elevation: 4,
              child: TreeTile(
                entry: widget.entry,
                showIndentation: false,
                onFolderPressed: () {},
                // fetchRecords: widget.fetchRecords,
                projectId: widget.projectId,
                towarId: widget.towarId,
              ),
            ),
          ),
          child: TreeTile(
            entry: widget.entry,
            onFolderPressed: widget.entry.node.isLeaf
                ? widget.onFilePressed
                : widget.onFolderPressed,
            decoration: decoration,
            flag: false,
            // fetchRecords: widget.fetchRecords,
            projectId: widget.projectId,
            towarId: widget.towarId,
          ),
        );
      },
    );
  }
}
