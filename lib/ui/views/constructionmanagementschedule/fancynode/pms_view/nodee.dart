import '../../models/ws_get_pms_structure.dart';

class Node {
  Node({
    required this.id,
    bool? expandnode = false,
    List<Node>? children,
    this.dict,
  }) : children1 = <Node>[] {
    if (children == null) return;

    for (final Node child in children) {
      child.parent1 = this;
      children1.add(child);
    }
  }

  final int id;
  List<Node> children1;
  final PmsStructure? dict;

  Iterable<Node> get children => children1;
  bool get isLeaf => children1.isEmpty;

  Node? get parent => parent1;
  Node? parent1;

  int get index => parent1?.children1.indexOf(this) ?? -1;

  void insertChild(int index, Node node) {
    // Adjust the index if necessary when dropping a node at the same parent
    if (node.parent1 == this && node.index < index) {
      index--;
    }

    node
      ..parent1?.children1.remove(node)
      ..parent1 = this;

    children1.insert(index, node);
  }
}
